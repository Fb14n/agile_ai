import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:agile_ai/models/message.dart';
import 'package:agile_ai/models/scrum_ceremony.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/services/storage_service.dart';
import 'package:agile_ai/config/app_config.dart';

class ChatProvider extends ChangeNotifier {
  final SettingsProvider _settingsProvider;
  final StorageService _storageService = StorageService();

  List<Message> _messages = [];
  List<Message> _filteredMessages = [];
  bool _isLoading = false;
  ScrumCeremony? _currentCeremony;
  String _searchQuery = '';

  // ─── Timer ────────────────────────────────────────────────────────────────
  Timer? _timer;
  int _timerSeconds = 0;
  bool _timerRunning = false;
  int _timerMaxSeconds = 0;

  ChatProvider(this._settingsProvider) {
    _loadMessages();
  }

  // ─── Getters ──────────────────────────────────────────────────────────────

  List<Message> get messages =>
      _searchQuery.isEmpty ? _messages : _filteredMessages;
  bool get isLoading => _isLoading;
  ScrumCeremony? get currentCeremony => _currentCeremony;
  String get searchQuery => _searchQuery;

  int get timerSeconds => _timerSeconds;
  int get timerMaxSeconds => _timerMaxSeconds;
  bool get timerRunning => _timerRunning;
  double get timerProgress =>
      _timerMaxSeconds > 0 ? _timerSeconds / _timerMaxSeconds : 0.0;
  bool get timerExpired => _timerMaxSeconds > 0 && _timerSeconds >= _timerMaxSeconds;

  String get formattedTimer {
    final remaining = _timerMaxSeconds - _timerSeconds;
    final min = (remaining ~/ 60).toString().padLeft(2, '0');
    final sec = (remaining % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  List<ActionItem> get currentActionItems =>
      _currentCeremony?.actionItems ?? [];

  // ─── Loading ──────────────────────────────────────────────────────────────

  Future<void> _loadMessages() async {
    _messages = await _storageService.loadMessages();
    notifyListeners();
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredMessages = [];
    } else {
      _filteredMessages = _messages
          .where((m) => m.text.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // ─── Timer ────────────────────────────────────────────────────────────────

  void startTimer(int maxMinutes) {
    _timerSeconds = 0;
    _timerMaxSeconds = maxMinutes * 60;
    _timerRunning = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _timerSeconds++;
      if (_timerSeconds >= _timerMaxSeconds) {
        _timerRunning = false;
        _timer?.cancel();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseResumeTimer() {
    if (_timerRunning) {
      _timerRunning = false;
      _timer?.cancel();
    } else {
      _timerRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _timerSeconds++;
        if (_timerSeconds >= _timerMaxSeconds) {
          _timerRunning = false;
          _timer?.cancel();
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _timerSeconds = 0;
    _timerRunning = false;
    notifyListeners();
  }

  // ─── Action items ─────────────────────────────────────────────────────────

  void addActionItem(String text, {String? assignee}) {
    if (_currentCeremony == null) return;
    final item = ActionItem(text: text, assignee: assignee);
    _currentCeremony = _currentCeremony!.copyWith(
      actionItems: [..._currentCeremony!.actionItems, item],
    );
    notifyListeners();
  }

  void toggleActionItem(String actionItemId) {
    if (_currentCeremony == null) return;
    final items = _currentCeremony!.actionItems.map((a) {
      if (a.id == actionItemId) return a.copyWith(completed: !a.completed);
      return a;
    }).toList();
    _currentCeremony = _currentCeremony!.copyWith(actionItems: items);
    notifyListeners();
  }

  // ─── Send message ─────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _addUserMessage(text);
    await _runAi(() => _settingsProvider.aiService.sendMessage(text));
  }

  Future<void> startCeremony(String ceremonyName) async {
    resetTimer();

    // Read timebox from AppConfig and start timer
    final details = _getCeremonyDetails(ceremonyName);
    final timebox = details?['timeboxMinutes'] as int? ?? 60;

    _currentCeremony = ScrumCeremony(name: ceremonyName, timeboxMinutes: timebox);
    startTimer(timebox);

    // A8: Build context from past ceremonies
    final pastCeremonies = await _storageService.loadCeremonies();
    final pastSummaries = pastCeremonies
        .where((c) => c.summary != null)
        .map((c) => '${c.name}: ${c.summary!}')
        .toList();
    final context = _settingsProvider.aiService
        .buildCeremonyContext(pastSummaries);

    await _runAi(
      () => _settingsProvider.aiService.facilitateCeremony(
        ceremonyName,
        'Team startet neue Zeremonie$context',
      ),
      type: MessageType.ceremony,
      metadata: {'ceremony': ceremonyName},
    );

    // D2: Add contextual Scrum tip
    _runAi(
      () => _settingsProvider.aiService.getScrumTip(ceremonyName),
      type: MessageType.tip,
    );
  }

  Future<void> analyzeSentiment(String text) async {
    await _runAi(
      () => _settingsProvider.aiService.analyzeSentiment(text),
      type: MessageType.sentiment,
    );
  }

  Future<void> generateSprintGoal(List<String> items) async {
    await _runAi(
      () => _settingsProvider.aiService.generateSprintGoal(items),
      type: MessageType.goal,
    );
  }

  Future<void> analyzeRetrospective(List<String> points) async {
    await _runAi(
      () => _settingsProvider.aiService.analyzeRetrospective(points),
      type: MessageType.insight,
    );
  }

  Future<void> estimateStoryPoints(String story) async {
    await _runAi(
      () => _settingsProvider.aiService.estimateStoryPoints(story),
      type: MessageType.goal,
    );
  }

  Future<void> generateAcceptanceCriteria(String story) async {
    await _runAi(
      () => _settingsProvider.aiService.generateAcceptanceCriteria(story),
      type: MessageType.insight,
    );
  }

  Future<void> validateInvest(String story) async {
    await _runAi(
      () => _settingsProvider.aiService.validateInvest(story),
      type: MessageType.insight,
    );
  }

  Future<void> detectImpediments(String standupText) async {
    await _runAi(
      () => _settingsProvider.aiService.detectImpediments(standupText),
      type: MessageType.impediment,
    );
  }

  Future<void> analyzeSprintRisk(List<String> items, int capacity) async {
    await _runAi(
      () => _settingsProvider.aiService.analyzeSprintRisk(items, capacity),
      type: MessageType.risk,
    );
  }

  Future<void> extractActionItems(String meetingText) async {
    await _runAi(
      () => _settingsProvider.aiService.extractActionItems(meetingText),
      type: MessageType.actionItem,
    );
  }

  Future<void> generateDefinitionOfDone(
      String context, List<String> techStack) async {
    await _runAi(
      () => _settingsProvider.aiService.generateDefinitionOfDone(context, techStack),
      type: MessageType.insight,
    );
  }

  Future<void> evaluateScrumMaturity(Map<String, int> answers) async {
    await _runAi(
      () => _settingsProvider.aiService.evaluateScrumMaturity(answers),
      type: MessageType.assessment,
    );
  }

  Future<void> analyzeRetroPatterns() async {
    final ceremonies = await _storageService.loadCeremonies();
    final summaries = ceremonies
        .where((c) =>
            c.name == 'Sprint Retrospective' && c.summary != null)
        .map((c) => c.summary!)
        .toList();
    if (summaries.isEmpty) {
      _messages.add(Message(
        text: 'No retrospective summaries available yet.',
        isUser: false,
      ));
      notifyListeners();
      return;
    }
    await _runAi(
      () => _settingsProvider.aiService.analyzeRetroPatterns(summaries),
      type: MessageType.insight,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _addUserMessage(String text) {
    _messages.add(Message(text: text, isUser: true));
    notifyListeners();
  }

  Future<void> _runAi(
    Future<String> Function() aiCall, {
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await aiCall();
      _messages.add(Message(text: response, isUser: false, type: type, metadata: metadata));
    } catch (e) {
      _messages.add(Message(text: 'Error: $e', isUser: false));
    } finally {
      _isLoading = false;
      await _storageService.saveMessages(_messages);
      notifyListeners();
    }
  }

  Map<String, dynamic>? _getCeremonyDetails(String name) {
    try {
      return AppConfig.ceremonyDetails
          .firstWhere((c) => c['name'] == name || c['nameEn'] == name);
    } catch (_) {
      return null;
    }
  }

  void clearChat() {
    _messages.clear();
    _settingsProvider.aiService.resetChat();
    _storageService.saveMessages(_messages);
    notifyListeners();
  }

  void endCeremony() {
    resetTimer();
    _currentCeremony = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
