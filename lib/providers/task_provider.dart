// lib/providers/task_provider.dart
import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service;
  TaskProvider(this._service);

  bool _initialized = false;
  bool _loading = false;
  String? _error;
  List<Task> _items = const [];

  // 👇 Public getters (your screen uses these)
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

    try {
      final data = await _service.fetch();
      _items = data;
      _initialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);

  /// UI calls this: `p.toggle(t)`
  Future<void> toggle(Task task) => toggleDone(task.id);

  /// Optimistic toggle by id + rollback on failure (keeps your existing pattern)
  Future<void> toggleDone(int id) async {
    final i = _items.indexWhere((t) => t.id == id);
    if (i < 0) return;

    final prev = _items[i];
    final optimistic = prev.copyWith(done: !prev.done);

    debugPrint(
      'PROVIDER → TaskProvider.toggleDone(id: $id)'
      ' (optimistic: ${optimistic.done})',
    );

    // Optimistic update
    _items = List.of(_items)..[i] = optimistic;
    notifyListeners();

    try {
      final server = await _service.toggleDone(optimistic);
      final merged = server.copyWith(id: prev.id); // keep id stable
      _items = List.of(_items)..[i] = merged;
    } catch (e) {
      // Rollback and surface error
      _items = List.of(_items)..[i] = prev;
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
