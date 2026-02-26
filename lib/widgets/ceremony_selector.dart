import 'package:flutter/material.dart';
import 'package:agile_ai/config/app_config.dart';

class CeremonySelector extends StatelessWidget {
  final Function(String) onCeremonySelected;

  const CeremonySelector({
    super.key,
    required this.onCeremonySelected,
  });

  IconData _getIcon(String ceremony) {
    switch (ceremony) {
      case 'Daily Standup':
        return Icons.groups;
      case 'Sprint Planning':
        return Icons.calendar_month;
      case 'Sprint Review':
        return Icons.preview;
      case 'Sprint Retrospective':
        return Icons.insights;
      case 'Backlog Refinement':
        return Icons.list_alt;
      default:
        return Icons.event;
    }
  }

  String _getDescription(String ceremony) {
    switch (ceremony) {
      case 'Daily Standup':
        return 'Tägliches 15-minütiges Team-Meeting';
      case 'Sprint Planning':
        return 'Planung des kommenden Sprints';
      case 'Sprint Review':
        return 'Präsentation der Sprint-Ergebnisse';
      case 'Sprint Retrospective':
        return 'Reflexion über den letzten Sprint';
      case 'Backlog Refinement':
        return 'Verfeinerung des Product Backlogs';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wähle eine Scrum-Zeremonie',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...AppConfig.ceremonies.map(
            (ceremony) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(_getIcon(ceremony)),
                ),
                title: Text(ceremony),
                subtitle: Text(_getDescription(ceremony)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => onCeremonySelected(ceremony),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
