import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/providers/team_provider.dart';
import 'package:agile_ai/config/app_config.dart';

/// Planning Poker screen: AI-supported estimation workflow.
///
/// Flow:
/// 1. Enter user story
/// 2. AI provides initial estimate and reasoning
/// 3. Each team member enters their estimate
/// 4. On divergence: AI moderates the discussion
/// 5. Finalize the estimate
class PlanningPokerScreen extends StatefulWidget {
  const PlanningPokerScreen({super.key});

  @override
  State<PlanningPokerScreen> createState() => _PlanningPokerScreenState();
}

class _PlanningPokerScreenState extends State<PlanningPokerScreen> {
  final _storyCtrl = TextEditingController();
  final Map<String, int?> _votes = {}; // memberName → storyPoints

  String? _aiSuggestion;
  String? _aiDiscussion;
  int? _finalEstimate;
  bool _loading = false;
  _Phase _phase = _Phase.input;

  @override
  void dispose() {
    _storyCtrl.dispose();
    super.dispose();
  }

  Future<void> _getAiEstimate() async {
    if (_storyCtrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _phase = _Phase.aiEstimate;
    });
    try {
      final ai = context.read<SettingsProvider>().aiService;
      final result =
          await ai.estimateStoryPoints(_storyCtrl.text.trim());
      setState(() => _aiSuggestion = result);
      // Initialize team votes
      final members = context.read<TeamProvider>().memberNames;
      for (final m in members) {
        _votes[m] = null;
      }
      if (members.isEmpty) _votes['Ich'] = null;
      _phase = _Phase.voting;
    } catch (e) {
      setState(() => _aiSuggestion = 'Fehler: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _getAiModeration() async {
    setState(() {
      _loading = true;
      _phase = _Phase.discussion;
    });
    try {
      final ai = context.read<SettingsProvider>().aiService;
      final voteText = _votes.entries
          .where((e) => e.value != null)
          .map((e) => '${e.key}: ${e.value} SP')
          .join(', ');
      final prompt = 'User Story: "${_storyCtrl.text.trim()}"\n'
          'Team-Schätzungen: $voteText\n'
          'KI-Vorschlag: $_aiSuggestion\n\n'
          'Moderiere die Diskussion: Erkläre die Abweichungen und '
          'empfehle eine finale Schätzung mit Begründung.';
      final result = await ai.sendMessage(prompt);
      setState(() => _aiDiscussion = result);
    } catch (e) {
      setState(() => _aiDiscussion = 'Fehler: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _reset() {
    setState(() {
      _storyCtrl.clear();
      _votes.clear();
      _aiSuggestion = null;
      _aiDiscussion = null;
      _finalEstimate = null;
      _phase = _Phase.input;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning Poker'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Neu starten',
              onPressed: _reset),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Step 1: User story ────────────────────────────────────
            _StepCard(
              step: '1',
              title: 'User Story',
              active: _phase == _Phase.input ||
                  _phase == _Phase.aiEstimate,
              child: Column(
                children: [
                  TextField(
                    controller: _storyCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          'Als [Nutzer] möchte ich [Funktion], damit [Nutzen]...',
                      border: OutlineInputBorder(),
                    ),
                    enabled: _phase == _Phase.input,
                  ),
                  if (_phase == _Phase.input) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _getAiEstimate,
                        icon: const Icon(Icons.smart_toy_outlined),
                        label: const Text('KI-Schätzung anfordern'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Step 2: AI estimate ──────────────────────────────────
            if (_phase.index >= _Phase.aiEstimate.index)
              _StepCard(
                step: '2',
                title: 'KI-Einschätzung',
                active: _phase == _Phase.aiEstimate,
                child: _loading && _aiSuggestion == null
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Text(_aiSuggestion ?? ''),
              ),

            // ── Step 3: Team votes ────────────────────────────────────
            if (_phase.index >= _Phase.voting.index) ...[
              const SizedBox(height: 12),
              _StepCard(
                step: '3',
                title: 'Team-Schätzungen',
                active: _phase == _Phase.voting,
                child: Column(
                  children: [
                    ..._votes.keys.map((member) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(member,
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.w500))),
                              Wrap(
                                spacing: 4,
                                children: AppConfig.fibonacciPoints
                                    .map((sp) => ChoiceChip(
                                          label: Text('$sp'),
                                          selected:
                                              _votes[member] == sp,
                                          onSelected:
                                              _phase == _Phase.voting
                                                  ? (sel) => setState(
                                                      () => _votes[
                                                              member] =
                                                          sel ? sp : null)
                                                  : null,
                                          padding: EdgeInsets.zero,
                                          labelPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 4),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 12),
                    if (_votes.values
                        .any((v) => v != null)) ...[
                      // Check for consensus
                      if (_allAgreed())
                        _ConsensusWidget(
                            points: _votes.values.first!,
                            onAccept: () => setState(() {
                                  _finalEstimate =
                                      _votes.values.first;
                                  _phase = _Phase.done;
                                }))
                      else
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed:
                                _loading ? null : _getAiModeration,
                            icon: const Icon(Icons.forum_outlined),
                            label: const Text(
                                'KI-Moderation anfordern'),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],

            // ── Step 4: Discussion ────────────────────────────────────
            if (_phase.index >= _Phase.discussion.index) ...[
              const SizedBox(height: 12),
              _StepCard(
                step: '4',
                title: 'KI-Moderation',
                active: _phase == _Phase.discussion,
                child: _loading && _aiDiscussion == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Text(_aiDiscussion ?? ''),
                          if (_aiDiscussion != null) ...[
                            const SizedBox(height: 12),
                            Text('Finale Schätzung festlegen:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: AppConfig.fibonacciPoints
                                  .map((sp) => ChoiceChip(
                                        label: Text('$sp'),
                                        selected:
                                            _finalEstimate == sp,
                                        onSelected: (sel) =>
                                            setState(() =>
                                                _finalEstimate =
                                                    sel ? sp : null),
                                      ))
                                  .toList(),
                            ),
                            if (_finalEstimate != null) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => setState(
                                      () => _phase = _Phase.done),
                                  child: const Text(
                                      'Schätzung bestätigen'),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
              ),
            ],

            // ── Step 5: Result ──────────────────────────────────────
            if (_phase == _Phase.done) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.green.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Finale Schätzung',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '$_finalEstimate Story Points',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                          onPressed: _reset, child: const Text('Neu')),
                    ],
                  ),
                ),
              ),
            ],

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  bool _allAgreed() {
    final vals = _votes.values.whereType<int>().toList();
    if (vals.length < _votes.length) return false; // not all votes in yet
    return vals.every((v) => v == vals.first);
  }
}

enum _Phase { input, aiEstimate, voting, discussion, done }

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final Widget child;
  final bool active;

  const _StepCard({
    required this.step,
    required this.title,
    required this.child,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: active
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                      active ? Theme.of(context).colorScheme.primary : Colors.grey,
                  child: Text(step,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white)),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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

class _ConsensusWidget extends StatelessWidget {
  final int points;
  final VoidCallback onAccept;

  const _ConsensusWidget({required this.points, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.thumb_up, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '✅ Konsens: alle schätzen $points Story Points',
              style:
                  const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: onAccept,
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
  }
}
