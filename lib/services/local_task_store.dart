import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/pending_op.dart';

class LocalTaskStore {
  static const _kTasks = 'tasks.v1';
  static const _kMutations = 'mutations.v1';
  static const _kQueueKey = 'tasks_queue_v1';

  final SharedPreferences _sp;
  LocalTaskStore(this._sp);

  /// One-time async creator so callers don’t need to await getInstance everywhere.
  static Future<LocalTaskStore> create() async =>
      LocalTaskStore(await SharedPreferences.getInstance());

  // ---- Tasks ----
  Future<List<Task>> loadTasks() async {
    debugPrint('STORE → LocalTaskStore.loadTasks()');
    final raw = _sp.getString(_kTasks);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Task.fromJson).toList();
  }

  Future<void> saveTasks(List<Task> items) async {
    debugPrint('STORE → LocalTaskStore.saveTasks(${items.length})');
    final data = items.map((e) => e.toJson()).toList();
    await _sp.setString(_kTasks, jsonEncode(data));
  }

  // ---- v0 Mutations (legacy) ----
  Future<List<Map<String, dynamic>>> loadMutations() async {
    final raw = _sp.getString(_kMutations);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> saveMutations(List<Map<String, dynamic>> list) async {
    debugPrint('STORE → LocalTaskStore.saveMutations(${list.length})');
    await _sp.setString(_kMutations, jsonEncode(list));
  }

  // ---- v1 WAL Queue ----
  Future<void> saveQueue(List<PendingOp> ops) async {
    debugPrint('STORE → LocalTaskStore.saveQueue(${ops.length})');
    final encoded = jsonEncode(ops.map((e) => e.toJson()).toList());
    await _sp.setString(_kQueueKey, encoded);
  }

  Future<List<PendingOp>> loadQueue() async {
    debugPrint('STORE → LocalTaskStore.loadQueue()');
    final raw = _sp.getString(_kQueueKey);
    if (raw == null || raw.isEmpty) return const [];
    final list = (jsonDecode(raw) as List).cast<Map>();
    return list
        .map((m) => PendingOp.fromJson(m.cast<String, dynamic>()))
        .toList();
  }

  /// Optional one-time migration: convert old `_kMutations` into `_kQueueKey`.
  Future<void> migrateMutationsToQueueIfAny(String Function() newOpId) async {
    final muts = await loadMutations();
    if (muts.isEmpty) return;
    final now = DateTime.now();
    final ops = muts.map((m) {
      // naive mapping; adjust if your old shape differs
      return PendingOp(
        opId: newOpId(),
        kind: PendingKind.values.firstWhere(
          (k) => m['kind'] == describeEnum(k),
          orElse: () => PendingKind.update,
        ),
        id: m['id'] as String,
        payload: (m['payload'] as Map?)?.cast<String, dynamic>(),
        ts: now,
        attempts: 0,
      );
    }).toList();
    await saveQueue(ops);
    await _sp.remove(_kMutations);
    debugPrint('STORE → migrated ${ops.length} mutations → queue');
  }
}
