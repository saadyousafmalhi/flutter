class TaskMutation {
  final int id;
  final bool done;
  final int clock; // logical clock per task

  const TaskMutation({
    required this.id,
    required this.done,
    required this.clock,
  });

  String get key => '$id:$clock';

  Map<String, dynamic> toJson() => {'id': id, 'done': done, 'clock': clock};

  factory TaskMutation.fromJson(Map<String, dynamic> j) => TaskMutation(
    id: j['id'] as int,
    done: j['done'] as bool,
    clock: j['clock'] as int,
  );
}
