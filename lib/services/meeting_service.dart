import 'package:agile_ai/models/meeting.dart';
import 'package:agile_ai/models/meeting_message.dart';
import 'package:agile_ai/services/database_service.dart';
import 'package:agile_ai/services/ai_service.dart';

/// Service for meeting-related business logic and AI integration.
class MeetingService {
  final DatabaseService _dbService;
  final AiService _aiService;

  MeetingService(this._dbService, this._aiService);

  // ─── Meetings ──────────────────────────────────────────────────────────────

  Future<List<Meeting>> getMeetingsByProject(String projectId) async {
    return await _dbService.loadMeetingsByProject(projectId);
  }

  Future<Meeting?> getMeeting(String id) async {
    return await _dbService.loadMeeting(id);
  }

  Future<Meeting> createMeeting(Meeting meeting) async {
    await _dbService.saveMeeting(meeting);
    return meeting;
  }

  Future<void> updateMeeting(Meeting meeting) async {
    await _dbService.saveMeeting(meeting);
  }

  Future<void> completeMeeting(String meetingId, {
    String? summary,
    List<String>? actionItems,
    double? sentimentScore,
  }) async {
    final meeting = await _dbService.loadMeeting(meetingId);
    if (meeting != null) {
      await _dbService.saveMeeting(
        meeting.copyWith(
          summary: summary ?? meeting.summary,
          actionItems: actionItems ?? meeting.actionItems,
          sentimentScore: sentimentScore ?? meeting.sentimentScore,
        ),
      );
    }
  }

  // ─── Meeting Messages ──────────────────────────────────────────────────────

  Future<List<MeetingMessage>> getMessages(String meetingId) async {
    return await _dbService.loadMessagesByMeeting(meetingId);
  }

  Future<void> saveMessage(MeetingMessage message) async {
    await _dbService.saveMeetingMessage(message);
  }

  Future<MeetingMessage> sendUserMessage(String meetingId, String content) async {
    final message = MeetingMessage(
      meetingId: meetingId,
      isUser: true,
      content: content,
      messageType: MessageType.user,
    );
    await _dbService.saveMeetingMessage(message);
    return message;
  }

  Future<MeetingMessage> sendAssistantMessage(String meetingId, String content, {
    MessageType type = MessageType.assistant,
  }) async {
    final message = MeetingMessage(
      meetingId: meetingId,
      isUser: false,
      content: content,
      messageType: type,
    );
    await _dbService.saveMeetingMessage(message);
    return message;
  }

  // ─── AI Integration ────────────────────────────────────────────────────────

  /// Sends a message to AI and saves both user and assistant messages
  Future<String> sendToAI({
    required String meetingId,
    required String userMessage,
    required String projectContext,
  }) async {
    // Save user message
    await sendUserMessage(meetingId, userMessage);

    // Get AI response with project context
    final aiResponse = await _aiService.sendMessage(
      userMessage,
      projectContext: projectContext,
    );

    // Save AI response
    await sendAssistantMessage(meetingId, aiResponse);

    return aiResponse;
  }

  /// Analyzes meeting sentiment based on messages
  Future<double> analyzeMeetingSentiment(String meetingId) async {
    final messages = await _dbService.loadMessagesByMeeting(meetingId);
    final userMessages = messages
        .where((m) => m.isUser)
        .map((m) => m.content)
        .join('\n');

    if (userMessages.isEmpty) return 5.0;

    final sentiment = await _aiService.analyzeSentiment(userMessages);
    return sentiment;
  }

  /// Generates action items from meeting messages
  Future<List<String>> generateActionItems(String meetingId) async {
    final messages = await _dbService.loadMessagesByMeeting(meetingId);
    final conversation = messages
        .map((m) => '${m.isUser ? "User" : "AI"}: ${m.content}')
        .join('\n');

    if (conversation.isEmpty) return [];

    // Simple extraction - in real app, use more sophisticated AI
    final actionItems = <String>[];
    for (final msg in messages) {
      if (msg.content.toLowerCase().contains('action:') ||
          msg.content.toLowerCase().contains('todo:')) {
        actionItems.add(msg.content);
      }
    }

    return actionItems;
  }

  /// Generates a summary of the meeting
  Future<String> generateMeetingSummary(String meetingId) async {
    final messages = await _dbService.loadMessagesByMeeting(meetingId);
    final conversation = messages
        .map((m) => '${m.isUser ? "Team" : "AI"}: ${m.content}')
        .join('\n\n');

    if (conversation.isEmpty) return 'No discussion recorded.';

    // For now, return last few messages as summary
    // In real app, use AI to generate proper summary
    final lastMessages = messages.reversed.take(3).toList();
    return lastMessages.map((m) => m.content).join('\n');
  }

  // ─── Meeting History for AI Context ────────────────────────────────────────

  /// Builds conversation history for AI context continuity
  Future<String> buildConversationHistory(String meetingId) async {
    final messages = await _dbService.loadMessagesByMeeting(meetingId);
    
    final buffer = StringBuffer();
    buffer.writeln('# Meeting History\n');
    
    for (final msg in messages) {
      final speaker = msg.isUser ? 'User' : 'Assistant';
      buffer.writeln('**$speaker:** ${msg.content}\n');
    }
    
    return buffer.toString();
  }
}
