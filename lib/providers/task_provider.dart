// lib/providers/task_provider.dart
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../models/task_mutation.dart';
import '../services/task_service.dart';
import '../services/local_task_store.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service;
  final LocalTaskStore _store;

  TaskProvider(this._service, [LocalTaskStore? store])
    : _store = store ?? LocalTaskStore();

  bool _initialized = false;
  bool _loading = false;
  String? _error;
  List<Task> _items = const [];

  // Offline-first
  final Map<int, int> _clocks = <int, int>{}; // taskId -> last logical clock
  final List<TaskMutation> _queue = <TaskMutation>[];
  bool _syncing = false;

  // Public API
  bool get initialized => _initialized;
  bool get loading => _loading;
  String? get error => _error;
  UnmodifiableListView<Task> get items => UnmodifiableListView(_items);

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

    // 3) Resume pending mutations (WAL)
    final raw = await _store.loadMutations();
    _queue
      ..clear()
      ..addAll(raw.map(TaskMutation.fromJson));
    for (final m in _queue) {
      _clocks[m.id] = max(_clocks[m.id] ?? 0, m.clock);
    }
    _syncMutations(); // fire & forget
  }

  Future<void> refresh() => load(force: true);

  /// UI calls this: `p.toggle(t)`
  Future<void> toggle(Task task) => toggleDone(task.id);

  /// Optimistic toggle + durable queue; no flip-back on transient failure
  Future<void> toggleDone(int id) async {
    final i = _items.indexWhere((t) => t.id == id);
    if (i < 0) return;
    final prev = _items[i];
    final desired = !prev.done;
    final optimistic = prev.copyWith(done: desired);

    debugPrint(
      'PROVIDER → TaskProvider.toggleDone(id: $id) (optimistic: $desired)',
    );

    // 1) Optimistic apply (and persist)
    _items = List.of(_items)..[i] = optimistic;
    await _store.saveTasks(_items);
    notifyListeners();

    // 2) Coalesce mutation for this id to the latest desired state
    final clock = (_clocks[id] ?? 0) + 1;
    _clocks[id] = clock;
    final m = TaskMutation(id: id, done: desired, clock: clock);

    _queue.removeWhere((q) => q.id == id);
    _queue.add(m);
    await _store.saveMutations(_queue.map((e) => e.toJson()).toList());

    // 3) Kick sync loop
    _syncMutations();
  }

  // === Sync loop with exponential backoff + jitter ===
  Future<void> _syncMutations() async {
    if (_syncing || _queue.isEmpty) return;
    _syncing = true;

    try {
      var delay = const Duration(milliseconds: 300);
      final rnd = Random();

      while (_queue.isNotEmpty) {
        final m = _queue.first;

        // Compose Task for service (we ignore server body; local is source of truth)
        final current = _items.firstWhere(
          (x) => x.id == m.id,
          orElse: () => Task(id: m.id, title: 'Task ${m.id}', done: m.done),
        );
        final toSend = current.copyWith(done: m.done);

        try {
          await _service.toggleDone(toSend);
          _queue.removeAt(0);
          await _store.saveMutations(_queue.map((e) => e.toJson()).toList());
          delay = const Duration(milliseconds: 300); // reset backoff
        } catch (e) {
          final sleep = delay + Duration(milliseconds: rnd.nextInt(250));
          debugPrint('SYNC → retry ${m.key} in ${sleep.inMilliseconds}ms');
          await Future.delayed(sleep);
          delay *= 2;
          if (delay > const Duration(seconds: 5)) {
            debugPrint(
              'SYNC → pausing; will retry later (queue=${_queue.length})',
            );
            break;
          }
        }
      }
    } finally {
      _syncing = false;
    }
  }
}
