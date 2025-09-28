import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class LocalTaskStore {
  static const _kTasks = 'tasks.v1';
  static const _kMutations = 'mutations.v1'; // List<Map<String, dynamic>>

  Future<List<Task>> loadTasks() async {
    debugPrint('STORE → LocalTaskStore.loadTasks()');
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kTasks);
    if (raw == null) return const [];
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Task.fromJson).toList();
  }

  Future<void> saveTasks(List<Task> items) async {
    debugPrint('STORE → LocalTaskStore.saveTasks(${items.length})');
    final sp = await SharedPreferences.getInstance();
    final data = items.map((e) => e.toJson()).toList();
    await sp.setString(_kTasks, json.encode(data));
  }

  Future<List<Map<String, dynamic>>> loadMutations() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kMutations);
    if (raw == null) return const [];
    return (json.decode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> saveMutations(List<Map<String, dynamic>> list) async {
    debugPrint('STORE → LocalTaskStore.saveMutations(${list.length})');
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMutations, json.encode(list));
  }
}
