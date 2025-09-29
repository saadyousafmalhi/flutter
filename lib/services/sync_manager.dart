// lib/services/sync_manager.dart
import 'dart:async';
import 'dart:math';

import '../models/pending_op.dart';
import 'local_task_store.dart';
import '../providers/auth_provider.dart';
import 'task_service.dart'; // your interface

class SyncManager {
  final TaskService taskService;
  final TokenSource tokenSource; // AuthProvider implements this
  final LocalTaskStore store;

  bool _draining = false;
  Timer? _debounce; // simple guard so kick() is idempotent-ish
  final Random _rng;

  SyncManager({
    required this.taskService,
    required this.tokenSource,
    required this.store,
    Random? rng,
  }) : _rng = rng ?? Random();

  /// Safe to call anytime; starts a drain soon if not already running.
  void kick() {
    // debounce multiple kicks in the same tick/frame
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      if (_draining) return;
      _draining = true;
      // Fire and forget; errors are handled inside drainOnce later
      unawaited(_drainLoop());
    });
  }

  /// For tests/manual: process the queue once (no loop/backoff).
  Future<void> drainOnce() async {
    // We'll implement in step 5; for now just no-op.
  }

  Future<void> _drainLoop() async {
    try {
      // In step 5 we’ll:
      // - load queue
      // - process FIFO
      // - apply backoff & stop on 401
      // - remap temp IDs on create success
      // For now, just a stub so wiring compiles.
    } finally {
      _draining = false;
    }
  }
}
