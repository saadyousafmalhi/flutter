// lib/services/task_service_http.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'base_service.dart';
import '../models/task.dart';
import 'task_service.dart';

class TaskServiceHttp extends BaseService implements TaskService {
  TaskServiceHttp({http.Client? client}) : super(client: client);

  @override
  Future<List<Task>> fetch() async {
    debugPrint('HTTP CALL → TaskServiceHttp.fetch()');
    final res = await get(url('/todos')).timeout(const Duration(seconds: 12));
    throwOnError(res);

    final data = decodeJson<List>(res);
    return data.map((e) => Task.fromJson(e)).toList();
  }

  @override
  Future<Task> toggleDone(Task task) async {
    final updated = task.copyWith(done: !task.done);
    debugPrint('HTTP CALL → TaskServiceHttp.toggleDone(${task.id})');

    final res = await http
        .patch(
          url('/todos/${task.id}'),
          headers: const {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({'completed': updated.done}),
        )
        .timeout(const Duration(seconds: 12));
    throwOnError(res);

    final map = decodeJson<Map<String, dynamic>>(res);
    return Task.fromJson(map);
  }
}
