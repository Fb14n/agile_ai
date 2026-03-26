import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/screens/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.waving_hand,
      title: 'Willkommen bei AgileAI',
      subtitle: 'Dein intelligenter KI-Scrum-Master. Er führt dich durch alle Scrum-Zeremonien, analysiert die Team-Stimmung und hilft dir, bessere Sprints zu planen.',
      color: Color(0xFF6750A4),
      features: [
        'Daily Standups moderieren',
        'Sprint Planning unterstützen',
        'Retrospektiven auswerten',
        'Team-Stimmung analysieren',
      ],
    ),
    _OnboardingPage(
      icon: Icons.psychology,
      title: 'So funktioniert deine KI',
      subtitle: 'Gemini ist dein virtueller Scrum Master mit speziellen Fähigkeiten:',
      color: Color(0xFF0077B6),
      features: [
        '✓ Strukturierte Fragen stellen',
        '✓ Blocker erkennen und hervorheben',
        '✓ Meeting-Zusammenfassungen erstellen',
        '✓ Sprint-Ziele formulieren',
        '✓ Team-Feedback transparent verarbeiten',
      ],
    ),
    _OnboardingPage(
      icon: Icons.chat_bubble_outline,
      title: 'Zwei Arten zu interagieren',
      subtitle: 'Wähle, wie du mit der KI arbeiten möchtest:',
      color: Color(0xFF2D6A4F),
      features: [
        '🎯 Geführter Modus: Die KI stellt strukturierte Fragen (perfekt für Scrum-Einsteiger)',
        '💬 Freier Chat: Stelle beliebige Fragen oder diskutiere Themen (für erfahrene Nutzer)',
      ],
    ),
    _OnboardingPage(
      icon: Icons.tips_and_updates,
      title: 'Tipps für beste Ergebnisse',
      subtitle: 'So holst du das Beste aus AgileAI heraus:',
      color: Color(0xFFB5179E),
      features: [
        '💡 Sei konkret bei Antworten',
        '📝 Nutze Antwort-Chips für schnelle Eingaben',
        '🎯 Starte Zeremonien über das Kalender-Icon',
        '❓ Tippe auf Info-Icons für Scrum-Erklärungen',
        '📊 Alle Ergebnisse werden automatisch gespeichert',
      ],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await context.read<SettingsProvider>().completeOnboarding();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _currentPage ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? _pages[_currentPage].color
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _finish,
                          child: const Text('Überspringen'),
                        ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _next,
                        icon: Icon(_currentPage < _pages.length - 1
                            ? Icons.arrow_forward
                            : Icons.check),
                        label: Text(_currentPage < _pages.length - 1
                            ? 'Weiter'
                            : 'Los geht\'s'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _pages[_currentPage].color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<String>? features;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.features,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: color),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          if (features != null) ...[
            const SizedBox(height: 24),
            ...features!.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!feature.contains(RegExp(r'[✓🎯💬💡📝❓📊]')))
                    Icon(Icons.check_circle, color: color, size: 20)
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}
