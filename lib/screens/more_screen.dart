import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/providers/analytics_provider.dart';
import 'package:agile_ai/screens/settings_screen.dart';
import 'package:agile_ai/screens/team_screen.dart';
import 'package:agile_ai/screens/glossary_screen.dart';
import 'package:agile_ai/screens/planning_poker_screen.dart';

/// "Mehr"-Tab: Links zu Settings, Team, Glossar, Planning Poker.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AnalyticsProvider>(
      builder: (context, settings, analytics, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Mehr')),
          body: ListView(
            children: [
              // ── Team Health Summary ──────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context)
                          .colorScheme
                          .secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analytics.healthLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Ø Sentiment: ${analytics.averageSentiment.toStringAsFixed(1)} | '
                          '${analytics.totalCeremonies} Zeremonien',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Hauptmenü ────────────────────────────────────────────────
              _SectionHeader('Verwaltung'),
              _NavTile(
                icon: Icons.people_outline,
                title: 'Team verwalten',
                subtitle: 'Mitglieder hinzufügen und Rollen festlegen',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TeamScreen())),
              ),
              _NavTile(
                icon: Icons.settings_outlined,
                title: 'Einstellungen',
                subtitle:
                    '${settings.language == "de" ? "Deutsch" : "English"} · ${_shortModelName(settings.aiModel)}',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),

              _SectionHeader('Werkzeuge'),
              _NavTile(
                icon: Icons.casino_outlined,
                title: 'Planning Poker',
                subtitle: 'Moderiertes Schätzen mit KI-Unterstützung',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PlanningPokerScreen())),
              ),
              _NavTile(
                icon: Icons.menu_book_outlined,
                title: 'Scrum-Glossar',
                subtitle: 'Begriffe, Rollen und Zeremonien – offline verfügbar',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const GlossaryScreen())),
              ),
            ],
          ),
        );
      },
    );
  }

  String _shortModelName(String modelId) {
    if (modelId.contains('gemma')) return 'Gemma';
    if (modelId.contains('flash')) return 'Flash';
    return 'Gemini';
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
