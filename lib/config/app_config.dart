import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // ─── API ─────────────────────────────────────────────────────────────────
  static final String geminiApiKey = dotenv.env['GEMINI_API_KEY']!;

  // ─── App ─────────────────────────────────────────────────────────────────
  static const String appName = 'AgileAI';
  static const String appVersion = '1.0.0';

  // ─── Sprachunterstützung ─────────────────────────────────────────────────
  /// Unterstützte Sprachen: 'de' | 'en'
  static const String defaultLanguage = 'de';

  // ─── Scrum-Zeremonien mit Details ────────────────────────────────────────
  static const List<Map<String, dynamic>> ceremonyDetails = [
    {
      'name': 'Daily Standup',
      'nameEn': 'Daily Standup',
      'icon': 'groups',
      'timeboxMinutes': 15,
      'agenda': [
        'Was habe ich gestern getan?',
        'Was werde ich heute tun?',
        'Gibt es Hindernisse?',
      ],
      'agendaEn': [
        'What did I do yesterday?',
        'What will I do today?',
        'Are there any impediments?',
      ],
      'description': 'Tägliches 15-minütiges Team-Meeting',
      'descriptionEn': 'Daily 15-minute team sync',
    },
    {
      'name': 'Sprint Planning',
      'nameEn': 'Sprint Planning',
      'icon': 'calendar_month',
      'timeboxMinutes': 240,
      'agenda': [
        'Sprint Goal festlegen',
        'Backlog Items auswählen & schätzen',
        'Tasks aufteilen',
        'Commitment des Teams',
      ],
      'agendaEn': [
        'Define Sprint Goal',
        'Select & estimate Backlog Items',
        'Break down into tasks',
        'Team commitment',
      ],
      'description': 'Planung des kommenden Sprints (max. 4h)',
      'descriptionEn': 'Plan the upcoming sprint (max 4h)',
    },
    {
      'name': 'Sprint Review',
      'nameEn': 'Sprint Review',
      'icon': 'preview',
      'timeboxMinutes': 60,
      'agenda': [
        'Erledigte Items präsentieren',
        'Demo durchführen',
        'Feedback vom Stakeholder',
        'Backlog anpassen',
      ],
      'agendaEn': [
        'Present completed items',
        'Live demo',
        'Stakeholder feedback',
        'Backlog update',
      ],
      'description': 'Präsentation der Sprint-Ergebnisse (max. 1h)',
      'descriptionEn': 'Present sprint results (max 1h)',
    },
    {
      'name': 'Sprint Retrospective',
      'nameEn': 'Sprint Retrospective',
      'icon': 'insights',
      'timeboxMinutes': 90,
      'agenda': [
        'Was lief gut?',
        'Was lief nicht gut?',
        'Was können wir verbessern?',
        'Action Items festlegen',
      ],
      'agendaEn': [
        'What went well?',
        'What did not go well?',
        'What can we improve?',
        'Define action items',
      ],
      'description': 'Reflexion über den letzten Sprint (max. 1,5h)',
      'descriptionEn': 'Reflect on the last sprint (max 1.5h)',
    },
    {
      'name': 'Backlog Refinement',
      'nameEn': 'Backlog Refinement',
      'icon': 'list_alt',
      'timeboxMinutes': 120,
      'agenda': [
        'User Stories reviewen',
        'Akzeptanzkriterien definieren',
        'Story Points schätzen',
        'Priorität anpassen',
      ],
      'agendaEn': [
        'Review user stories',
        'Define acceptance criteria',
        'Estimate story points',
        'Adjust priority',
      ],
      'description': 'Verfeinerung des Product Backlogs (max. 2h)',
      'descriptionEn': 'Refine the product backlog (max 2h)',
    },
  ];

  /// Nur die Namen (Rückwärtskompatibilität)
  static List<String> get ceremonies =>
      ceremonyDetails.map((c) => c['name'] as String).toList();

  // ─── KI-Modelle ───────────────────────────────────────────────────────────
  static const List<Map<String, String>> availableModels = [
    {'id': 'gemma-3-27b-it', 'label': 'Gemma 3 27B (Standard)'},
    {'id': 'gemma-3-12b-it', 'label': 'Gemma 3 12B (Schnell)'},
    {'id': 'gemini-2.0-flash-lite', 'label': 'Gemini 2.0 Flash Lite (Max Limits)'},
    {'id': 'gemini-2.0-flash', 'label': 'Gemini 2.0 Flash (Ausgewogen)'},
    {'id': 'gemini-2.5-flash', 'label': 'Gemini 2.5 Flash (Aktuell)'},
  ];

  static const String defaultModel = 'gemma-3-27b-it';

  // ─── Persona-Stile ────────────────────────────────────────────────────────
  static const List<Map<String, String>> personaStyles = [
    {'id': 'coach', 'label': 'Coach (Empfohlen)', 'desc': 'Unterstützend, fragend, motivierend'},
    {'id': 'direct', 'label': 'Direkt', 'desc': 'Klar, prägnant, auf den Punkt'},
    {'id': 'formal', 'label': 'Formal', 'desc': 'Professionell, strukturiert'},
    {'id': 'casual', 'label': 'Casual', 'desc': 'Locker, teamorientiert'},
  ];

  // ─── System-Prompts ───────────────────────────────────────────────────────
  static String systemPrompt({String language = 'de', String persona = 'coach'}) {
    final personaInstructions = _personaInstructions[persona] ?? _personaInstructions['coach']!;
    if (language == 'en') {
      return '''
You are an experienced Scrum Master assistant. Your role is to:
- Guide teams through Scrum ceremonies
- Provide helpful suggestions and best practices
- Analyze team sentiment and provide insights
- Generate sprint goals and summaries
- Identify impediments and risks early

$personaInstructions
Always be practical and actionable. Keep answers concise unless detail is requested.
''';
    }
    return '''
Du bist ein erfahrener Scrum Master Assistent. Deine Aufgabe ist es:
- Teams durch Scrum-Zeremonien zu führen
- Hilfreiche Vorschläge und Best Practices zu geben
- Team-Stimmung zu analysieren und Einblicke zu liefern
- Sprint-Ziele und Zusammenfassungen zu generieren
- Impediments und Risiken frühzeitig zu erkennen

$personaInstructions
Sei immer praktisch und handlungsorientiert. Halte Antworten prägnant, außer Details sind gewünscht.
''';
  }

  static const Map<String, String> _personaInstructions = {
    'coach':
        'Kommuniziere unterstützend und coachend. Stelle Fragen, die das Team zum Nachdenken bringen. Sei motivierend.',
    'direct':
        'Kommuniziere direkt und klar. Keine unnötigen Füllwörter. Klare Empfehlungen.',
    'formal':
        'Kommuniziere professionell und strukturiert. Verwende eine formelle Ausdrucksweise.',
    'casual':
        'Kommuniziere locker und teamorientiert. Duze das Team. Sei zugänglich.',
  };

  // ─── Fibonacci-Skala für Story Points ────────────────────────────────────
  static const List<int> fibonacciPoints = [1, 2, 3, 5, 8, 13, 21];

  // ─── Scrum-Wissensbasis ───────────────────────────────────────────────────
  static const List<Map<String, dynamic>> knowledgeBase = [
    {
      'category': 'Rollen',
      'entries': [
        {
          'term': 'Product Owner',
          'definition':
              'Verantwortlich für den Product Backlog und die Maximierung des Produktwerts. Repräsentiert die Stakeholder.',
        },
        {
          'term': 'Scrum Master',
          'definition':
              'Servant Leader des Scrum Teams. Sorgt für die Einhaltung von Scrum, beseitigt Hindernisse.',
        },
        {
          'term': 'Entwicklungsteam',
          'definition':
              'Selbstorganisiertes, cross-funktionales Team (3–9 Personen), das das Inkrement erstellt.',
        },
      ],
    },
    {
      'category': 'Zeremonien',
      'entries': [
        {
          'term': 'Sprint',
          'definition': 'Zeitlicher Rahmen von 1–4 Wochen, in dem ein fertiges Inkrement erstellt wird.',
        },
        {
          'term': 'Daily Standup',
          'definition':
              'Tägliches 15-minütiges Meeting zur Synchronisation des Teams. Kein Statusbericht – Koordination.',
        },
        {
          'term': 'Sprint Planning',
          'definition':
              'Meeting zu Beginn jedes Sprints. Team wählt Items aus dem Backlog und plant die Arbeit (max. 8h für 4-Wochen-Sprint).',
        },
        {
          'term': 'Sprint Review',
          'definition':
              'Präsentation des Inkrements an Stakeholder. Feedback einsammeln. Backlog anpassen (max. 4h).',
        },
        {
          'term': 'Sprint Retrospective',
          'definition':
              'Team reflektiert über Prozess, Zusammenarbeit und Werkzeuge. Verbesserungsmaßnahmen festlegen (max. 3h).',
        },
        {
          'term': 'Backlog Refinement',
          'definition':
              'Laufende Aktivität zur Detaillierung und Schätzung von Backlog Items. Typisch: 10% der Sprint-Kapazität.',
        },
      ],
    },
    {
      'category': 'Artefakte',
      'entries': [
        {
          'term': 'Product Backlog',
          'definition':
              'Geordnete Liste aller bekannten Anforderungen. Wird vom Product Owner gepflegt.',
        },
        {
          'term': 'Sprint Backlog',
          'definition':
              'Ausgewählte Items für den aktuellen Sprint plus Plan für ihre Umsetzung.',
        },
        {
          'term': 'Inkrement',
          'definition': 'Summe aller Done Items eines Sprints. Muss die Definition of Done erfüllen.',
        },
        {
          'term': 'Definition of Done (DoD)',
          'definition':
              'Gemeinsames Verständnis, wann ein Item als fertig gilt (z.B. Code reviewed, getestet, deployt).',
        },
      ],
    },
    {
      'category': 'INVEST-Kriterien',
      'entries': [
        {'term': 'Independent', 'definition': 'Story ist unabhängig von anderen Stories umsetzbar.'},
        {'term': 'Negotiable', 'definition': 'Details der Story können zwischen PO und Team verhandelt werden.'},
        {'term': 'Valuable', 'definition': 'Story liefert messbaren Wert für den Nutzer oder das Unternehmen.'},
        {'term': 'Estimable', 'definition': 'Team kann die Story schätzen – sie ist klar genug verstanden.'},
        {'term': 'Small', 'definition': 'Story ist klein genug, um in einem Sprint abgeschlossen zu werden.'},
        {'term': 'Testable', 'definition': 'Es können konkrete Akzeptanzkriterien formuliert werden.'},
      ],
    },
    {
      'category': 'Schätzung',
      'entries': [
        {
          'term': 'Story Points',
          'definition':
              'Relative Komplexitätseinheit (Fibonacci: 1,2,3,5,8,13,21). Misst Aufwand, nicht Zeit.',
        },
        {
          'term': 'Planning Poker',
          'definition':
              'Schätztechnik: Alle Teammitglieder schätzen gleichzeitig verdeckt, dann Diskussion bei Abweichungen.',
        },
        {
          'term': 'Velocity',
          'definition':
              'Durchschnittliche Story Points, die ein Team pro Sprint abschließt. Basis für die Sprintplanung.',
        },
      ],
    },
  ];
}
