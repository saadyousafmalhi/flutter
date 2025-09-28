// lib/services/task_service_http.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'base_service.dart';
import '../models/task.dart';
import 'task_service.dart';
import '../config/supabase_config.dart';

class TaskServiceHttp extends BaseService implements TaskService {
  TaskServiceHttp({super.client}) : super(base: kSupabaseRestUrl);

  @override
  Map<String, String> get defaultHeaders => {
    ...super.defaultHeaders,
    'apikey': kSupabaseAnonKey,
    'Authorization': 'Bearer $kSupabaseAnonKey',
  };

  @override
  Future<List<Task>> fetch() async {
    debugPrint('HTTP CALL → TaskServiceHttp.fetch()');
    final res = await get(url('/tasks')).timeout(const Duration(seconds: 12));
    throwOnError(res);
    final data = decodeJson<List>(res);
    return data.map((e) => Task.fromJson(e)).toList();
  }

  @override
  Future<Task> toggleDone(Task task) async {
    debugPrint(
      'HTTP CALL → TaskServiceHttp.toggleDone(${task.id}) -> ${task.done}',
    );
    final res = await patch(
      url('/tasks', query: {'id': 'eq.${task.id}'}),
      headers: const {
        'Content-Type': 'application/json; charset=utf-8',
        'Prefer': 'return=representation',
      },
      body: jsonEncode({
        'done': task.done, // send target as-is
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }),
    ).timeout(const Duration(seconds: 12));
    throwOnError(res);

    final rows = decodeJson<List>(res);
    final map =
        (rows.isNotEmpty
                ? rows.first
                : {'id': task.id, 'title': task.title, 'done': task.done})
            as Map<String, dynamic>;
    return Task.fromJson(map);
  }

  // NEW: create task
  @override
  Future<Task> create(String title) async {
    debugPrint('HTTP CALL → TaskServiceHttp.create("$title")');
    final res = await post(
      url('/tasks'),
      headers: const {
        'Content-Type': 'application/json; charset=utf-8',
        'Prefer': 'return=representation', // return inserted row
      },
      body: jsonEncode({
        'title': title,
        'done': false,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }),
    ).timeout(const Duration(seconds: 12));
    throwOnError(res);

    final rows = decodeJson<List>(res);
    final map = rows.first as Map<String, dynamic>;
    return Task.fromJson(map);
  }

  // NEW: delete task
  @override
  Future<void> delete(int id) async {
    debugPrint('HTTP CALL → TaskServiceHttp.delete($id)');
    final res = await deleteReq(
      // <-- use BaseService helper name
      url('/tasks', query: {'id': 'eq.$id'}),
      headers: const {'Prefer': 'return=representation'}, // optional
    ).timeout(const Duration(seconds: 12));
    throwOnError(res);
  }
}
