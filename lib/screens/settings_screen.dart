import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/config/app_config.dart';

/// Einstellungs-Screen: Sprache, KI-Modell, Persona, Sprint, Daten.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Einstellungen')),
          body: ListView(
            children: [
              // ── Sprache ─────────────────────────────────────────────────
              _SectionHeader('Sprache & Stil'),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Sprache'),
                subtitle: Text(
                    settings.language == 'de' ? 'Deutsch' : 'English'),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'de', label: Text('DE')),
                    ButtonSegment(value: 'en', label: Text('EN')),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (sel) =>
                      settings.setLanguage(sel.first),
                ),
              ),

              // ── KI-Modell ───────────────────────────────────────────────
              _SectionHeader('KI-Konfiguration'),
              ListTile(
                leading: const Icon(Icons.smart_toy_outlined),
                title: const Text('KI-Modell'),
                subtitle: Text(_modelLabel(settings.aiModel)),
                onTap: () => _showModelPicker(context, settings),
              ),

              // ── Persona ─────────────────────────────────────────────────
              ListTile(
                leading: const Icon(Icons.psychology_outlined),
                title: const Text('Kommunikationsstil (Persona)'),
                subtitle: Text(_personaLabel(settings.personaStyle)),
                onTap: () => _showPersonaPicker(context, settings),
              ),

              // ── Sprint ──────────────────────────────────────────────────
              _SectionHeader('Sprint'),
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Aktueller Sprint'),
                subtitle: Text('Sprint ${settings.currentSprintNumber}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: settings.currentSprintNumber > 1
                          ? () => settings.setSprintNumber(
                              settings.currentSprintNumber - 1)
                          : null,
                    ),
                    Text(
                      '${settings.currentSprintNumber}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => settings.setSprintNumber(
                          settings.currentSprintNumber + 1),
                    ),
                  ],
                ),
              ),

              // ── Daten ───────────────────────────────────────────────────
              _SectionHeader('Daten'),
              ListTile(
                leading:
                    const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Alle Daten zurücksetzen',
                    style: TextStyle(color: Colors.red)),
                subtitle: const Text(
                    'Löscht Chat-Verlauf, Zeremonien, Backlog und Team'),
                onTap: () => _confirmReset(context, settings),
              ),

              // ── Info ─────────────────────────────────────────────────────
              _SectionHeader('Über die App'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                trailing: Text(AppConfig.appVersion,
                    style: const TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  String _modelLabel(String modelId) {
    final match = AppConfig.availableModels
        .where((m) => m['id'] == modelId)
        .firstOrNull;
    return match?['label'] ?? modelId;
  }

  String _personaLabel(String personaId) {
    final match = AppConfig.personaStyles
        .where((p) => p['id'] == personaId)
        .firstOrNull;
    return match?['label'] ?? personaId;
  }

  void _showModelPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('KI-Modell wählen',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...AppConfig.availableModels.map(
            (m) => RadioListTile<String>(
              value: m['id']!,
              groupValue: settings.aiModel,
              title: Text(m['label']!),
              onChanged: (val) {
                if (val != null) settings.setAiModel(val);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showPersonaPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Kommunikationsstil wählen',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...AppConfig.personaStyles.map(
            (p) => RadioListTile<String>(
              value: p['id']!,
              groupValue: settings.personaStyle,
              title: Text(p['label']!),
              subtitle: Text(p['desc']!),
              onChanged: (val) {
                if (val != null) settings.setPersonaStyle(val);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alle Daten löschen?'),
        content: const Text(
            'Diese Aktion kann nicht rückgängig gemacht werden. '
            'Chat-Verlauf, Zeremonien, Backlog und Team werden gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              settings.resetAllData();
              Navigator.pop(context);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
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
