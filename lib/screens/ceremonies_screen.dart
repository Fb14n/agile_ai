import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:agile_ai/providers/analytics_provider.dart';
import 'package:agile_ai/models/scrum_ceremony.dart';

/// Übersicht aller vergangenen Scrum-Zeremonien mit Filter und Detailansicht.
class CeremoniesScreen extends StatefulWidget {
  const CeremoniesScreen({super.key});

  @override
  State<CeremoniesScreen> createState() => _CeremoniesScreenState();
}

class _CeremoniesScreenState extends State<CeremoniesScreen> {
  String _filterType = 'Alle';

  static const List<String> _filterOptions = [
    'Alle',
    'Daily Standup',
    'Sprint Planning',
    'Sprint Review',
    'Sprint Retrospective',
    'Backlog Refinement',
  ];

  List<ScrumCeremony> _filteredCeremonies(List<ScrumCeremony> all) {
    if (_filterType == 'Alle') return all.reversed.toList();
    return all.where((c) => c.name == _filterType).toList().reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Zeremonien'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  children: _filterOptions
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f),
                              selected: _filterType == f,
                              onSelected: (_) =>
                                  setState(() => _filterType = f),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          body: Builder(
            builder: (context) {
              final ceremonies = _filteredCeremonies(analytics.allCeremonies);
              if (ceremonies.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Noch keine Zeremonien',
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Text(
                        'Starte eine Zeremonie im Chat-Tab',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: ceremonies.length,
                itemBuilder: (_, i) =>
                    _CeremonyCard(ceremony: ceremonies[i]),
              );
            },
          ),
        );
      },
    );
  }
}

class _CeremonyCard extends StatelessWidget {
  final ScrumCeremony ceremony;

  const _CeremonyCard({required this.ceremony});

  IconData _icon(String name) {
    switch (name) {
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

  String _duration() {
    if (ceremony.endTime == null) return '';
    final diff = ceremony.endTime!.difference(ceremony.startTime);
    final min = diff.inMinutes;
    return '${min} Min.';
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_icon(ceremony.name),
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ceremony.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text(
                      fmt.format(ceremony.startTime),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (ceremony.actionItems.isNotEmpty)
                    _badge(
                        context,
                        '${ceremony.actionItems.length} AI',
                        Colors.teal),
                  if (_duration().isNotEmpty)
                    Text(_duration(),
                        style: const TextStyle(fontSize: 11)),
                  if (ceremony.sentiment != null)
                    _badge(
                        context,
                        '😊 ${(ceremony.sentiment!['score'] as num).toStringAsFixed(1)}',
                        Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => _CeremonyDetailSheet(
            ceremony: ceremony, scrollController: ctrl),
      ),
    );
  }
}

class _CeremonyDetailSheet extends StatelessWidget {
  final ScrumCeremony ceremony;
  final ScrollController scrollController;

  const _CeremonyDetailSheet({
    required this.ceremony,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text(ceremony.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // Metadaten
          _DetailRow('Datum', fmt.format(ceremony.startTime)),
          if (ceremony.endTime != null)
            _DetailRow('Dauer',
                '${ceremony.endTime!.difference(ceremony.startTime).inMinutes} Minuten'),
          if (ceremony.sprintNumber != null)
            _DetailRow('Sprint', 'Sprint ${ceremony.sprintNumber}'),
          if (ceremony.participants.isNotEmpty)
            _DetailRow('Teilnehmer', ceremony.participants.join(', ')),
          if (ceremony.sentiment?['score'] != null)
            _DetailRow('Sentiment',
                '${(ceremony.sentiment!['score'] as num).toStringAsFixed(1)} / 10'),
          const SizedBox(height: 16),

          // KI-Zusammenfassung
          if (ceremony.summary != null) ...[
            Text('Zusammenfassung',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(ceremony.summary!),
            const SizedBox(height: 16),
          ],

          // Notizen
          if (ceremony.notes.isNotEmpty) ...[
            Text('Notizen',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...ceremony.notes.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $n'),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Items
          if (ceremony.actionItems.isNotEmpty) ...[
            Text('Action Items',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...ceremony.actionItems.map(
              (a) => ListTile(
                dense: true,
                leading: Icon(
                  a.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: a.completed ? Colors.green : Colors.grey,
                  size: 20,
                ),
                title: Text(a.text,
                    style: TextStyle(
                        decoration: a.completed
                            ? TextDecoration.lineThrough
                            : null)),
                subtitle: a.assignee != null ? Text(a.assignee!) : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
