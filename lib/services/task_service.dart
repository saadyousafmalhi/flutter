import '../models/task.dart';

abstract class TaskService {
  Future<List<Task>> fetch();
  Future<Task> toggleDone(Task t);

  Future<Task> create(String title);
  Future<void> delete(int id);
}
