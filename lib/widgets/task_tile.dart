import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onToggle});

  final Task task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Checkbox(value: task.done, onChanged: (_) => onToggle()),
      title: Text(
        task.title,
        style: task.done
            ? TextStyle(
                color: scheme.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
              )
            : null,
      ),
      trailing: Icon(
        task.done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: task.done ? scheme.primary : scheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: scheme.surface,
    );
  }
}
