import 'package:agile_ai/models/project.dart';
import 'package:agile_ai/models/sprint.dart';
import 'package:agile_ai/models/user_story.dart';
import 'package:agile_ai/models/meeting.dart';
import 'package:agile_ai/models/meeting_message.dart';
import 'package:agile_ai/models/project_team_member.dart';
import 'package:agile_ai/models/project_context.dart';
import 'package:agile_ai/services/database_service.dart';

/// Seeds the database with the fantasy project "QuantumHealth"
/// for demo and onboarding purposes.
class SeedService {
  final DatabaseService _dbService;

  SeedService(this._dbService);

  Future<void> seedFantasyProject() async {
    // Check if DB is already seeded
    final isEmpty = await _dbService.isDatabaseEmpty();
    if (!isEmpty) return;

    print('🌱 Seeding fantasy project: QuantumHealth');

    // Create project
    final project = Project(
      name: 'QuantumHealth',
      description: 'KI-gestützte Telemedizin-Plattform für Patienten und Ärzte mit Videosprechstunden, E-Rezept-Integration und smartem Symptom-Checker',
      teamSize: 6,
      sprintLengthWeeks: 2,
      currentSprintNumber: 3,
      averageVelocity: 42.0,
      status: ProjectStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    );
    await _dbService.saveProject(project);

    // Create team members
    final teamMembers = [
      ProjectTeamMember(
        projectId: project.id,
        name: 'Alice Chen',
        role: 'Backend Developer',
      ),
      ProjectTeamMember(
        projectId: project.id,
        name: 'Bob Müller',
        role: 'Backend Developer',
      ),
      ProjectTeamMember(
        projectId: project.id,
        name: 'Charlie Wilson',
        role: 'Frontend Developer',
      ),
      ProjectTeamMember(
        projectId: project.id,
        name: 'Diana Schmidt',
        role: 'Frontend Developer',
      ),
      ProjectTeamMember(
        projectId: project.id,
        name: 'Eve Rodriguez',
        role: 'QA Engineer',
      ),
      ProjectTeamMember(
        projectId: project.id,
        name: 'Frank Weber',
        role: 'Product Owner',
      ),
    ];
    for (final member in teamMembers) {
      await _dbService.saveTeamMember(member);
    }

    // Create sprints
    final sprint1 = Sprint(
      projectId: project.id,
      sprintNumber: 1,
      startDate: DateTime.now().subtract(const Duration(days: 56)),
      endDate: DateTime.now().subtract(const Duration(days: 42)),
      goal: 'Basis-Infrastruktur und User-Authentifizierung aufsetzen',
      plannedStoryPoints: 40,
      completedStoryPoints: 38,
      status: SprintStatus.completed,
    );
    await _dbService.saveSprint(sprint1);

    final sprint2 = Sprint(
      projectId: project.id,
      sprintNumber: 2,
      startDate: DateTime.now().subtract(const Duration(days: 42)),
      endDate: DateTime.now().subtract(const Duration(days: 28)),
      goal: 'Patienten-Profil und Arzt-Dashboard implementieren',
      plannedStoryPoints: 45,
      completedStoryPoints: 44,
      status: SprintStatus.completed,
    );
    await _dbService.saveSprint(sprint2);

    final sprint3 = Sprint(
      projectId: project.id,
      sprintNumber: 3,
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 0)),
      goal: 'Patienten können eigenständig Termine buchen und Videosprechstunden durchführen',
      plannedStoryPoints: 42,
      completedStoryPoints: 21,
      status: SprintStatus.active,
    );
    await _dbService.saveSprint(sprint3);

    // Create user stories
    final stories = [
      // Sprint 3 - Done
      UserStory(
        projectId: project.id,
        sprintId: sprint3.id,
        title: 'Als Patient möchte ich meine Vitalparameter erfassen',
        description: 'Patienten können Blutdruck, Puls, Gewicht und Blutzucker manuell eingeben und die Historie einsehen.',
        storyPoints: 8,
        priority: StoryPriority.high,
        status: StoryStatus.done,
        acceptanceCriteria: [
          'Eingabeformular für Vitalparameter',
          'Validierung der Eingabewerte',
          'Historie-Ansicht mit Diagramm',
          'Export als PDF möglich',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      UserStory(
        projectId: project.id,
        sprintId: sprint3.id,
        title: 'Als Arzt möchte ich Patientenhistorie einsehen',
        description: 'Ärzte können die vollständige Krankenakte eines Patienten inklusive vergangener Diagnosen, Medikamente und Laborwerte einsehen.',
        storyPoints: 13,
        priority: StoryPriority.high,
        status: StoryStatus.done,
        acceptanceCriteria: [
          'Timeline-Ansicht der Patientenhistorie',
          'Filter nach Zeitraum und Kategorie',
          'Detailansicht für einzelne Einträge',
          'Performance: Laden < 2 Sekunden',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      // Sprint 3 - In Progress
      UserStory(
        projectId: project.id,
        sprintId: sprint3.id,
        title: 'Als Patient möchte ich Videosprechstunden buchen',
        description: 'Patienten können verfügbare Termine einsehen, Videosprechstunden buchen und Erinnerungen erhalten.',
        storyPoints: 13,
        priority: StoryPriority.critical,
        status: StoryStatus.inProgress,
        acceptanceCriteria: [
          'Kalenderansicht mit verfügbaren Slots',
          'Buchung mit Termin-Bestätigung per E-Mail',
          'Push-Benachrichtigung 15 Min. vor Termin',
          'Stornierung bis 24h vorher möglich',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserStory(
        projectId: project.id,
        sprintId: sprint3.id,
        title: 'KI-Symptom-Checker implementieren',
        description: 'Ein KI-gestützter Chatbot erfasst Symptome des Patienten und gibt erste Empfehlungen zur Dringlichkeit.',
        storyPoints: 8,
        priority: StoryPriority.medium,
        status: StoryStatus.inProgress,
        acceptanceCriteria: [
          'Conversational UI für Symptom-Abfrage',
          'Integration mit medizinischer Wissensdatenbank',
          'Ausgabe von Dringlichkeits-Score (1-10)',
          'Disclaimer und rechtliche Absicherung',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      // Backlog - Not in Sprint
      UserStory(
        projectId: project.id,
        sprintId: null,
        title: 'E-Rezept-Integration mit Apotheken',
        description: 'Ärzte können digitale Rezepte ausstellen, die Patienten direkt an ihre Wunsch-Apotheke übermitteln.',
        storyPoints: 21,
        priority: StoryPriority.high,
        status: StoryStatus.todo,
        acceptanceCriteria: [
          'Integration mit gematik E-Rezept-API',
          'Apotheken-Suche mit Verfügbarkeit',
          'QR-Code-Generierung für Rezept',
          'End-to-End-Verschlüsselung',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      UserStory(
        projectId: project.id,
        sprintId: null,
        title: 'Medikamenten-Erinnerung mit Smart Notifications',
        description: 'Patienten erhalten automatische Erinnerungen zur Medikamenteneinnahme basierend auf ihrem Medikationsplan.',
        storyPoints: 5,
        priority: StoryPriority.medium,
        status: StoryStatus.todo,
        acceptanceCriteria: [
          'Medikationsplan anlegen und pflegen',
          'Zeitbasierte Push-Notifications',
          'Bestätigung der Einnahme',
          'Statistik über Einnahme-Compliance',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
      ),
      UserStory(
        projectId: project.id,
        sprintId: null,
        title: 'Dark Mode für App implementieren',
        description: 'Die gesamte App soll einen optionalen Dark Mode unterstützen für bessere Nutzbarkeit bei Nacht.',
        storyPoints: 3,
        priority: StoryPriority.low,
        status: StoryStatus.todo,
        acceptanceCriteria: [
          'Theme-Switching in Settings',
          'Alle Screens im Dark Mode designt',
          'System-Theme automatisch übernehmen',
          'Persistierung der Einstellung',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      UserStory(
        projectId: project.id,
        sprintId: null,
        title: 'Export von Gesundheitsdaten als FHIR-konform',
        description: 'Patienten können ihre Gesundheitsdaten im standardisierten FHIR-Format exportieren.',
        storyPoints: 13,
        priority: StoryPriority.low,
        status: StoryStatus.todo,
        acceptanceCriteria: [
          'Export-Funktion im Profil',
          'FHIR R4 Standard-konform',
          'ZIP-Download mit allen Daten',
          'Datenschutz-Hinweis vor Export',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];
    for (final story in stories) {
      await _dbService.saveUserStory(story);
    }

    // Create meetings with messages
    await _seedSprintPlanningMeeting(project.id, sprint3.id, teamMembers);
    await _seedDailyStandupMeeting(project.id, sprint3.id, teamMembers);
    await _seedRetrospectiveMeeting(project.id, sprint2.id, teamMembers);

    // Create project context
    final contexts = [
      ProjectContext(
        projectId: project.id,
        contextType: ContextType.techStack,
        key: 'Backend',
        value: 'Node.js, Express, PostgreSQL, Redis',
      ),
      ProjectContext(
        projectId: project.id,
        contextType: ContextType.techStack,
        key: 'Frontend',
        value: 'Flutter, Provider, WebRTC für Video',
      ),
      ProjectContext(
        projectId: project.id,
        contextType: ContextType.techStack,
        key: 'Infrastructure',
        value: 'AWS (EC2, RDS, S3), Docker, GitHub Actions',
      ),
      ProjectContext(
        projectId: project.id,
        contextType: ContextType.definitionOfDone,
        key: 'Code Quality',
        value: 'Code reviewed, alle Tests grün, keine kritischen SonarQube-Issues',
      ),
      ProjectContext(
        projectId: project.id,
        contextType: ContextType.definitionOfDone,
        key: 'Documentation',
        value: 'API-Doku aktualisiert, User-Guide bei UI-Änderungen',
      ),
      ProjectContext(
        projectId: project.id,
        contextType: ContextType.teamInfo,
        key: 'Working Hours',
        value: 'Mo-Fr 9:00-17:00 CET, Daily um 9:30 Uhr',
      ),
      ProjectContext(
        projectId: project.id,
        contextType: ContextType.customNote,
        key: 'Compliance',
        value: 'DSGVO-konform, ISO 27001 in Vorbereitung, MDR Klasse IIa',
      ),
    ];
    for (final context in contexts) {
      await _dbService.saveProjectContext(context);
    }

    print('✅ Fantasy project "QuantumHealth" seeded successfully!');
  }

  Future<void> _seedSprintPlanningMeeting(
    String projectId,
    String sprintId,
    List<ProjectTeamMember> team,
  ) async {
    final meeting = Meeting(
      projectId: projectId,
      sprintId: sprintId,
      type: MeetingType.planning,
      date: DateTime.now().subtract(const Duration(days: 14)),
      durationMinutes: 180,
      participants: team.map((m) => m.name).toList(),
      summary: 'Sprint 3 Planning: Focus auf Terminbuchung und Videosprechstunden. Team committet auf 42 Story Points.',
      actionItems: [
        'Alice: API-Endpoints für Terminbuchung entwickeln',
        'Charlie: Videosprechstunden-UI implementieren',
        'Eve: E2E-Tests für kritische User Flows erstellen',
      ],
      sentimentScore: 8.0,
    );
    await _dbService.saveMeeting(meeting);

    final messages = [
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: 'Willkommen zum Sprint Planning für Sprint 3! 🚀\n\nWir haben heute 3 Stunden Zeit, um den Sprint zu planen. Lasst uns mit dem Sprint Goal starten.',
        messageType: MessageType.assistant,
        timestamp: meeting.date,
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Frank (PO): Unser Ziel ist es, dass Patienten eigenständig Termine buchen und Videosprechstunden durchführen können.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 2)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: '✅ Sprint Goal definiert: "Patienten können eigenständig Termine buchen und Videosprechstunden durchführen"\n\nWelche Stories möchtet ihr in den Sprint aufnehmen?',
        messageType: MessageType.assistant,
        timestamp: meeting.date.add(const Duration(minutes: 3)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Alice: Ich schlage vor: Vitalparameter-Erfassung (8 SP), Patientenhistorie für Ärzte (13 SP), Terminbuchung (13 SP) und Symptom-Checker (8 SP). Das wären 42 Story Points.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 10)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: '📊 Geplante Kapazität: 42 Story Points\nDas entspricht eurer durchschnittlichen Velocity. Gute Planung!',
        messageType: MessageType.analysis,
        timestamp: meeting.date.add(const Duration(minutes: 11)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Charlie: Die Videosprechstunde wird komplex. Wir müssen WebRTC integrieren und eine stabile Verbindung sicherstellen.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 15)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Bob: Ich unterstütze Alice bei der API. Wir können parallel an Terminbuchung und Vitalparametern arbeiten.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 18)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: '✅ Sprint 3 Planning abgeschlossen!\n\n**Commitment:** 42 Story Points\n**Team Sentiment:** 8/10 - Das Team ist motiviert und gut vorbereitet.\n\nViel Erfolg im Sprint! 💪',
        messageType: MessageType.assistant,
        timestamp: meeting.date.add(const Duration(minutes: 180)),
      ),
    ];
    for (final msg in messages) {
      await _dbService.saveMeetingMessage(msg);
    }
  }

  Future<void> _seedDailyStandupMeeting(
    String projectId,
    String sprintId,
    List<ProjectTeamMember> team,
  ) async {
    final meeting = Meeting(
      projectId: projectId,
      sprintId: sprintId,
      type: MeetingType.daily,
      date: DateTime.now().subtract(const Duration(days: 3)),
      durationMinutes: 15,
      participants: team.map((m) => m.name).toList(),
      summary: 'Daily Standup Tag 8: Vitalparameter und Patientenhistorie sind done. Video-Integration hat Performance-Issues.',
      actionItems: [
        'Alice: WebRTC Performance-Probleme mit DevOps Team klären',
        'Eve: Integrationstests für Terminbuchung starten',
      ],
      sentimentScore: 6.5,
    );
    await _dbService.saveMeeting(meeting);

    final messages = [
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: 'Guten Morgen zum Daily Standup! ☀️\nWer möchte starten?',
        messageType: MessageType.assistant,
        timestamp: meeting.date,
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Alice: Gestern habe ich die API für Vitalparameter finalisiert. Heute kümmere ich mich um die WebRTC-Integration. Blocker: Performance ist noch nicht optimal.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 1)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: '⚠️ Blocker erkannt: Performance-Issues bei WebRTC-Integration\nSoll ich einen Termin mit dem DevOps-Team koordinieren?',
        messageType: MessageType.warning,
        timestamp: meeting.date.add(const Duration(minutes: 2)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Bob: Patientenhistorie ist fertig und getestet. Heute starte ich mit dem Symptom-Checker.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 3)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Charlie: Frontend für Terminbuchung ist zu 70% fertig. Die Kalenderansicht funktioniert, jetzt kommt die Buchungslogik.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 5)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Diana: Ich helfe Charlie bei der Terminbuchung. Gestern haben wir die UI-Komponenten fertiggestellt.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 7)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Eve: Tests für Vitalparameter sind grün. Heute plane ich die Integrationstests für Terminbuchung.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 9)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: '📊 Daily Summary:\n✅ 2 Stories Done\n🔄 2 Stories In Progress\n⚠️ 1 Blocker\n\n**Sentiment:** 6.5/10 - Team arbeitet gut, aber Performance-Issue sollte priorisiert werden.',
        messageType: MessageType.analysis,
        timestamp: meeting.date.add(const Duration(minutes: 15)),
      ),
    ];
    for (final msg in messages) {
      await _dbService.saveMeetingMessage(msg);
    }
  }

  Future<void> _seedRetrospectiveMeeting(
    String projectId,
    String sprintId,
    List<ProjectTeamMember> team,
  ) async {
    final meeting = Meeting(
      projectId: projectId,
      sprintId: sprintId,
      type: MeetingType.retrospective,
      date: DateTime.now().subtract(const Duration(days: 15)),
      durationMinutes: 90,
      participants: team.map((m) => m.name).toList(),
      summary: 'Sprint 2 Retrospective: Positive Stimmung, gute Pair-Programming-Sessions. Verbesserungspotenzial bei Code-Reviews.',
      actionItems: [
        'Daily Code-Review-Slot (14:00-14:30) einführen',
        'Pair-Programming mindestens 2x pro Woche beibehalten',
        'Retrospektive-Action-Items im nächsten Sprint nachverfolgen',
      ],
      sentimentScore: 7.5,
    );
    await _dbService.saveMeeting(meeting);

    final messages = [
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: 'Willkommen zur Sprint 2 Retrospektive! 🎯\n\nWir schauen gemeinsam auf die letzten 2 Wochen zurück.\n\n**Was lief gut?**',
        messageType: MessageType.assistant,
        timestamp: meeting.date,
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Charlie: Die Pair-Programming-Sessions mit Diana waren super produktiv. Wir haben viel voneinander gelernt.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 5)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Bob: Wir haben fast alle Story Points geschafft (44 von 45). Das zeigt, dass unsere Schätzungen besser werden.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 8)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Eve: Die Test-Automatisierung zahlt sich aus. Wir finden Bugs früher.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 10)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: '✅ Das lief gut:\n- Effektive Pair-Programming-Sessions\n- Präzisere Schätzungen (98% Velocity)\n- Frühe Bug-Erkennung durch Tests\n\n**Was können wir verbessern?**',
        messageType: MessageType.assistant,
        timestamp: meeting.date.add(const Duration(minutes: 15)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Alice: Code-Reviews dauern manchmal zu lange. PRs liegen teilweise 2 Tage rum.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 18)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Diana: Stimmt. Wir könnten einen festen Daily-Slot für Code-Reviews einführen.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 20)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: true,
        content: 'Frank: Dokumentation der neuen Features war teilweise lückenhaft. Wir sollten das in die Definition of Done aufnehmen.',
        messageType: MessageType.user,
        timestamp: meeting.date.add(const Duration(minutes: 25)),
      ),
      MeetingMessage(
        meetingId: meeting.id,
        isUser: false,
        content: '📋 **Action Items für Sprint 3:**\n\n1. Daily Code-Review-Slot (14:00-14:30) einführen\n2. Pair-Programming mindestens 2x pro Woche beibehalten\n3. Dokumentation in Definition of Done ergänzen\n\n**Team Sentiment:** 7.5/10 - Positiv und motiviert! 💪',
        messageType: MessageType.analysis,
        timestamp: meeting.date.add(const Duration(minutes: 90)),
      ),
    ];
    for (final msg in messages) {
      await _dbService.saveMeetingMessage(msg);
    }
  }
}
