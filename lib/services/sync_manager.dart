// lib/services/sync_manager.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/pending_op.dart';
import '../models/task.dart';
import 'local_task_store.dart';
import '../providers/auth_provider.dart';
import 'task_service_http.dart';

class SyncManager {
  final TaskServiceHttp taskService;
  final AuthProvider auth;
  final LocalTaskStore store;

  bool _draining = false;
  Timer? _debounce;
  final Random _rng;

  SyncManager({
    required this.taskService,
    required this.auth,
    required this.store,
    Random? rng,
  }) : _rng = rng ?? Random();

  /// Safe to call anytime; starts a drain soon if not already running.
  void kick() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      if (_draining) return;
      _draining = true;
      unawaited(_drainLoop());
    });
  }

  /// Manually process a single pass (good for tests/debug).
  Future<void> drainOnce() async {
    if (_draining) return;
    _draining = true;
    try {
      await _drainLoop(singlePass: true);
    } finally {
      _draining = false;
    }
  }

  Future<void> _drainLoop({bool singlePass = false}) async {
    try {
      while (true) {
        // stop if logged out
        final token = auth.token;
        if (token == null || token.isEmpty) {
          debugPrint('SYNC → stopped (no token)');
          return;
        }

        final queue = await store.loadQueue();
        if (queue.isEmpty) {
          debugPrint('SYNC → queue empty');
          return;
        }

        final ops = List<PendingOp>.from(queue);
        final op = ops.first;

        try {
          switch (op.kind) {
            case PendingKind.create:
              await _handleCreate(op, ops);
              break;
            case PendingKind.toggle:
              await _handleToggle(op, ops);
              break;
            case PendingKind.delete:
              await _handleDelete(op, ops);
              break;
            case PendingKind.update:
              // MVP: drop update (or add a handler later calling patchTitle)
              ops.removeAt(0);
              await store.saveQueue(ops);
              break;
          }
        } on Unauthorized401 {
          debugPrint('SYNC → 401, waiting for re-login');
          return; // stop; caller will kick() again after successful login
        } catch (e) {
          // retryable error: exponential backoff + jitter, persist attempts
          final attempts = op.attempts + 1;
          final baseMs = 500 * (1 << attempts.clamp(0, 6)); // 0.5s..32s
          final jitter = _rng.nextInt(300);
          final delay = Duration(milliseconds: baseMs + jitter);

          ops[0] = op.copyWith(attempts: attempts);
          await store.saveQueue(ops);

          debugPrint('SYNC → error: $e; retry in ${delay.inMilliseconds}ms');
          Timer(delay, kick);
          return; // exit loop now; will resume later
        }

        if (singlePass) return;
      }
    } finally {
      _draining = false;
    }
  }

  // --- handlers ---

  Future<void> _handleCreate(PendingOp op, List<PendingOp> ops) async {
    final payload = op.payload ?? const {};
    final title = (payload['title'] ?? '') as String;
    if (title.isEmpty) {
      // malformed op → drop head
      ops.removeAt(0);
      await store.saveQueue(ops);
      return;
    }

    final created = await taskService.create(title);

    // If enqueued create asked for done=true, toggle it now
    final done = (payload['done'] as bool?) ?? false;
    if (done) {
      await taskService.toggleDone(created.copyWith(done: true));
    }

    // Replace temp task locally (temp id is negative int stored as string)
    await _replaceTempOrInsert(created, tempIdString: op.id);

    // Remap remaining ops referencing temp id → real id
    final remapped = _remapIds(ops, fromId: op.id, toId: created.id.toString());
    remapped.removeAt(0); // pop processed create
    await store.saveQueue(remapped);
  }

  Future<void> _handleToggle(PendingOp op, List<PendingOp> ops) async {
    final id = _parseIntId(op.id);
    if (id == null) {
      ops.removeAt(0);
      await store.saveQueue(ops);
      return;
    }

    final desired = (op.payload?['done'] as bool?) ?? false;
    final tasks = await store.loadTasks();
    final current = tasks.firstWhere(
      (t) => t.id == id,
      orElse: () => Task(id: id, title: 'Task $id', done: desired),
    );

    await taskService.toggleDone(current.copyWith(done: desired));

    // Trust server result: update local cache with desired state
    final updated = current.copyWith(done: desired);
    await store.saveTasks(_upsert(tasks, updated));

    ops.removeAt(0);
    await store.saveQueue(ops);
  }

  Future<void> _handleDelete(PendingOp op, List<PendingOp> ops) async {
    final id = _parseIntId(op.id);
    if (id == null) {
      ops.removeAt(0);
      await store.saveQueue(ops);
      return;
    }

    await taskService.delete(id);

    final tasks = await store.loadTasks();
    final next = tasks.where((t) => t.id != id).toList(growable: false);
    await store.saveTasks(next);

    ops.removeAt(0);
    await store.saveQueue(ops);
  }

  // --- helpers ---

  int? _parseIntId(String s) {
    try {
      return int.parse(s);
    } catch (_) {
      return null;
    }
  }

  Future<void> _replaceTempOrInsert(
    Task created, {
    required String tempIdString,
  }) async {
    final tasks = await store.loadTasks();
    final tempInt = _parseIntId(tempIdString);
    if (tempInt != null) {
      final idx = tasks.indexWhere((t) => t.id == tempInt);
      if (idx >= 0) {
        final next = List<Task>.from(tasks)..[idx] = created;
        await store.saveTasks(next);
        return;
      }
    }
    await store.saveTasks([created, ...tasks]);
  }

  List<PendingOp> _remapIds(
    List<PendingOp> ops, {
    required String fromId,
    required String toId,
  }) {
    return ops
        .map((p) => p.id == fromId ? p.copyWith(id: toId) : p)
        .toList(growable: false);
  }

  List<Task> _upsert(List<Task> list, Task t) {
    final i = list.indexWhere((x) => x.id == t.id);
    if (i >= 0) {
      final next = List<Task>.from(list)..[i] = t;
      return next;
    }
    return [t, ...list];
  }
}
