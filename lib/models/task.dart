class Task {
  final int id;
  final String title;
  final bool done;

  const Task({required this.id, required this.title, required this.done});

  Task copyWith({int? id, String? title, bool? done}) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    done: done ?? this.done,
  );

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'] as int,
    title: j['title'] as String,
    done: (j['done'] as bool?) ?? (j['completed'] as bool? ?? false),
  );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};
}
