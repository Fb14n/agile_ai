import 'package:flutter/material.dart';
import 'package:agile_ai/models/scrum_ceremony.dart';

class ActionItemTile extends StatelessWidget {
  final ActionItem item;
  final VoidCallback onToggle;

  const ActionItemTile({
    super.key,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Checkbox(
        value: item.completed,
        onChanged: (_) => onToggle(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      title: Text(
        item.text,
        style: TextStyle(
          decoration: item.completed ? TextDecoration.lineThrough : null,
          color: item.completed ? Colors.grey : null,
        ),
      ),
      subtitle: item.assignee != null || item.dueDate != null
          ? Row(
              children: [
                if (item.assignee != null) ...[
                  const Icon(Icons.person_outline, size: 12),
                  const SizedBox(width: 2),
                  Text(item.assignee!, style: const TextStyle(fontSize: 11)),
                ],
                if (item.dueDate != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '${item.dueDate!.day}.${item.dueDate!.month}.',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ],
            )
          : null,
    );
  }
}
