import 'package:flutter/material.dart';
import 'package:agile_ai/models/backlog_item.dart';

class BacklogItemCard extends StatelessWidget {
  final BacklogItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEstimate;
  final VoidCallback? onAcceptanceCriteria;
  final VoidCallback? onInvest;
  final VoidCallback? onAssignSprint;

  const BacklogItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
    this.onEstimate,
    this.onAcceptanceCriteria,
    this.onInvest,
    this.onAssignSprint,
  });

  Color _statusColor(BacklogStatus status) {
    switch (status) {
      case BacklogStatus.todo:
        return Colors.grey;
      case BacklogStatus.inProgress:
        return Colors.blue;
      case BacklogStatus.done:
        return Colors.green;
      case BacklogStatus.removed:
        return Colors.red;
    }
  }

  String _statusLabel(BacklogStatus status) {
    switch (status) {
      case BacklogStatus.todo:
        return 'To Do';
      case BacklogStatus.inProgress:
        return 'In Progress';
      case BacklogStatus.done:
        return 'Done';
      case BacklogStatus.removed:
        return 'Entfernt';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (item.storyPoints != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.storyPoints} SP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor(item.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel(item.status),
                      style: TextStyle(
                        fontSize: 10,
                        color: _statusColor(item.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.acceptanceCriteria.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${item.acceptanceCriteria.length} Akzeptanzkriterien',
                  style: const TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEstimate != null)
                    _ActionButton(
                      icon: Icons.casino_outlined,
                      label: 'Schätzen',
                      onTap: onEstimate!,
                    ),
                  if (onAcceptanceCriteria != null)
                    _ActionButton(
                      icon: Icons.checklist,
                      label: 'Kriterien',
                      onTap: onAcceptanceCriteria!,
                    ),
                  if (onInvest != null)
                    _ActionButton(
                      icon: Icons.verified_outlined,
                      label: 'INVEST',
                      onTap: onInvest!,
                    ),
                  if (onAssignSprint != null)
                    _ActionButton(
                      icon: item.sprintNumber != null
                          ? Icons.event_available
                          : Icons.add_to_queue_outlined,
                      label: item.sprintNumber != null
                          ? 'S${item.sprintNumber}'
                          : 'Sprint',
                      onTap: onAssignSprint!,
                    ),
                  if (onDelete != null)
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: '',
                      onTap: onDelete!,
                      color: Colors.red,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: color),
      label: label.isNotEmpty ? Text(label, style: const TextStyle(fontSize: 11)) : const SizedBox(),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        foregroundColor: color ?? Theme.of(context).colorScheme.primary,
        minimumSize: const Size(0, 0),
      ),
    );
  }
}
