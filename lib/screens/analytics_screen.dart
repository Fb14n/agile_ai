import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/analytics_provider.dart';
import 'package:agile_ai/providers/backlog_provider.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/models/sprint_data.dart';
import 'package:agile_ai/widgets/charts_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AnalyticsProvider, BacklogProvider, SettingsProvider>(
      builder: (context, analytics, backlog, settings, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Analytics'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Aktualisieren',
                onPressed: analytics.refresh,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: analytics.refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Team Health Score ────────────────────────────────────
                _SectionCard(
                  title: 'Team Health',
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              analytics.healthLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: analytics.teamHealthScore,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              color: _healthColor(analytics.teamHealthScore),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ø Sentiment: ${analytics.averageSentiment.toStringAsFixed(1)} / 10',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          _StatChip(
                            label: 'Zeremonien',
                            value: '${analytics.totalCeremonies}',
                            icon: Icons.event_note,
                          ),
                          const SizedBox(height: 8),
                          _StatChip(
                            label: 'Action Items',
                            value:
                                '${analytics.completedActionItems}/${analytics.totalActionItems}',
                            icon: Icons.checklist,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Action Item Completion Rate ───────────────────────────
                if (analytics.totalActionItems > 0)
                  _SectionCard(
                    title: 'Action Item Abschlussrate',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: analytics.actionItemCompletionRate,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(analytics.actionItemCompletionRate * 100).toStringAsFixed(0)} % abgeschlossen',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // ── Sentiment-Verlauf ─────────────────────────────────────
                _SectionCard(
                  title: 'Sentiment-Verlauf',
                  child: SizedBox(
                    height: 200,
                    child: SentimentChartWidget(
                        data: analytics.sentimentHistory),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Sprint Velocity ───────────────────────────────────────
                _SectionCard(
                  title: 'Sprint Velocity',
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Eintragen'),
                    onPressed: () =>
                        _showVelocityDialog(context, backlog, settings),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: analytics.velocityHistory.isEmpty
                        ? const Center(
                            child: Text('Noch keine Velocity-Daten.\nErstelle Sprints über "Eintragen".'),
                          )
                        : VelocityChartWidget(
                            data: analytics.velocityHistory
                                .map((s) => {
                                      'sprint': s.sprintNumber,
                                      'velocity': s.velocity ?? 0,
                                      'planned': s.plannedPoints,
                                    })
                                .toList(),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Zeremonien-Übersicht ──────────────────────────────────
                if (analytics.ceremonyCounts.isNotEmpty)
                  _SectionCard(
                    title: 'Zeremonien-Übersicht',
                    child: Column(
                      children: analytics.ceremonyCounts.entries
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(e.key)),
                                    Text(
                                      '${e.value}×',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _healthColor(double score) {
    if (score >= 0.75) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }

  void _showVelocityDialog(
    BuildContext context,
    BacklogProvider backlog,
    SettingsProvider settings,
  ) {
    final sprintCtrl = TextEditingController(
        text: settings.currentSprintNumber.toString());
    final velocityCtrl = TextEditingController();
    final plannedCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Velocity eintragen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sprintCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sprint-Nummer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: velocityCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Abgeschlossene Story Points',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plannedCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Geplante Story Points (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              final sprintNum = int.tryParse(sprintCtrl.text);
              final vel = int.tryParse(velocityCtrl.text);
              if (sprintNum != null && vel != null) {
                backlog.saveSprint(SprintData(
                  sprintNumber: sprintNum,
                  velocity: vel,
                  plannedPoints: int.tryParse(plannedCtrl.text),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}

// ─── Hilfs-Widgets ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
