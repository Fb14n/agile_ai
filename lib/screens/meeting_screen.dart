import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/meeting_provider.dart';
import 'package:agile_ai/models/meeting.dart';

/// Placeholder for meeting screen - to be fully implemented
class MeetingScreen extends StatelessWidget {
  final String projectId;
  final String meetingType;

  const MeetingScreen({
    super.key,
    required this.projectId,
    required this.meetingType,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeetingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getMeetingTypeName(meetingType)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.messages.length,
              itemBuilder: (context, index) {
                final message = provider.messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Card(
                    color: message.isUser ? Colors.blue[100] : Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(message.content),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Nachricht eingeben...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (text) {
                      provider.sendMessage(text);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        return 'Retrospective';
      default:
        return 'Meeting';
    }
  }
}
