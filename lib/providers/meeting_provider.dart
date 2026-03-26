import 'package:flutter/foundation.dart';
import 'package:agile_ai/models/meeting.dart';
import 'package:agile_ai/models/meeting_message.dart';
import 'package:agile_ai/services/meeting_service.dart';
import 'package:agile_ai/services/project_service.dart';

/// Provider for meeting-specific chat and state management
class MeetingProvider with ChangeNotifier {
  final MeetingService _meetingService;
  final ProjectService _projectService;

  MeetingProvider(this._meetingService, this._projectService);

  // Current state
  Meeting? _currentMeeting;
  List<MeetingMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  String _projectContext = '';

  // Getters
  Meeting? get currentMeeting => _currentMeeting;
  List<MeetingMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMeeting => _currentMeeting != null;

  // ─── Meeting Management ────────────────────────────────────────────────────

  Future<void> startMeeting({
    required String projectId,
    String? sprintId,
    required MeetingType type,
    required List<String> participants,
  }) async {
    _setLoading(true);
    try {
      // Create new meeting
      final meeting = Meeting(
        projectId: projectId,
        sprintId: sprintId,
        type: type,
        participants: participants,
      );
      
      _currentMeeting = await _meetingService.createMeeting(meeting);
      
      // Load project context for AI
      _projectContext = await _projectService.buildAIContext(projectId);
      
      // Load existing messages (should be empty for new meeting)
      _messages = await _meetingService.getMessages(_currentMeeting!.id);
      
      // Send welcome message
      await _sendWelcomeMessage(type);
      
      _error = null;
    } catch (e) {
      _error = 'Failed to start meeting: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMeeting(String meetingId) async {
    _setLoading(true);
    try {
      _currentMeeting = await _meetingService.getMeeting(meetingId);
      if (_currentMeeting != null) {
        _messages = await _meetingService.getMessages(meetingId);
        _projectContext = await _projectService.buildAIContext(_currentMeeting!.projectId);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load meeting: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _sendWelcomeMessage(MeetingType type) async {
    if (_currentMeeting == null) return;

    String welcomeText;
    switch (type) {
      case MeetingType.daily:
        welcomeText = 'Willkommen zum Daily Standup! ☀️\n\nTeilt eure Updates:\n- Was wurde gestern erreicht?\n- Was ist heute geplant?\n- Gibt es Blocker?';
        break;
      case MeetingType.planning:
        welcomeText = 'Willkommen zum Sprint Planning! 🎯\n\nLasst uns den nächsten Sprint planen:\n1. Sprint Goal definieren\n2. User Stories auswählen\n3. Tasks aufteilen';
        break;
      case MeetingType.review:
        welcomeText = 'Willkommen zur Sprint Review! 🎉\n\nZeigt, was ihr erreicht habt:\n- Welche Stories sind Done?\n- Was funktioniert?\n- Feedback sammeln';
        break;
      case MeetingType.retrospective:
        welcomeText = 'Willkommen zur Retrospektive! 🔄\n\nReflektiert über den Sprint:\n- Was lief gut?\n- Was können wir verbessern?\n- Action Items festlegen';
        break;
      case MeetingType.refinement:
        welcomeText = 'Willkommen zum Backlog Refinement! 📝\n\nVerfeinern wir den Backlog:\n- Stories reviewen\n- Akzeptanzkriterien klären\n- Story Points schätzen';
        break;
    }

    await _meetingService.sendAssistantMessage(
      _currentMeeting!.id,
      welcomeText,
      type: MessageType.assistant,
    );

    _messages = await _meetingService.getMessages(_currentMeeting!.id);
    notifyListeners();
  }

  // ─── Message Management ────────────────────────────────────────────────────

  Future<void> sendMessage(String content) async {
    if (_currentMeeting == null || content.trim().isEmpty) return;

    _setLoading(true);
    try {
      // Send to AI and save both messages
      await _meetingService.sendToAI(
        meetingId: _currentMeeting!.id,
        userMessage: content,
        projectContext: _projectContext,
      );

      // Reload messages
      _messages = await _meetingService.getMessages(_currentMeeting!.id);
      _error = null;
    } catch (e) {
      _error = 'Failed to send message: $e';
      // Add error message to UI
      await _meetingService.sendAssistantMessage(
        _currentMeeting!.id,
        'Entschuldigung, es gab einen Fehler beim Senden der Nachricht. Bitte versuche es erneut.',
        type: MessageType.system,
      );
      _messages = await _meetingService.getMessages(_currentMeeting!.id);
    } finally {
      _setLoading(false);
    }
  }

  // ─── Meeting Completion ────────────────────────────────────────────────────

  Future<void> completeMeeting() async {
    if (_currentMeeting == null) return;

    _setLoading(true);
    try {
      // Analyze sentiment
      final sentiment = await _meetingService.analyzeMeetingSentiment(_currentMeeting!.id);
      
      // Generate summary and action items
      final summary = await _meetingService.generateMeetingSummary(_currentMeeting!.id);
      final actionItems = await _meetingService.generateActionItems(_currentMeeting!.id);
      
      // Calculate duration
      final now = DateTime.now();
      final duration = now.difference(_currentMeeting!.date).inMinutes;
      
      // Update meeting
      await _meetingService.completeMeeting(
        _currentMeeting!.id,
        summary: summary,
        actionItems: actionItems,
        sentimentScore: sentiment,
      );
      
      final updatedMeeting = _currentMeeting!.copyWith(
        durationMinutes: duration,
        summary: summary,
        actionItems: actionItems,
        sentimentScore: sentiment,
      );
      
      await _meetingService.updateMeeting(updatedMeeting);
      
      _error = null;
    } catch (e) {
      _error = 'Failed to complete meeting: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearMeeting() {
    _currentMeeting = null;
    _messages = [];
    _projectContext = '';
    notifyListeners();
  }
}
