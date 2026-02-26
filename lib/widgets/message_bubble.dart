import 'package:flutter/material.dart';
import 'package:agile_ai/models/message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  Color _getBackgroundColor(BuildContext context, MessageType type) {
    if (message.isUser) {
      return Theme.of(context).primaryColor;
    }

    switch (type) {
      case MessageType.ceremony:
        return Colors.purple[100]!;
      case MessageType.insight:
        return Colors.blue[100]!;
      case MessageType.goal:
        return Colors.green[100]!;
      case MessageType.sentiment:
        return Colors.orange[100]!;
      default:
        return Colors.grey[300]!;
    }
  }

  IconData _getIcon(MessageType type) {
    switch (type) {
      case MessageType.ceremony:
        return Icons.event;
      case MessageType.insight:
        return Icons.insights;
      case MessageType.goal:
        return Icons.flag;
      case MessageType.sentiment:
        return Icons.sentiment_satisfied;
      default:
        return Icons.chat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.timestamp);
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context, message.type),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser && message.type != MessageType.text)
                Row(
                  children: [
                    Icon(
                      _getIcon(message.type),
                      size: 16,
                      color: message.isUser ? Colors.white : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTypeLabel(message.type),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: message.isUser ? Colors.white : Colors.black54,
                      ),
                    ),
                  ],
                ),
              if (!message.isUser && message.type != MessageType.text)
                const SizedBox(height: 8),
              Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: message.isUser ? Colors.white70 : Colors.black45,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.ceremony:
        return 'Zeremonie';
      case MessageType.insight:
        return 'Insights';
      case MessageType.goal:
        return 'Sprint-Ziel';
      case MessageType.sentiment:
        return 'Sentiment';
      default:
        return '';
    }
  }
}
