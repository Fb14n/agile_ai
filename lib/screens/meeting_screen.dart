import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/meeting_provider.dart';
import 'package:agile_ai/providers/project_provider.dart';
import 'package:agile_ai/models/meeting.dart';

/// Screen for conducting Scrum meetings with AI facilitation.
class MeetingScreen extends StatefulWidget {
  final String projectId;
  final String meetingType;

  const MeetingScreen({
    super.key,
    required this.projectId,
    required this.meetingType,
  });

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMeeting();
    });
  }

  Future<void> _initializeMeeting() async {
    if (_initialized) return;
    _initialized = true;

    final meetingProvider = context.read<MeetingProvider>();
    final projectProvider = context.read<ProjectProvider>();
    
    // Get current sprint if available
    final currentSprint = projectProvider.sprints.isNotEmpty 
        ? projectProvider.sprints.last 
        : null;

    await meetingProvider.startMeeting(
      projectId: widget.projectId,
      sprintId: currentSprint?.id,
      type: _parseMeetingType(widget.meetingType),
      participants: ['Ich'], // Default participant
    );
  }

  MeetingType _parseMeetingType(String type) {
    switch (type) {
      case 'daily':
        return MeetingType.daily;
      case 'planning':
        return MeetingType.planning;
      case 'review':
        return MeetingType.review;
      case 'retrospective':
        return MeetingType.retrospective;
      case 'refinement':
        return MeetingType.refinement;
      default:
        return MeetingType.daily;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    await context.read<MeetingProvider>().sendMessage(text);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _endMeeting() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Meeting beenden?'),
        content: const Text(
          'Das Meeting wird beendet und eine Zusammenfassung wird erstellt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Beenden'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<MeetingProvider>().completeMeeting();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeetingProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(_getMeetingTypeIcon(widget.meetingType)),
            const SizedBox(width: 8),
            Text(_getMeetingTypeName(widget.meetingType)),
          ],
        ),
        actions: [
          if (provider.hasMeeting)
            TextButton.icon(
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              label: const Text('Beenden', style: TextStyle(color: Colors.red)),
              onPressed: _endMeeting,
            ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: provider.isLoading && provider.messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Meeting wird gestartet...'),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      return _MessageBubble(
                        content: message.content,
                        isUser: message.isUser,
                        timestamp: message.timestamp,
                      );
                    },
                  ),
          ),

          // Error message
          if (provider.error != null)
            Container(
              color: Colors.red[100],
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(provider.error!)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => provider.clearError(),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Nachricht eingeben...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !provider.isLoading && provider.hasMeeting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: provider.isLoading || !provider.hasMeeting
                        ? null
                        : _sendMessage,
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMeetingTypeIcon(String type) {
    switch (type) {
      case 'daily':
        return Icons.wb_sunny;
      case 'planning':
        return Icons.event_note;
      case 'review':
        return Icons.visibility;
      case 'retrospective':
        return Icons.refresh;
      case 'refinement':
        return Icons.tune;
      default:
        return Icons.event;
    }
  }

  String _getMeetingTypeName(String type) {
    switch (type) {
      case 'daily':
        return 'Daily Standup';
      case 'planning':
        return 'Sprint Planning';
      case 'review':
        return 'Sprint Review';
      case 'retrospective':
        return 'Retrospektive';
      case 'refinement':
        return 'Refinement';
      default:
        return 'Meeting';
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const _MessageBubble({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white70
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
