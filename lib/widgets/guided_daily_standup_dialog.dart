import 'package:flutter/material.dart';
import 'package:agile_ai/widgets/quick_response_chips.dart';

class GuidedDailyStandupDialog extends StatefulWidget {
  final Function(Map<String, String>) onComplete;

  const GuidedDailyStandupDialog({
    super.key,
    required this.onComplete,
  });

  @override
  State<GuidedDailyStandupDialog> createState() => _GuidedDailyStandupDialogState();
}

class _GuidedDailyStandupDialogState extends State<GuidedDailyStandupDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  final TextEditingController _yesterdayController = TextEditingController();
  final TextEditingController _todayController = TextEditingController();
  final TextEditingController _blockersController = TextEditingController();

  final Map<String, String> _responses = {
    'yesterday': '',
    'today': '',
    'blockers': '',
  };

  @override
  void dispose() {
    _pageController.dispose();
    _yesterdayController.dispose();
    _todayController.dispose();
    _blockersController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Save current step response
    switch (_currentStep) {
      case 0:
        _responses['yesterday'] = _yesterdayController.text;
        break;
      case 1:
        _responses['today'] = _todayController.text;
        break;
      case 2:
        _responses['blockers'] = _blockersController.text;
        break;
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      // Complete and close
      widget.onComplete(_responses);
      Navigator.of(context).pop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  void _addChipResponse(String text, TextEditingController controller) {
    if (controller.text.isEmpty) {
      controller.text = text;
    } else {
      controller.text = '${controller.text}, $text';
    }
    setState(() {});
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _yesterdayController.text.trim().isNotEmpty;
      case 1:
        return _todayController.text.trim().isNotEmpty;
      case 2:
        return true; // Blocker sind optional
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.groups,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Standup',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Schritt ${_currentStep + 1} von 3',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),

            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: Colors.grey[200],
            ),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepPage(
                    icon: Icons.history,
                    iconColor: Colors.blue,
                    question: 'Was hast du gestern gemacht?',
                    hint: 'Beschreibe kurz deine gestrigen Aufgaben...',
                    controller: _yesterdayController,
                    suggestions: const [
                      'Code Review',
                      'Bug Fixing',
                      'Feature Development',
                      'Testing',
                      'Dokumentation',
                      'Meeting',
                    ],
                  ),
                  _buildStepPage(
                    icon: Icons.today,
                    iconColor: Colors.green,
                    question: 'Was planst du heute?',
                    hint: 'Beschreibe deine heutigen Aufgaben...',
                    controller: _todayController,
                    suggestions: const [
                      'Feature Development',
                      'Code Review',
                      'Testing',
                      'Bug Fixing',
                      'Refactoring',
                      'Dokumentation',
                    ],
                  ),
                  _buildStepPage(
                    icon: Icons.block,
                    iconColor: Colors.red,
                    question: 'Gibt es Blocker oder Impediments?',
                    hint: 'Beschreibe was dich blockiert (oder lasse es leer)...',
                    controller: _blockersController,
                    suggestions: const [
                      'Keine Blocker',
                      'Wartet auf Review',
                      'Technisches Problem',
                      'Externe Abhängigkeit',
                      'Unklare Anforderungen',
                      'Ressourcen fehlen',
                    ],
                    isOptional: true,
                  ),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Zurück'),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  FilledButton.icon(
                    onPressed: _canProceed() ? _nextStep : null,
                    icon: Icon(_currentStep < 2 ? Icons.arrow_forward : Icons.check),
                    label: Text(_currentStep < 2 ? 'Weiter' : 'Fertig'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPage({
    required IconData icon,
    required Color iconColor,
    required String question,
    required String hint,
    required TextEditingController controller,
    required List<String> suggestions,
    bool isOptional = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon & Question
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (isOptional)
                      Text(
                        'Optional',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick response chips
          Text(
            'Schnellantworten:',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          QuickResponseChips(
            suggestions: suggestions,
            onChipSelected: (text) => _addChipResponse(text, controller),
          ),

          const SizedBox(height: 16),

          // Text input
          Text(
            'Oder tippe deine Antwort:',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Helper text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tipp: Verwende die Chips oben für häufige Antworten oder tippe eigene Details.',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
