import 'package:flutter/foundation.dart';
import 'package:agile_ai/models/message.dart';
import 'package:agile_ai/models/scrum_ceremony.dart';
import 'package:agile_ai/services/ai_service.dart';
import 'package:agile_ai/services/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final AiService _aiService = AiService();
  final StorageService _storageService = StorageService();

  List<Message> _messages = [];
  bool _isLoading = false;
  ScrumCeremony? _currentCeremony;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  ScrumCeremony? get currentCeremony => _currentCeremony;

  ChatProvider() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    _messages = await _storageService.loadMessages();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = Message(
      text: text,
      isUser: true,
    );
    _messages.add(userMessage);
    notifyListeners();

    // Get AI response
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _aiService.sendMessage(text);
      final aiMessage = Message(
        text: response,
        isUser: false,
      );
      _messages.add(aiMessage);
    } catch (e) {
      final errorMessage = Message(
        text: 'Fehler: $e',
        isUser: false,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      await _storageService.saveMessages(_messages);
      notifyListeners();
    }
  }

  Future<void> startCeremony(String ceremonyName) async {
    _currentCeremony = ScrumCeremony(name: ceremonyName);
    
    _isLoading = true;
    notifyListeners();

    try {
      final facilitationText = await _aiService.facilitateCeremony(
        ceremonyName,
        'Team startet neue Zeremonie',
      );
      
      final message = Message(
        text: facilitationText,
        isUser: false,
        type: MessageType.ceremony,
        metadata: {'ceremony': ceremonyName},
      );
      _messages.add(message);
    } catch (e) {
      final errorMessage = Message(
        text: 'Fehler beim Starten der Zeremonie: $e',
        isUser: false,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      await _storageService.saveMessages(_messages);
      notifyListeners();
    }
  }

  Future<void> analyzeSentiment(String text) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sentimentAnalysis = await _aiService.analyzeSentiment(text);
      final message = Message(
        text: sentimentAnalysis,
        isUser: false,
        type: MessageType.sentiment,
      );
      _messages.add(message);
    } catch (e) {
      final errorMessage = Message(
        text: 'Fehler bei Sentiment-Analyse: $e',
        isUser: false,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      await _storageService.saveMessages(_messages);
      notifyListeners();
    }
  }

  Future<void> generateSprintGoal(List<String> backlogItems) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sprintGoal = await _aiService.generateSprintGoal(backlogItems);
      final message = Message(
        text: sprintGoal,
        isUser: false,
        type: MessageType.goal,
      );
      _messages.add(message);
    } catch (e) {
      final errorMessage = Message(
        text: 'Fehler bei Sprint-Ziel Generierung: $e',
        isUser: false,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      await _storageService.saveMessages(_messages);
      notifyListeners();
    }
  }

  Future<void> analyzeRetrospective(List<String> points) async {
    _isLoading = true;
    notifyListeners();

    try {
      final analysis = await _aiService.analyzeRetrospective(points);
      final message = Message(
        text: analysis,
        isUser: false,
        type: MessageType.insight,
      );
      _messages.add(message);
    } catch (e) {
      final errorMessage = Message(
        text: 'Fehler bei Retrospektiven-Analyse: $e',
        isUser: false,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      await _storageService.saveMessages(_messages);
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _aiService.resetChat();
    _storageService.saveMessages(_messages);
    notifyListeners();
  }

  void endCeremony() {
    _currentCeremony = null;
    notifyListeners();
  }
}
