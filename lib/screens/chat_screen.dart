import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:agile_ai/providers/chat_provider.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/widgets/message_bubble.dart';
import 'package:agile_ai/widgets/ceremony_selector.dart';
import 'package:agile_ai/widgets/meeting_timer_widget.dart';
import 'package:agile_ai/widgets/action_item_tile.dart';
import 'package:agile_ai/config/app_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;
  bool _showActionItems = false;
  final TextEditingController _searchController = TextEditingController();

  // ─── Speech-to-Text ───────────────────────────────────────────────────────
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _speechListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final platform = defaultTargetPlatform;
    final supported = platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;

    if (!supported) {
      _speechAvailable = false;
      if (mounted) setState(() {});
      return;
    }

    try {
      _speechAvailable = await _speech.initialize();
    } on MissingPluginException {
      _speechAvailable = false;
    } catch (_) {
      _speechAvailable = false;
    }

    if (mounted) setState(() {});
  }

  Future<void> _toggleSpeech() async {
    if (_speechListening) {
      await _speech.stop();
      setState(() => _speechListening = false);
    } else {
      setState(() => _speechListening = true);
      await _speech.listen(
        onResult: (result) {
          _messageController.text = result.recognizedWords;
          _messageController.selection = TextSelection.fromPosition(
            TextPosition(offset: _messageController.text.length),
          );
          if (result.finalResult) {
            setState(() => _speechListening = false);
          }
        },
        localeId: context.read<SettingsProvider>().language == 'de'
            ? 'de_DE'
            : 'en_US',
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isNotEmpty) {
      context.read<ChatProvider>().sendMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCeremonySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => CeremonySelector(
          onCeremonySelected: (ceremony) {
            Navigator.pop(context);
            context.read<ChatProvider>().startCeremony(ceremony);
            _scrollToBottom();
          },
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(8),
          children: [
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Zeremonie starten'),
              onTap: () { Navigator.pop(context); _showCeremonySelector(); },
            ),
            ListTile(
              leading: const Icon(Icons.sentiment_satisfied),
              title: const Text('Sentiment analysieren'),
              onTap: () { Navigator.pop(context); _showSentimentDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Sprint-Ziel generieren'),
              onTap: () { Navigator.pop(context); _showSprintGoalDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('Retrospektive analysieren'),
              onTap: () { Navigator.pop(context); _showRetrospectiveDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Impediments erkennen'),
              onTap: () { Navigator.pop(context); _showImpedimentDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: const Text('Sprint-Risiko analysieren'),
              onTap: () { Navigator.pop(context); _showRiskDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.casino_outlined),
              title: const Text('Story Points schätzen'),
              onTap: () { Navigator.pop(context); _showStoryPointDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Akzeptanzkriterien generieren'),
              onTap: () { Navigator.pop(context); _showAcceptanceCriteriaDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('INVEST validieren'),
              onTap: () { Navigator.pop(context); _showInvestDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Action Items extrahieren'),
              onTap: () { Navigator.pop(context); _showActionItemExtractionDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Definition of Done generieren'),
              onTap: () { Navigator.pop(context); _showDoDDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.assessment_outlined),
              title: const Text('Scrum-Reifegrad bewerten'),
              onTap: () { Navigator.pop(context); _showMaturityDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.pattern),
              title: const Text('Retro-Muster analysieren'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatProvider>().analyzeRetroPatterns();
                _scrollToBottom();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Chat exportieren'),
              onTap: () { Navigator.pop(context); _exportChat(); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Chat löschen', style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(context); context.read<ChatProvider>().clearChat(); },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  void _showSentimentDialog() => _showTextInputDialog(
        title: 'Sentiment analysieren',
        hint: 'Meeting-Text eingeben...',
        actionLabel: 'Analysieren',
        onSubmit: (text) => context.read<ChatProvider>().analyzeSentiment(text),
      );

  void _showSprintGoalDialog() => _showTextInputDialog(
        title: 'Sprint-Ziel generieren',
        hint: 'Backlog Items eingeben (eine pro Zeile)...',
        actionLabel: 'Generieren',
        onSubmit: (text) {
          final items = text.split('\n').where((s) => s.trim().isNotEmpty).toList();
          context.read<ChatProvider>().generateSprintGoal(items);
        },
      );

  void _showRetrospectiveDialog() => _showTextInputDialog(
        title: 'Retrospektive analysieren',
        hint: 'Retro-Punkte eingeben (eine pro Zeile)...',
        actionLabel: 'Analysieren',
        onSubmit: (text) {
          final points = text.split('\n').where((s) => s.trim().isNotEmpty).toList();
          context.read<ChatProvider>().analyzeRetrospective(points);
        },
      );

  void _showImpedimentDialog() => _showTextInputDialog(
        title: 'Impediments erkennen',
        hint: 'Standup-Text oder Meeting-Notizen eingeben...',
        actionLabel: 'Analysieren',
        onSubmit: (text) => context.read<ChatProvider>().detectImpediments(text),
      );

  void _showStoryPointDialog() => _showTextInputDialog(
        title: 'Story Points schätzen',
        hint: 'User Story eingeben...',
        actionLabel: 'Schätzen',
        onSubmit: (text) => context.read<ChatProvider>().estimateStoryPoints(text),
      );

  void _showAcceptanceCriteriaDialog() => _showTextInputDialog(
        title: 'Akzeptanzkriterien generieren',
        hint: 'User Story eingeben...',
        actionLabel: 'Generieren',
        onSubmit: (text) => context.read<ChatProvider>().generateAcceptanceCriteria(text),
      );

  void _showInvestDialog() => _showTextInputDialog(
        title: 'INVEST validieren',
        hint: 'User Story eingeben...',
        actionLabel: 'Validieren',
        onSubmit: (text) => context.read<ChatProvider>().validateInvest(text),
      );

  void _showActionItemExtractionDialog() => _showTextInputDialog(
        title: 'Action Items extrahieren',
        hint: 'Meeting-Protokoll oder Notizen eingeben...',
        actionLabel: 'Extrahieren',
        onSubmit: (text) => context.read<ChatProvider>().extractActionItems(text),
      );

  void _showRiskDialog() => _showTextInputDialog(
        title: 'Sprint-Risiko analysieren',
        hint: 'Geplante Items (eine pro Zeile)...',
        actionLabel: 'Analysieren',
        onSubmit: (text) {
          final items = text.split('\n').where((s) => s.trim().isNotEmpty).toList();
          context.read<ChatProvider>().analyzeSprintRisk(items, 40);
        },
      );

  void _showAddActionItemDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Action Item hinzufügen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Was soll getan werden?',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatProvider>().addActionItem(controller.text.trim());
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  void _showDoDDialog() {
    final contextCtrl = TextEditingController();
    final techCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Definition of Done generieren'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contextCtrl,
              decoration: const InputDecoration(
                  labelText: 'Projektkontext',
                  hintText: 'z.B. Web-App, Flutter-App...',
                  border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: techCtrl,
              decoration: const InputDecoration(
                  labelText: 'Tech-Stack (kommagetrennt)',
                  hintText: 'z.B. Flutter, Firebase, REST',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final stack = techCtrl.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              context.read<ChatProvider>().generateDefinitionOfDone(
                    contextCtrl.text.trim(),
                    stack,
                  );
              _scrollToBottom();
            },
            child: const Text('Generieren'),
          ),
        ],
      ),
    );
  }

  void _showMaturityDialog() {
    // Questions for the Scrum maturity assessment
    final questions = [
      'Daily Standups sind fokussiert und pünktlich',
      'Sprint Planning erzeugt realistische Sprint-Ziele',
      'Retrospektiven führen zu messbaren Verbesserungen',
      'Der Product Backlog ist priorisiert und gepflegt',
      'Das Team liefert vollständige Inkremente (Definition of Done)',
      'Impediments werden schnell erkannt und beseitigt',
    ];
    final answers = <String, int>{
      for (final q in questions) q: 3
    };

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Scrum-Reifegrad bewerten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: questions.map((q) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q, style: const TextStyle(fontSize: 13)),
                  Slider(
                    value: answers[q]!.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '${answers[q]}/5',
                    onChanged: (v) =>
                        setStateDialog(() => answers[q] = v.round()),
                  ),
                  const Divider(),
                ],
              )).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<ChatProvider>().evaluateScrumMaturity(answers);
                _scrollToBottom();
              },
              child: const Text('Auswerten'),
            ),
          ],
        ),
      ),
    );
  }

  /// B1: Export current chat messages as Markdown.
  Future<void> _exportChat() async {
    final messages = context.read<ChatProvider>().messages;
    if (messages.isEmpty) return;
    final buf = StringBuffer();
    buf.writeln('# AgileAI – Chat-Export');
    buf.writeln('Exportiert: ${DateTime.now().toLocal()}');
    buf.writeln();
    for (final msg in messages) {
      final role = msg.isUser ? '**Du**' : '**AgileAI**';
      buf.writeln('$role: ${msg.text}');
      buf.writeln();
    }
    await Share.share(buf.toString(), subject: 'AgileAI Chat-Export');
  }

  void _showTextInputDialog({
    required String title,
    required String hint,
    required String actionLabel,
    required void Function(String) onSubmit,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                onSubmit(controller.text.trim());
                _scrollToBottom();
              }
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppConfig.appName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (chat.currentCeremony != null)
                  Text(
                    chat.currentCeremony!.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
              ],
            ),
            actions: [
              if (chat.currentCeremony != null)
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined),
                  tooltip: 'Zeremonie beenden',
                  onPressed: () => chat.endCeremony(),
                ),
              IconButton(
                icon: Icon(_showSearch ? Icons.search_off : Icons.search),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchController.clear();
                      chat.setSearchQuery('');
                    }
                  });
                },
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: _showOptionsMenu),
            ],
          ),
          body: Column(
            children: [
              // ── Search bar ──────────────────────────────────────────────
              if (_showSearch)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Im Chat suchen...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                chat.setSearchQuery('');
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: chat.setSearchQuery,
                  ),
                ),

              // ── Timer (when a ceremony is active) ───────────────────────────
              if (chat.currentCeremony != null && chat.timerMaxSeconds > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      MeetingTimerWidget(
                        elapsedSeconds: chat.timerSeconds,
                        maxSeconds: chat.timerMaxSeconds,
                        running: chat.timerRunning,
                        onStartPause: chat.pauseResumeTimer,
                        onReset: chat.resetTimer,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.checklist, size: 16),
                        label: Text('Action Items (${chat.currentActionItems.length})'),
                        onPressed: () =>
                            setState(() => _showActionItems = !_showActionItems),
                      ),
                    ],
                  ),
                ),

              // ── Action items panel ──────────────────────────────────────
              if (_showActionItems && chat.currentCeremony != null)
                _buildActionItemsPanel(chat),

              // ── Chat messages ────────────────────────────────────────
              Expanded(
                child: chat.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == chat.messages.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return MessageBubble(message: chat.messages[i]);
                        },
                      ),
              ),

              // ── Input bar ───────────────────────────────────────────
              _buildInputBar(chat),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('AgileAI bereit!',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Stelle eine Frage oder starte eine Zeremonie',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showCeremonySelector,
            icon: const Icon(Icons.event),
            label: const Text('Zeremonie starten'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItemsPanel(ChatProvider chat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.teal[50],
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            title: const Text('Action Items',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: _showAddActionItemDialog,
            ),
          ),
          if (chat.currentActionItems.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Noch keine Action Items',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ...chat.currentActionItems.map((item) => ActionItemTile(
                  item: item,
                  onToggle: () => chat.toggleActionItem(item.id),
                )),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatProvider chat) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.event),
              onPressed: _showCeremonySelector,
              tooltip: 'Zeremonie starten',
            ),
            if (_speechAvailable)
              IconButton(
                icon: Icon(
                  _speechListening ? Icons.mic : Icons.mic_none,
                  color: _speechListening ? Colors.red : null,
                ),
                tooltip: _speechListening
                    ? 'Aufnahme stoppen'
                    : 'Spracheingabe',
                onPressed: _toggleSpeech,
              ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Nachricht eingeben...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                enabled: !chat.isLoading,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: chat.isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
