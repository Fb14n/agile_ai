import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:agile_ai/config/app_config.dart';

class AiService {
  late final GenerativeModel _model;
  late ChatSession _chat;
  
  AiService() {
    _model = GenerativeModel(
      model: 'gemma-3-27b-it',
      apiKey: AppConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
    
    _chat = _model.startChat(
      history: [
        Content.text(AppConfig.systemPrompt),
      ],
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'Entschuldigung, ich konnte keine Antwort generieren.';
    } catch (e) {
      throw Exception('Fehler beim Senden der Nachricht: $e');
    }
  }

  Future<String> analyzeSentiment(String text) async {
    try {
      final prompt = '''
Analysiere die Stimmung (Sentiment) des folgenden Textes aus einem Scrum-Meeting.
Bewerte die Stimmung auf einer Skala von 1-10 (1=sehr negativ, 10=sehr positiv) und gib eine kurze Begründung.

Text: "$text"

Format der Antwort:
Score: [Zahl 1-10]
Begründung: [Kurze Erklärung]
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Sentiment-Analyse fehlgeschlagen.';
    } catch (e) {
      throw Exception('Fehler bei Sentiment-Analyse: $e');
    }
  }

  Future<String> generateSprintGoal(List<String> backlogItems) async {
    try {
      final prompt = '''
Basierend auf den folgenden Backlog Items, generiere ein klares, fokussiertes Sprint-Ziel (Sprint Goal):

Backlog Items:
${backlogItems.map((item) => '- $item').join('\n')}

Das Sprint-Ziel sollte:
- Klar und prägnant sein
- Den Wert für den Kunden hervorheben
- Das Team motivieren
- In 1-2 Sätzen formuliert sein
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Sprint-Ziel konnte nicht generiert werden.';
    } catch (e) {
      throw Exception('Fehler bei Sprint-Ziel Generierung: $e');
    }
  }

  Future<String> analyzeRetrospective(List<String> points) async {
    try {
      final prompt = '''
Analysiere die folgenden Retrospektiven-Punkte und erstelle eine Zusammenfassung mit konkreten Handlungsempfehlungen:

Punkte:
${points.map((p) => '- $p').join('\n')}

Erstelle:
1. Hauptthemen (3-5 Punkte)
2. Konkrete Aktionen für den nächsten Sprint
3. Positive Aspekte, die beibehalten werden sollten
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Retrospektiven-Analyse fehlgeschlagen.';
    } catch (e) {
      throw Exception('Fehler bei Retrospektiven-Analyse: $e');
    }
  }

  Future<String> facilitateCeremony(String ceremonyType, String context) async {
    try {
      final prompt = '''
Als Scrum Master führe ich gerade eine "$ceremonyType" durch.
Kontext: $context

Bitte gib mir:
1. Eine kurze Einleitung für diesen Termin
2. Die wichtigsten Punkte, die besprochen werden sollten
3. Hilfreiche Fragen, um die Diskussion zu fördern
4. Tipps, um das Meeting effektiv zu gestalten
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Zeremonie-Unterstützung fehlgeschlagen.';
    } catch (e) {
      throw Exception('Fehler bei Zeremonie-Moderation: $e');
    }
  }

  void resetChat() {
    _chat = _model.startChat(
      history: [
        Content.text(AppConfig.systemPrompt),
      ],
    );
  }
}
