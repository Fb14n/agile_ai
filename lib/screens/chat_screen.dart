import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/chat_provider.dart';
import 'package:agile_ai/widgets/message_bubble.dart';
import 'package:agile_ai/widgets/ceremony_selector.dart';
import 'package:agile_ai/config/app_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
      builder: (context) => CeremonySelector(
        onCeremonySelected: (ceremony) {
          Navigator.pop(context);
          context.read<ChatProvider>().startCeremony(ceremony);
          _scrollToBottom();
        },
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Zeremonie starten'),
              onTap: () {
                Navigator.pop(context);
                _showCeremonySelector();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sentiment_satisfied),
              title: const Text('Sentiment analysieren'),
              onTap: () {
                Navigator.pop(context);
                _showSentimentDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Sprint-Ziel generieren'),
              onTap: () {
                Navigator.pop(context);
                _showSprintGoalDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('Retrospektive analysieren'),
              onTap: () {
                Navigator.pop(context);
                _showRetrospectiveDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Chat löschen'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatProvider>().clearChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSentimentDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sentiment analysieren'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Text aus dem Meeting eingeben...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatProvider>().analyzeSentiment(controller.text);
              _scrollToBottom();
            },
            child: const Text('Analysieren'),
          ),
        ],
      ),
    );
  }

  void _showSprintGoalDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sprint-Ziel generieren'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Backlog Items eingeben (eine pro Zeile)...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final items = controller.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
              context.read<ChatProvider>().generateSprintGoal(items);
              _scrollToBottom();
            },
            child: const Text('Generieren'),
          ),
        ],
      ),
    );
  }

  void _showRetrospectiveDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retrospektive analysieren'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Retrospektiven-Punkte eingeben (eine pro Zeile)...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final points = controller.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
              context.read<ChatProvider>().analyzeRetrospective(points);
              _scrollToBottom();
            },
            child: const Text('Analysieren'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Willkommen beim ScrumMaster AI!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Starte eine Konversation oder wähle eine Zeremonie',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showCeremonySelector,
                          icon: const Icon(Icons.event),
                          label: const Text('Zeremonie starten'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatProvider.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final message = chatProvider.messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Nachricht eingeben...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
