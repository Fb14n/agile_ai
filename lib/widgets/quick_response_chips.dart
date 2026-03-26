import 'package:flutter/material.dart';

class QuickResponseChips extends StatelessWidget {
  final Function(String) onChipSelected;
  final List<String> suggestions;

  const QuickResponseChips({
    super.key,
    required this.onChipSelected,
    this.suggestions = const [],
  });

  // Default common responses for Daily Standup
  static const List<String> dailyStandupDefaults = [
    'Keine Blocker',
    'Code Review',
    'Bug Fixing',
    'Feature Development',
    'Testing',
    'Dokumentation',
    'Meeting',
    'Noch in Arbeit',
  ];

  // Common blocker types
  static const List<String> blockerDefaults = [
    'Technisches Problem',
    'Wartet auf Review',
    'Externe Abhängigkeit',
    'Unklare Anforderungen',
    'Ressourcen fehlen',
  ];

  // Sprint Planning
  static const List<String> sprintPlanningDefaults = [
    'Story fertig besprochen',
    'Weitere Klärung nötig',
    'Kann starten',
    'Abhängigkeiten klären',
  ];

  // Retrospective
  static const List<String> retroDefaults = [
    'Gut gelaufen',
    'Verbesserungspotenzial',
    'Problem aufgetreten',
    'Weitermachen',
    'Ändern',
    'Mehr davon',
  ];

  @override
  Widget build(BuildContext context) {
    final chips = suggestions.isNotEmpty ? suggestions : dailyStandupDefaults;
    
    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips.map((suggestion) {
          return ActionChip(
            label: Text(suggestion),
            avatar: Icon(
              _getIconForSuggestion(suggestion),
              size: 18,
            ),
            onPressed: () => onChipSelected(suggestion),
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForSuggestion(String suggestion) {
    if (suggestion.toLowerCase().contains('blocker') || 
        suggestion.toLowerCase().contains('problem')) {
      return Icons.block;
    }
    if (suggestion.toLowerCase().contains('review')) {
      return Icons.rate_review;
    }
    if (suggestion.toLowerCase().contains('bug') || 
        suggestion.toLowerCase().contains('fix')) {
      return Icons.bug_report;
    }
    if (suggestion.toLowerCase().contains('feature') || 
        suggestion.toLowerCase().contains('development')) {
      return Icons.code;
    }
    if (suggestion.toLowerCase().contains('test')) {
      return Icons.science;
    }
    if (suggestion.toLowerCase().contains('doku') || 
        suggestion.toLowerCase().contains('dokumentation')) {
      return Icons.description;
    }
    if (suggestion.toLowerCase().contains('meeting')) {
      return Icons.groups;
    }
    if (suggestion.toLowerCase().contains('gut') || 
        suggestion.toLowerCase().contains('fertig')) {
      return Icons.check_circle_outline;
    }
    if (suggestion.toLowerCase().contains('wart')) {
      return Icons.hourglass_empty;
    }
    if (suggestion.toLowerCase().contains('unklar')) {
      return Icons.help_outline;
    }
    return Icons.chat_bubble_outline;
  }
}
