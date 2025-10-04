// lib/providers/task_provider.dart
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../models/pending_op.dart';
import '../models/sync_event.dart'; // so it knows CreateCommitted, etc.
import '../services/task_service_http.dart';
import '../services/local_task_store.dart';
import '../services/sync_manager.dart';

class TaskProvider extends ChangeNotifier {
  final TaskServiceHttp _service;
  final LocalTaskStore _store;
  late SyncManager _sync; // injected from main.dart

  TaskProvider(this._service, this._store, this._sync) {
    // 👇 subscribe once, as soon as provider is constructed
    _sync.events.listen(_onSyncEvent);
  }

  void attachSync(SyncManager sync) {
    _sync = sync;
  }

  bool _initialized = false;
  bool _loading = false;
  String? _error;
  List<Task> _items = const [];

  // WAL/queue
  final _uuid = const Uuid();
  List<PendingOp> _queue = [];

  // Public API
  bool get initialized => _initialized;
  bool get loading => _loading;
  String? get error => _error;
  UnmodifiableListView<Task> get items => UnmodifiableListView(_items);

  /// Back-compat for older UI: p.toggle(task)
  Future<void> toggle(Task task) => toggleDone(task.id, !task.done);

  /// Handy if you only have an id in scope
  Future<void> toggleById(int id) {
    final i = _items.indexWhere((t) => t.id == id);
    if (i < 0) return Future.value();
    return toggleDone(id, !_items[i].done);
  }

  Future<void> _onSyncEvent(SyncEvent e) async {
    if (e is CreateCommitted) {
      final i = _items.indexWhere((t) => t.id == e.tempId);
      if (i >= 0) {
        _items = List.of(_items)..[i] = e.real;
      } else {
        _items = [..._items, e.real];
      }
      await _store.saveTasks(_items);
      notifyListeners();
    } else if (e is UpdateCommitted) {
      final i = _items.indexWhere((t) => t.id == e.real.id);
      if (i >= 0) {
        _items = List.of(_items)..[i] = e.real;
        await _store.saveTasks(_items);
        notifyListeners();
      }
    } else if (e is DeleteCommitted) {
      final before = _items.length;
      _items = _items.where((t) => t.id != e.id).toList(growable: false);
      if (_items.length != before) {
        await _store.saveTasks(_items);
        notifyListeners();
      }
    }
  }

  Future<void> load({bool force = false}) async {
    if (_initialized && !force) return;

    debugPrint('PROVIDER → TaskProvider.load(force: $force)');
    _loading = true;
    _error = null;
    notifyListeners();

    // 1) Local-first paint (SWR)
    try {
      final local = await _store.loadTasks();
      if (local.isNotEmpty) {
        _items = local;
        _initialized = true;
        _loading = false;
        notifyListeners();
      }
    } catch (_) {
      // ignore local decode issues
    }

    // 2) Background revalidate (network)
    try {
      final fresh = await _service.fetch();
      _items = fresh;
      await _store.saveTasks(_items);
      _initialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }

    // 3) Load WAL queue from disk
    _queue = List<PendingOp>.from(await _store.loadQueue());
    debugPrint('PROVIDER → loaded queue=${_queue.length}');
    if (_queue.isNotEmpty) {
      _sync.kick();
    }
  }

  Future<void> refresh() => load(force: true);

  // === WAL enqueue with compaction ===
  Future<void> _enqueue(PendingOp op) async {
    // Work on a growable copy to avoid "Unsupported operation: add"
    var q = List<PendingOp>.from(_queue);

    // Compaction rules
    if (op.kind == PendingKind.delete) {
      final i = q.lastIndexWhere(
        (e) => e.id == op.id && e.kind == PendingKind.create,
      );
      if (i != -1) {
        q.removeAt(i);
        _queue = q;
        await _store.saveQueue(_queue);
        _sync.kick();
        return;
      }
    }

    if (op.kind == PendingKind.toggle) {
      final i = q.lastIndexWhere(
        (e) => e.id == op.id && e.kind == PendingKind.create,
      );
      if (i != -1) {
        final create = q[i];
        q[i] = create.copyWith(payload: {...?create.payload, ...?op.payload});
        _queue = q;
        await _store.saveQueue(_queue);
        _sync.kick();
        return;
      }
      final j = q.lastIndexWhere(
        (e) => e.id == op.id && e.kind == PendingKind.toggle,
      );
      if (j != -1) {
        q[j] = q[j].copyWith(payload: op.payload);
        _queue = q;
        await _store.saveQueue(_queue);
        _sync.kick();
        return;
      }
    }

    if (op.kind == PendingKind.update) {
      final i = q.lastIndexWhere(
        (e) => e.id == op.id && e.kind == PendingKind.update,
      );
      if (i != -1) {
        q[i] = q[i].copyWith(payload: op.payload);
        _queue = q;
        await _store.saveQueue(_queue);
        _sync.kick();
        return;
      }
    }

    // default: append
    q.add(op);
    _queue = q;
    await _store.saveQueue(_queue);
    _sync.kick();
  }

  // === Public mutations (optimistic + enqueue) ===

  Future<Task?> addTask(String title) async {
    debugPrint('PROVIDER → TaskProvider.addTask("$title")');

    // Optimistic placeholder
    final tempInt = -DateTime.now().millisecondsSinceEpoch;
    final temp = Task(id: tempInt, title: title, done: false);
    _items = [temp, ..._items];
    await _store.saveTasks(_items);
    notifyListeners();

    // Enqueue create
    await _enqueue(
      PendingOp(
        opId: _uuid.v4(),
        kind: PendingKind.create,
        id: tempInt.toString(),
        payload: {
          'title': title,
          'done': false,
          'updated_at': DateTime.now().toIso8601String(),
        },
        ts: DateTime.now(),
      ),
    );

    return temp; // actual server-created Task will come after sync
  }

  Future<void> toggleDone(int id, bool done) async {
    final i = _items.indexWhere((t) => t.id == id);
    if (i < 0) return;
    final prev = _items[i];
    final optimistic = prev.copyWith(done: done);

    _items = List.of(_items)..[i] = optimistic;
    await _store.saveTasks(_items);
    notifyListeners();

    await _enqueue(
      PendingOp(
        opId: _uuid.v4(),
        kind: PendingKind.toggle,
        id: id.toString(),
        payload: {'done': done, 'updated_at': DateTime.now().toIso8601String()},
        ts: DateTime.now(),
      ),
    );
  }

  Future<void> updateTitle(int id, String title) async {
    final i = _items.indexWhere((t) => t.id == id);
    if (i < 0) return;
    final optimistic = _items[i].copyWith(title: title);

    _items = List.of(_items)..[i] = optimistic;
    await _store.saveTasks(_items);
    notifyListeners();

    await _enqueue(
      PendingOp(
        opId: _uuid.v4(),
        kind: PendingKind.update,
        id: id.toString(),
        payload: {
          'title': title,
          'updated_at': DateTime.now().toIso8601String(),
        },
        ts: DateTime.now(),
      ),
    );
  }

  Future<void> removeTask(int id) async {
    debugPrint('PROVIDER → TaskProvider.removeTask($id)');

    // 1) Optimistic remove
    final i = _items.indexWhere((t) => t.id == id);
    if (i < 0) return;
    _items = List.of(_items)..removeAt(i);
    await _store.saveTasks(_items);
    notifyListeners();

    // 2) Enqueue delete (durable WAL) and kick sync
    await _enqueue(
      PendingOp(
        opId: _uuid.v4(),
        kind: PendingKind.delete,
        id: id.toString(),
        payload: null,
        ts: DateTime.now(),
      ),
    );
  }
}
