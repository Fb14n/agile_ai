import 'package:flutter/material.dart';
import 'package:agile_ai/config/app_config.dart';
import 'package:agile_ai/widgets/scrum_glossary.dart';

class CeremonySelector extends StatelessWidget {
  final Function(String) onCeremonySelected;

  const CeremonySelector({super.key, required this.onCeremonySelected});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scrum-Zeremonie starten',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Timebox-Timer startet automatisch',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.book),
                  onPressed: () => ScrumTermTooltip.showGlossary(context),
                  tooltip: 'Scrum Glossar',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...AppConfig.ceremonyDetails.map(
              (details) {
                final ceremonyName = details['name'] as String;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_getIcon(ceremonyName)),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(ceremonyName)),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 18),
                          onPressed: () {
                            final term = ScrumGlossary.getTerm(ceremonyName);
                            if (term != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  icon: Icon(term.icon, color: term.color, size: 48),
                                  title: Text(term.name),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        term.shortDescription,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: term.color,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(term.fullDescription),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Verstanden'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          tooltip: 'Was ist $ceremonyName?',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(details['description'] as String,
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              '${details['timeboxMinutes']} Min.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    isThreeLine: true,
                    onTap: () => onCeremonySelected(ceremonyName),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
