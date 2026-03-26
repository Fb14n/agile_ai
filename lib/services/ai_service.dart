import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:agile_ai/config/app_config.dart';

class AiService {
  late GenerativeModel _model;
  late ChatSession _chat;
  String _language;
  String _persona;

  AiService({String language = 'de', String persona = 'coach', String? modelId})
      : _language = language,
        _persona = persona {
    _initModel(modelId ?? AppConfig.defaultModel);
  }

  void _initModel(String modelId) {
    _model = GenerativeModel(
      model: modelId,
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
        Content.text(AppConfig.systemPrompt(language: _language, persona: _persona)),
      ],
    );
  }

  /// Reconfigures language/persona and restarts the chat session.
  void reconfigure({String? language, String? persona, String? modelId}) {
    if (language != null) _language = language;
    if (persona != null) _persona = persona;
    _initModel(modelId ?? AppConfig.defaultModel);
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────

  Future<String> sendMessage(String message, {String? projectContext}) async {
    try {
      // If project context is provided, prepend it to the message
      final fullMessage = projectContext != null 
          ? '$projectContext\n\nUser message: $message'
          : message;
      
      final response = await _chat.sendMessage(Content.text(fullMessage));
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<String> facilitateCeremony(String ceremonyType, String context) async {
    try {
      final prompt = _language == 'en'
          ? '''I am facilitating a "$ceremonyType".
Context: $context

Please provide:
1. A brief introduction for this meeting
2. The key points to discuss
3. Helpful questions to drive the conversation
4. Tips for an effective meeting'''
          : '''Ich führe gerade eine "$ceremonyType" durch.
Kontext: $context

Bitte gib mir:
1. Eine kurze Einleitung für diesen Termin
2. Die wichtigsten Punkte, die besprochen werden sollten
3. Hilfreiche Fragen, um die Diskussion zu fördern
4. Tipps, um das Meeting effektiv zu gestalten''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error facilitating ceremony: $e');
    }
  }

  void resetChat() {
    _chat = _model.startChat(
      history: [
        Content.text(AppConfig.systemPrompt(language: _language, persona: _persona)),
      ],
    );
  }

  // ─── Stateless single-request methods ────────────────────────────────────

  Future<double> analyzeSentiment(String messageText) async {
    try {
      final prompt = _language == 'en'
          ? '''Analyze the sentiment of this Scrum meeting text.
Rate it 1–10 (1=very negative, 10=very positive).

Text: "$messageText"

Respond with ONLY a number between 1 and 10, nothing else.'''
          : '''Analysiere die Stimmung dieses Scrum-Meeting-Textes.
Bewerte auf einer Skala 1–10 (1=sehr negativ, 10=sehr positiv).

Text: "$messageText"

Antworte NUR mit einer Zahl zwischen 1 und 10, sonst nichts.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '5.0';
      
      // Parse the number from response
      final numericValue = double.tryParse(responseText.trim()) ?? 5.0;
      return numericValue.clamp(1.0, 10.0);
    } catch (e) {
      return 5.0; // Neutral fallback
    }
  }

  Future<String> generateSprintGoal(List<String> backlogItems) async {
    try {
      final items = backlogItems.map((i) => '- $i').join('\n');
      final prompt = _language == 'en'
          ? '''Based on these backlog items, generate a clear, focused Sprint Goal.

Backlog Items:
$items

The Sprint Goal should:
- Be clear and concise (1–2 sentences)
- Highlight customer value
- Motivate the team'''
          : '''Basierend auf diesen Backlog Items, generiere ein klares Sprint-Ziel.

Backlog Items:
$items

Das Sprint-Ziel sollte:
- Klar und prägnant sein (1–2 Sätze)
- Den Kundenwert hervorheben
- Das Team motivieren''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error generating sprint goal: $e');
    }
  }

  Future<String> analyzeRetrospective(List<String> points) async {
    try {
      final items = points.map((p) => '- $p').join('\n');
      final prompt = _language == 'en'
          ? '''Analyze these retrospective points and create a summary with concrete action recommendations.

Points:
$items

Provide:
1. Main themes (3–5 points)
2. Concrete actions for the next sprint
3. Positive aspects to keep'''
          : '''Analysiere diese Retrospektiven-Punkte und erstelle eine Zusammenfassung mit konkreten Handlungsempfehlungen.

Punkte:
$items

Erstelle:
1. Hauptthemen (3–5 Punkte)
2. Konkrete Aktionen für den nächsten Sprint
3. Positive Aspekte, die beibehalten werden sollten''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error in retrospective analysis: $e');
    }
  }

  // ─── Additional AI methods ────────────────────────────────────────────────

  Future<String> estimateStoryPoints(String userStory) async {
    try {
      final prompt = _language == 'en'
          ? '''As an experienced Scrum team member, estimate the story points for this user story using the Fibonacci scale (1, 2, 3, 5, 8, 13, 21).

User Story: "$userStory"

Provide:
- Recommended story points: [number]
- Reasoning: [why this estimate]
- Complexity factors: [what makes it complex]
- Risks/Unknowns: [what is unclear]'''
          : '''Als erfahrenes Scrum-Teammitglied, schätze die Story Points für diese User Story auf der Fibonacci-Skala (1, 2, 3, 5, 8, 13, 21).

User Story: "$userStory"

Gib an:
- Empfohlene Story Points: [Zahl]
- Begründung: [warum diese Schätzung]
- Komplexitätsfaktoren: [was macht es komplex]
- Risiken/Unklarheiten: [was ist unklar]''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error estimating story points: $e');
    }
  }

  Future<String> generateAcceptanceCriteria(String userStory) async {
    try {
      final prompt = _language == 'en'
          ? '''Generate clear acceptance criteria for this user story in Gherkin format (Given/When/Then).

User Story: "$userStory"

Provide 3–5 concrete acceptance criteria that make the story testable.'''
          : '''Generiere klare Akzeptanzkriterien für diese User Story im Gherkin-Format (Given/When/Then).

User Story: "$userStory"

Erstelle 3–5 konkrete Akzeptanzkriterien, die die Story testbar machen.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error generating acceptance criteria: $e');
    }
  }

  Future<String> validateInvest(String userStory) async {
    try {
      final prompt = _language == 'en'
          ? '''Validate this user story against the INVEST criteria:
- Independent: Can it be developed independently?
- Negotiable: Are the details negotiable?
- Valuable: Does it deliver customer value?
- Estimable: Can it be estimated?
- Small: Is it small enough for one sprint?
- Testable: Can acceptance criteria be defined?

User Story: "$userStory"

For each criterion: ✅ Pass / ⚠️ Partial / ❌ Fail + short explanation.
End with an overall recommendation.'''
          : '''Validiere diese User Story anhand der INVEST-Kriterien:
- Independent: Kann sie unabhängig entwickelt werden?
- Negotiable: Sind die Details verhandelbar?
- Valuable: Liefert sie Kundenwert?
- Estimable: Kann sie geschätzt werden?
- Small: Ist sie klein genug für einen Sprint?
- Testable: Können Akzeptanzkriterien definiert werden?

User Story: "$userStory"

Für jedes Kriterium: ✅ Erfüllt / ⚠️ Teilweise / ❌ Nicht erfüllt + kurze Erklärung.
Abschließend: Gesamtempfehlung.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error in INVEST validation: $e');
    }
  }

  Future<String> detectImpediments(String standupText) async {
    try {
      final prompt = _language == 'en'
          ? '''Analyze this daily standup input for impediments and blockers.

Standup Notes: "$standupText"

Identify:
1. Explicit blockers (clearly stated)
2. Implicit risks (potential issues)
3. Recommended actions for the Scrum Master
4. Questions to ask the team'''
          : '''Analysiere diesen Daily-Standup-Text auf Impediments und Blocker.

Standup-Notizen: "$standupText"

Identifiziere:
1. Explizite Blocker (klar benannt)
2. Implizite Risiken (potenzielle Probleme)
3. Empfohlene Maßnahmen für den Scrum Master
4. Fragen, die gestellt werden sollten''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error in impediment analysis: $e');
    }
  }

  Future<String> analyzeSprintRisk(
      List<String> plannedItems, int availableCapacity) async {
    try {
      final items = plannedItems.map((i) => '- $i').join('\n');
      final prompt = _language == 'en'
          ? '''Analyze the risk of this sprint plan.

Planned Items:
$items

Available Capacity: $availableCapacity story points

Evaluate:
1. Overall risk level (Low / Medium / High)
2. Potential overcommitment risks
3. Technical or dependency risks
4. Recommendations to reduce risk'''
          : '''Analysiere das Risiko dieses Sprint-Plans.

Geplante Items:
$items

Verfügbare Kapazität: $availableCapacity Story Points

Bewerte:
1. Gesamtrisiko-Level (Niedrig / Mittel / Hoch)
2. Potenzielle Overcommitment-Risiken
3. Technische oder Abhängigkeits-Risiken
4. Empfehlungen zur Risikoreduktion''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error in risk analysis: $e');
    }
  }

  Future<String> generateDefinitionOfDone(
      String projectContext, List<String> techStack) async {
    try {
      final stack = techStack.join(', ');
      final prompt = _language == 'en'
          ? '''Create a practical Definition of Done for this project.

Project context: $projectContext
Technology stack: $stack

The DoD should cover: Code quality, Testing, Documentation, Deployment, and Review.
Format as a checklist with 8–12 items.'''
          : '''Erstelle eine praktische Definition of Done für dieses Projekt.

Projektkontext: $projectContext
Technologie-Stack: $stack

Die DoD sollte abdecken: Code-Qualität, Tests, Dokumentation, Deployment und Review.
Format: Checkliste mit 8–12 Punkten.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error generating DoD: $e');
    }
  }

  Future<String> extractActionItems(String meetingText) async {
    try {
      final prompt = _language == 'en'
          ? '''Extract all action items from this meeting transcript.

Meeting text: "$meetingText"

For each action item provide:
- Task: [what needs to be done]
- Assignee: [who is responsible, if mentioned]
- Due: [when, if mentioned]

Format as a numbered list.'''
          : '''Extrahiere alle Action Items aus diesem Meeting-Protokoll.

Meeting-Text: "$meetingText"

Für jedes Action Item:
- Aufgabe: [was getan werden muss]
- Verantwortlich: [wer, falls erwähnt]
- Bis wann: [wann, falls erwähnt]

Format: nummerierte Liste.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error extracting action items: $e');
    }
  }

  Future<String> evaluateScrumMaturity(Map<String, int> answers) async {
    try {
      final answerText = answers.entries
          .map((e) => '- ${e.key}: ${e.value}/5')
          .join('\n');
      final prompt = _language == 'en'
          ? '''Evaluate this team's Scrum maturity based on their self-assessment.

Assessment scores (1=very low, 5=very high):
$answerText

Provide:
1. Overall maturity score (1–5)
2. Key strengths (top 2–3)
3. Key improvement areas (top 2–3)
4. Concrete next steps for the Scrum Master
5. Recommended focus for the next sprint'''
          : '''Bewerte die Scrum-Reife dieses Teams basierend auf der Selbsteinschätzung.

Bewertungsscores (1=sehr niedrig, 5=sehr hoch):
$answerText

Erstelle:
1. Gesamt-Reife-Score (1–5)
2. Stärken (Top 2–3)
3. Verbesserungsbereiche (Top 2–3)
4. Konkrete nächste Schritte für den Scrum Master
5. Empfohlener Fokus für den nächsten Sprint''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error in maturity assessment: $e');
    }
  }

  Future<String> getScrumTip(String context) async {
    try {
      final prompt = _language == 'en'
          ? 'Give a practical Scrum tip relevant to this context: $context. Keep it under 3 sentences.'
          : 'Gib einen praktischen Scrum-Tipp passend zu diesem Kontext: $context. Maximal 3 Sätze.';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error fetching tip: $e');
    }
  }

  /// Generate content from a prompt (for project AI chat)
  Future<String?> generateContent(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      throw Exception('Error generating content: $e');
    }
  }

  /// Builds a context summary from past ceremonies to improve AI responses.
  String buildCeremonyContext(List<String> pastSummaries) {
    if (pastSummaries.isEmpty) return '';
    final summaries = pastSummaries.take(3).join('\n---\n');
    return _language == 'en'
        ? '\n\nContext from previous meetings:\n$summaries'
        : '\n\nKontext aus vergangenen Meetings:\n$summaries';
  }

  Future<String> analyzeRetroPatterns(List<String> summaries) async {
    try {
      final items = summaries.asMap().entries
          .map((e) => 'Retro ${e.key + 1}: ${e.value}')
          .join('\n\n');
      final prompt = _language == 'en'
          ? '''Analyze these retrospective summaries for recurring patterns and themes.

Retrospective summaries:
$items

Identify:
1. Recurring themes (appearing in 2+ retros) with frequency
2. Persistent impediments that have not been resolved
3. Positive trends that are improving
4. Recommended focus areas for the next sprint'''
          : '''Analysiere diese Retrospektiven-Zusammenfassungen auf wiederkehrende Muster.

Zusammenfassungen:
$items

Identifiziere:
1. Wiederkehrende Themen (in 2+ Retros vorhanden) mit Häufigkeit
2. Persistente Impediments, die nicht gelöst wurden
3. Positive Trends, die sich verbessern
4. Empfohlene Fokus-Bereiche für den nächsten Sprint''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _fallback();
    } catch (e) {
      throw Exception('Error in retro pattern analysis: $e');
    }
  }

  String _fallback() => _language == 'en'
      ? 'Sorry, no response could be generated.'
      : 'Entschuldigung, es konnte keine Antwort generiert werden.';
}
