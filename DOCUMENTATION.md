# 📖 AgileAI – Technische Dokumentation

## Inhaltsverzeichnis

1. [Projektübersicht](#1-projektübersicht)
2. [Architektur & Technologie-Stack](#2-architektur--technologie-stack)
3. [Projektstruktur](#3-projektstruktur)
4. [Datenmodelle](#4-datenmodelle)
5. [Services](#5-services)
6. [State Management & Provider](#6-state-management--provider)
7. [Screens & Navigation](#7-screens--navigation)
8. [Widgets](#8-widgets)
9. [KI-Integration](#9-ki-integration)
10. [Lokale Datenspeicherung](#10-lokale-datenspeicherung)
11. [Plattform-Konfiguration (macOS)](#11-plattform-konfiguration-macos)
12. [Konfiguration & Anpassung](#12-konfiguration--anpassung)
13. [Setup & Installation](#13-setup--installation)
14. [Bekannte Einschränkungen & Hinweise](#14-bekannte-einschränkungen--hinweise)
15. [Fehlerbehebung](#15-fehlerbehebung)

---

## 1. Projektübersicht

**AgileAI** ist eine plattformübergreifende Flutter-Applikation, die als intelligenter virtueller Scrum Master fungiert. Sie unterstützt agile Teams dabei, Scrum-Zeremonien durchzuführen, Sentiment zu analysieren, Sprint Goals zu generieren, Retrospektiven auszuwerten und den Backlog zu verwalten – alles durch den Einsatz von Google Gemini als KI-Backend.

### Kernfunktionen

| Funktion | Beschreibung |
|---|---|
| **AI-Chat** | Freie Konversation mit dem KI-Scrum-Master |
| **Scrum-Zeremonien** | Geführte Durchführung aller 5 Scrum-Events mit Tageshinweisen |
| **Backlog-Management** | CRUD für User Stories, Story Point Schätzung, INVEST-Validierung, Sprint-Zuweisung |
| **Sprint-View** | Aktueller Sprint mit Kapazitätsanzeige (Story Points gesamt/erledigt) |
| **Team-Verwaltung** | CRUD für Teammitglieder mit Rolle und Avatar |
| **Analytics-Dashboard** | Sentiment-Verlauf, Velocity-Chart, Team Health Score |
| **Zeremonien-Log** | Alle vergangenen Zeremonien filtern und Details anzeigen |
| **Planning Poker** | 5-Phasen-Schätzworkshop mit KI-Moderation |
| **Scrum-Glossar** | Offline-Lexikon mit allen Scrum-Begriffen (durchsuchbar) |
| **Spracheingabe** | Spracherkennung für Nachrichten (Speech-to-Text) |
| **Chat-Export** | Konversationsverlauf teilen via System-Share-Sheet |
| **Definition of Done** | KI-generierte DoD auf Basis von Projekt- und Technologie-Kontext |
| **Scrum-Reife-Bewertung** | 5-Fragen-Assessment mit KI-Auswertung |
| **Retro-Muster** | Langzeitanalyse aller Retrospektiven auf wiederkehrende Themen |
| **Onboarding** | Erststart-Einrichtung mit API Key, Sprache, Modell und Persona |
| **Einstellungen** | Sprache, Gemini-Modell, Persona, aktuelle Sprint-Nummer, Datenlöschung |

---

## 2. Architektur & Technologie-Stack

### Architekturmuster

Die App folgt dem **Provider-basierten MVVM-Pattern** mit einem `ChangeNotifier` je fachlichem Kontext:

```
Screens/Widgets
      ↕  (Consumer<X> / context.read<X>())
Providers (ChangeNotifier)
  ├── ChatProvider       → AiService, StorageService
  ├── BacklogProvider    → DatabaseService, AiService (via SettingsProvider)
  ├── TeamProvider       → StorageService
  ├── AnalyticsProvider  → StorageService, DatabaseService
  └── SettingsProvider   → StorageService
              ↕
Services
  ├── AiService          → Google Gemini API
  ├── StorageService     → SharedPreferences
  └── DatabaseService    → SQLite (sqflite)
```

### Provider-Hierarchie in `main.dart`

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(create: (_) => TeamProvider()),
    ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
    ChangeNotifierProxyProvider<SettingsProvider, ChatProvider>(
      create: (ctx) => ChatProvider(ctx.read<SettingsProvider>()),
      update: (_, settings, prev) => prev ?? ChatProvider(settings),
    ),
    ChangeNotifierProxyProvider<SettingsProvider, BacklogProvider>(
      create: (ctx) => BacklogProvider(ctx.read<SettingsProvider>()),
      update: (_, settings, prev) => prev ?? BacklogProvider(settings),
    ),
  ],
  child: _AppRoot(),
)
```

`_AppRoot` prüft nach dem Laden von `SettingsProvider` ob Onboarding noch aussteht und routet entsprechend.

### Technologie-Stack

| Bereich | Paket | Version |
|---|---|---|
| Framework | Flutter | 3.x |
| Sprache | Dart | ^3.10.7 |
| State Management | `provider` | ^6.1.1 |
| LLM / KI | `google_generative_ai` | ^0.4.0 |
| Lokale Speicherung (KV) | `shared_preferences` | ^2.2.2 |
| Lokale Datenbank (SQL) | `sqflite` | ^2.3.2 |
| JSON-Serialisierung | `json_annotation` / `json_serializable` | ^4.11.0 / ^6.7.1 |
| Code-Generierung | `build_runner` | ^2.4.9 |
| Diagramme | `fl_chart` | ^0.68.0 |
| Markdown-Rendering | `flutter_markdown` | ^0.7.7 |
| Chat-Export | `share_plus` | ^9.0.0 |
| Spracheingabe | `speech_to_text` | ^6.6.2 |
| UUID-Generierung | `uuid` | ^4.3.3 |
| Datum/Zeit | `intl` | ^0.19.0 |
| UI | Material Design 3 | – |

---

## 3. Projektstruktur

```
agile_ai/
├── lib/
│   ├── main.dart                        # Einstiegspunkt, MultiProvider, _AppRoot, Routing
│   ├── config/
│   │   └── app_config.dart              # API Key, Modell, Prompts, Zeremonien, Glossar
│   ├── models/
│   │   ├── message.dart / .g.dart       # Chat-Nachricht mit MessageType
│   │   ├── scrum_ceremony.dart / .g.dart # Zeremonien-Datensatz
│   │   ├── backlog_item.dart / .g.dart  # Backlog-Item mit Status, Sprint, StoryPoints
│   │   ├── sprint_data.dart / .g.dart   # Sprint-Metadaten
│   │   └── team_member.dart / .g.dart   # Teammitglied
│   ├── providers/
│   │   ├── chat_provider.dart           # Chat-State, alle KI-Aktionen
│   │   ├── backlog_provider.dart        # Backlog-State, CRUD, Schätzung
│   │   ├── settings_provider.dart       # App-Einstellungen, AiService-Factory
│   │   ├── analytics_provider.dart      # Sentiment-, Velocity-, Health-Daten
│   │   └── team_provider.dart           # Team-CRUD
│   ├── screens/
│   │   ├── main_screen.dart             # NavigationBar-Shell (5 Tabs, IndexedStack)
│   │   ├── chat_screen.dart             # Chat-Tab: Konversation + Menü + Sprache
│   │   ├── backlog_screen.dart          # Backlog- + Sprint-Tab mit KI-Aktionen
│   │   ├── analytics_screen.dart        # Dashboard: Charts, Health Score, Velocity
│   │   ├── ceremonies_screen.dart       # Zeremonien-Log mit Filter und Details
│   │   ├── settings_screen.dart         # Sprache, Modell, Persona, Sprint, Reset
│   │   ├── team_screen.dart             # Teammitglieder-CRUD
│   │   ├── glossary_screen.dart         # Offline-Scrum-Glossar (durchsuchbar)
│   │   ├── more_screen.dart             # Mehr-Tab: Links zu Einstellungen/Team/…
│   │   ├── onboarding_screen.dart       # Erststart-Einrichtung
│   │   └── planning_poker_screen.dart   # 5-Phasen Planning Poker mit KI
│   ├── services/
│   │   ├── ai_service.dart              # Gemini API: Chat-Session + Einzelanfragen
│   │   ├── storage_service.dart         # SharedPreferences: Nachrichten, Zeremonien
│   │   └── database_service.dart        # SQLite: Backlog, Sprints, Team
│   └── widgets/
│       ├── message_bubble.dart          # Chat-Bubble mit Typ-Label + Icon
│       ├── ceremony_selector.dart       # Bottom Sheet: Zeremonien-Auswahl
│       ├── backlog_item_card.dart        # Backlog-Karte mit Aktions-Buttons
│       └── charts_widget.dart           # Wiederverwendbare Chart-Komponenten
├── macos/Runner/
│   ├── DebugProfile.entitlements        # Sandbox: Netzwerk + Mikrofon (Debug)
│   └── Release.entitlements             # Sandbox: Netzwerk (Release)
├── assets/
│   ├── images/
│   └── icons/
├── pubspec.yaml
├── README.md
├── DOCUMENTATION.md                     # Diese Datei
├── IDEAS.md                             # Feature-Ideen mit Umsetzungsstatus
└── IMPLEMENTATION.md                    # Implementierungsnotizen
```

---

## 4. Datenmodelle

Alle Modelle liegen in `lib/models/` und nutzen `@JsonSerializable` mit generierten `.g.dart`-Dateien.
Nach jeder Modelländerung muss folgender Befehl ausgeführt werden:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4.1 `Message`

```dart
class Message {
  final String id;           // UUID v4
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;
}
```

#### `MessageType` Enum – steuert Bubble-Farbe und Label-Icon

| Wert | Label | Farbe | Icon |
|---|---|---|---|
| `text` | – | Grau | `Icons.chat` |
| `ceremony` | Zeremonie | Lila | `Icons.event` |
| `insight` | Insights | Blau | `Icons.insights` |
| `goal` | Sprint-Ziel | Grün | `Icons.flag` |
| `sentiment` | Sentiment | Orange | `Icons.sentiment_satisfied` |
| `actionItem` | Action Items | Teal | `Icons.check_circle_outline` |
| `impediment` | Impediment | Rot | `Icons.block` |
| `risk` | Risiko | Amber | `Icons.warning_amber_outlined` |
| `assessment` | Assessment | Indigo | `Icons.assessment` |
| `tip` | Tipp | Cyan | `Icons.lightbulb_outline` |

### 4.2 `ScrumCeremony`

```dart
class ScrumCeremony {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> participants;
  final List<String> notes;
  final String? summary;
  final Map<String, dynamic>? sentiment;
}
```

### 4.3 `BacklogItem`

```dart
class BacklogItem {
  final String id;
  String title;
  String description;
  int? storyPoints;
  BacklogStatus status;     // todo | inProgress | done | removed
  int? sprintNumber;        // null = Backlog, 0 = explizit aus Sprint entfernt
  List<String> acceptanceCriteria;
  final DateTime createdAt;
}
```

`copyWith` unterstützt `clearSprintNumber: true` um `sprintNumber` explizit auf `null` zu setzen.

### 4.4 `TeamMember`

```dart
class TeamMember {
  final String id;
  String name;
  String role;
  String? avatarUrl;
}
```

### 4.5 `SprintData`

```dart
class SprintData {
  final int sprintNumber;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalPoints;
  final int completedPoints;
}
```

---

## 5. Services

### 5.1 `AiService` (`lib/services/ai_service.dart`)

Wrapper um die Google Gemini API. Wird von `SettingsProvider` instanziiert und bei Modell-/Persona-Änderungen neu erstellt.

#### Zwei Nutzungsmuster

| Modus | Methoden | Beschreibung |
|---|---|---|
| **Persistente Chat-Session** (`_chat`) | `sendMessage`, `facilitateCeremony` | Konversationsverlauf bleibt erhalten |
| **Stateless Einzelanfragen** (`_model.generateContent`) | `analyzeSentiment`, `generateSprintGoal`, `analyzeRetrospective`, `evaluateScrumMaturity`, `generateDefinitionOfDone`, `analyzeRetroPatterns`, `getDailyTip`, alle Backlog-Methoden | Kein Kontext, direkte Anfrage |

#### Alle Methoden

| Methode | Rückgabe | Beschreibung |
|---|---|---|
| `sendMessage(text)` | `Future<String>` | Freie Konversation |
| `facilitateCeremony(type, ctx)` | `Future<String>` | Zeremonie moderieren |
| `analyzeSentiment(text)` | `Future<String>` | Score 1–10 + Begründung |
| `generateSprintGoal(items)` | `Future<String>` | Ziel aus Backlog-Items |
| `analyzeRetrospective(points)` | `Future<String>` | Zusammenfassung + Aktionen |
| `evaluateScrumMaturity(answers)` | `Future<String>` | Reife-Assessment-Auswertung |
| `generateDefinitionOfDone(ctx, stack)` | `Future<String>` | DoD generieren |
| `analyzeRetroPatterns(summaries)` | `Future<String>` | Langzeittrends erkennen |
| `getDailyTip(ceremony)` | `Future<String>` | Tipp für aktuelle Zeremonie |
| `estimateBacklogItem(title, desc)` | `Future<String>` | Story Point Schätzung |
| `generateAcceptanceCriteria(title, desc)` | `Future<String>` | Akzeptanzkriterien |
| `validateInvest(title, desc)` | `Future<String>` | INVEST-Kriterien-Check |
| `resetChat()` | `void` | Chat-Session zurücksetzen |

#### `_fallback()` Konvention
```dart
String _fallback() => 'Fehler: KI nicht verfügbar'; // MUSS synchron bleiben
```
Wird mit `??` genutzt, daher kein `async`.

### 5.2 `StorageService` (`lib/services/storage_service.dart`)

`SharedPreferences`-basierter Key-Value-Store für Chat-Daten und Einstellungen.

| Schlüssel | Inhalt |
|---|---|
| `"messages"` | JSON-Liste aller `Message`-Objekte |
| `"ceremonies"` | JSON-Liste aller `ScrumCeremony`-Objekte |
| `"api_key"` | Gemini API Key |
| `"language"` | `"de"` oder `"en"` |
| `"model"` | Gemini-Modellname |
| `"persona"` | KI-Persona |
| `"onboarding_done"` | `"true"` nach Onboarding |
| `"current_sprint"` | Aktuelle Sprint-Nummer als String |

### 5.3 `DatabaseService` (`lib/services/database_service.dart`)

SQLite-Datenbank (via `sqflite`) für strukturierte Daten.

| Tabelle | Inhalt |
|---|---|
| `backlog_items` | Alle Backlog-Items |
| `sprints` | Sprint-Metadaten |
| `team_members` | Teammitglieder |

---

## 6. State Management & Provider

### 6.1 `SettingsProvider`

Verwaltet persistente App-Einstellungen. Wird als erstes geladen (`isLoaded`-Flag).

```dart
bool get isLoaded         // true, sobald SharedPreferences geladen
String get language       // "de" | "en"
String get geminiModel    // z.B. "gemini-2.0-flash"
String get persona        // z.B. "professionell"
int get currentSprintNumber
AiService get aiService   // wird bei Modell-/Persona-Änderung neu instanziiert
bool get onboardingDone
```

### 6.2 `ChatProvider`

Einzig abhängiger Provider (`ChangeNotifierProxyProvider` von `SettingsProvider`).

**State:**
```dart
List<Message> _messages
bool _isLoading
ScrumCeremony? _currentCeremony
```

**Methoden-Übersicht:**

| Methode | Beschreibung |
|---|---|
| `sendMessage(text)` | Nachricht senden, KI antwortet |
| `startCeremony(name)` | Zeremonie starten + Kontext-Gedächtnis injizieren + Tages-Tipp |
| `endCeremony()` | Zeremonie beenden, in StorageService speichern |
| `analyzeSentiment(text)` | Sentiment-Analyse starten |
| `generateSprintGoal(items)` | Sprint-Ziel generieren |
| `analyzeRetrospective(points)` | Retro auswerten |
| `evaluateScrumMaturity(answers)` | Reife-Assessment |
| `generateDefinitionOfDone(ctx, stack)` | DoD erstellen |
| `analyzeRetroPatterns()` | Alle Retros analysieren |
| `clearMessages()` | Chat-Verlauf leeren |

**Fehlerbehandlung:** Jede `async`-Methode wrappet den KI-Aufruf in try/catch und hängt bei Fehler eine Fehlernachricht als `Message(isUser: false)` an. `_isLoading` wird immer im `finally`-Block zurückgesetzt.

**`_runAi` Hilfsmethode:**
```dart
Future<void> _runAi(Future<String> Function() fn, {MessageType type}) async {
  _isLoading = true; notifyListeners();
  try {
    final result = await fn();
    _messages.add(Message(text: result, isUser: false, type: type));
    await _storageService.saveMessages(_messages);
  } catch (e) {
    _messages.add(Message(text: 'Fehler: $e', isUser: false));
  } finally {
    _isLoading = false; notifyListeners();
  }
}
```

### 6.3 `BacklogProvider`

```dart
List<BacklogItem> get backlogItems        // Items ohne Sprint (sprintNumber == null)
List<BacklogItem> get currentSprintItems  // Items mit sprintNumber == currentSprint
int get totalPointsCurrentSprint
int get completedPointsCurrentSprint
```

**KI-Aktionen** delegieren an `_settingsProvider.aiService` und geben einen `String` zurück (kein direktes Hinzufügen zum Chat).

**Sprint-Zuweisung:**
```dart
await backlog.assignToSprint(item.id, sprintNumber); // 0 = aus Sprint entfernen
```

### 6.4 `TeamProvider`

Einfacher CRUD-Provider für `TeamMember`. Lädt beim Start aus `DatabaseService`.

### 6.5 `AnalyticsProvider`

Aggregiert Daten aus beiden Speicher-Backends:

```dart
List<ScrumCeremony> get allCeremonies   // aus SharedPreferences
List<SprintData>    get sprintHistory   // aus SQLite
double              get healthScore     // berechnet aus Sentiment + Velocity
```

---

## 7. Screens & Navigation

### 7.1 `MainScreen` – NavigationBar-Shell

```
NavigationBar (Bottom)
├── [0] Chat           → ChatScreen
├── [1] Backlog        → BacklogScreen
├── [2] Analytics      → AnalyticsScreen
├── [3] Zeremonien     → CeremoniesScreen
└── [4] Mehr           → MoreScreen
```

Nutzt `IndexedStack`: Alle Screens bleiben im Speicher und verlieren ihren State nicht beim Tab-Wechsel.

### 7.2 `ChatScreen`

Haupt-Interaktionsfläche.

**Input-Bar:**
- 📅 Zeremonien-Button → `CeremonySelector` Bottom Sheet
- 🎤 Mikrofon-Button (nur wenn `_speechAvailable`) → `_toggleSpeech()`; rot bei aktiver Aufnahme
- Textfeld
- ➤ Senden-Button

**Options-Menü (⋮):**
- Sentiment analysieren
- Sprint-Ziel generieren
- Retrospektive analysieren
- Definition of Done erstellen
- Scrum-Reife bewerten
- Retrospektiven-Muster
- Chat exportieren

**Spracheingabe (`speech_to_text`):**
- Initialisierung in `initState`; `_speechAvailable` steuert Sichtbarkeit des Buttons
- `_toggleSpeech()`: startet/stoppt Aufnahme, fügt erkannten Text in Textfeld ein
- Dispose: `_speech.stop()` im `dispose()`
- macOS: benötigt `com.apple.security.device.microphone` in Entitlements

### 7.3 `BacklogScreen`

**Backlog-Tab:**
- `Dismissible`-Liste (Wischen → Löschen)
- `BacklogItemCard` mit Aktionen: Status ändern, KI-Schätzung, Akzeptanzkriterien, INVEST, Sprint zuweisen
- Sprint-Zuweisung: Dialog mit „aktueller Sprint", „nächster Sprint", „aus Sprint entfernen"

**Sprint-Tab:**
- Header mit Sprint-Nummer, Gesamt-SP, Erledigte-SP, Fortschritt-Prozent
- Liste der Items im aktuellen Sprint

### 7.4 `AnalyticsScreen`

- **Team Health Score** (berechnet) mit farbiger Anzeige
- **Sentiment-Verlauf** (Liniendiagramm, `fl_chart`)
- **Velocity-Chart** (Balkendiagramm, letzte 5 Sprints)
- **Velocity eingeben** Dialog für manuelle Sprint-Nacherfassung

### 7.5 `CeremoniesScreen`

- Filter-Chips: Alle / Daily / Planning / Review / Retrospektive / Refinement
- Karten-Liste mit Datum, Dauer, Teilnehmeranzahl
- Bottom Sheet mit vollständigen Details (Notizen, Zusammenfassung, Sentiment)

### 7.6 `MoreScreen`

Hub für sekundäre Screens:
- ⚙️ Einstellungen → `SettingsScreen`
- 👥 Team → `TeamScreen`
- 📚 Glossar → `GlossaryScreen`
- 🃏 Planning Poker → `PlanningPokerScreen`

### 7.7 `SettingsScreen`

- Sprache: Radio-Buttons (Deutsch / English)
- Gemini-Modell: Radio-Buttons (Flash Lite / Flash / Flash 2.0 / Pro)
- KI-Persona: Radio-Buttons (professionell / locker / streng / coach)
- Aktuelle Sprint-Nummer: Stepper (+/–)
- Alle Daten zurücksetzen: Bestätigungs-Dialog

### 7.8 `TeamScreen`

- Liste aller Teammitglieder mit Avatar-Initialen, Name, Rolle
- FAB → Mitglied hinzufügen (Name + Rolle)
- Antippen → Bearbeiten-Dialog
- Löschen via Bestätigungs-Dialog

### 7.9 `GlossaryScreen`

- Vollständig offline (keine API)
- Daten aus `AppConfig.knowledgeBase`
- Suchfeld filtert Einträge in Echtzeit
- Kategorien als Abschnitte

### 7.10 `PlanningPokerScreen`

5-Phasen-Flow:

| Phase | Beschreibung |
|---|---|
| 1 – Eingabe | Story Title + Beschreibung eingeben |
| 2 – KI-Schätzung | KI schätzt Story Points (verdeckt) |
| 3 – Team-Voting | Jedes Teammitglied gibt seinen Schätzwert ein |
| 4 – Moderation | KI kommentiert die Schätzungen und Divergenz |
| 5 – Ergebnis | Finale Entscheidung (Median) wird angezeigt |

### 7.11 `OnboardingScreen`

- API Key eingeben (mit Validierung)
- Sprache wählen
- Modell wählen
- Persona wählen
- Fertigstellen → `SettingsProvider.completeOnboarding()` → `MainScreen`

---

## 8. Widgets

### 8.1 `MessageBubble`

| Element | Nutzer-Nachricht | KI-Nachricht |
|---|---|---|
| Ausrichtung | Rechtsbündig | Linksbündig |
| Hintergrund | `primaryColor` | Abhängig von `MessageType` |
| Textfarbe | Weiß | Schwarz87 |
| Typ-Label | – | Icon + Bezeichnung (wenn ≠ `text`) |
| Zeitstempel | Weiß70 | Schwarz45 |
| Max-Breite | 75% der Bildschirmbreite | 75% |

### 8.2 `CeremonySelector`

Bottom Sheet aus `SingleChildScrollView` + `ListTile`-Karten.
Alle Zeremonien aus `AppConfig.ceremonies` werden mit Icon, Titel und Kurzbeschreibung dargestellt.

### 8.3 `BacklogItemCard`

Aktions-Buttons (optional via Callbacks):
- Status ändern (`onTap`)
- KI-Schätzung (`onEstimate`)
- Akzeptanzkriterien (`onAcceptanceCriteria`)
- INVEST-Validierung (`onInvest`)
- Sprint zuweisen (`onAssignSprint`) – zeigt „S{n}" wenn bereits in Sprint
- Löschen (`onDelete`)

### 8.4 `ChartsWidget`

Wiederverwendbare Diagramm-Komponenten auf Basis von `fl_chart`.

---

## 9. KI-Integration

### System-Prompt

Definiert in `AppConfig.systemPrompt`. Wird beim Start des `AiService` als erste `Content`-Nachricht in die Chat-History eingefügt. Durch die Persona-Einstellung kann der Ton angepasst werden (professionell / locker / streng / coach).

### Modell-Konfiguration

```dart
GenerationConfig(
  temperature: 0.7,
  topK: 40,
  topP: 0.95,
  maxOutputTokens: 2048,
)
```

### Verfügbare Modelle (konfigurierbar in Einstellungen)

| Modell-ID | Empfehlung |
|---|---|
| `gemini-2.0-flash-lite` | Schnellstes Modell, höchste Free-Tier-Limits |
| `gemini-2.0-flash` | Gutes Gleichgewicht Qualität/Geschwindigkeit |
| `gemini-2.5-flash` | Aktuellstes Flash-Modell |
| `gemini-2.5-pro` | Höchste Qualität |

### Kontext-Gedächtnis in Zeremonien

Beim Start einer Zeremonie injiziert `ChatProvider.startCeremony()` einen Kontext-Block in das Gespräch:

```
[Kontext]
Aktive Zeremonie: Sprint Planning
Team: Alice (Developer), Bob (Designer)
Aktueller Sprint: #5
Letzte Zeremonie: Daily Standup (vor 2 Tagen)
[/Kontext]
```

---

## 10. Lokale Datenspeicherung

### SharedPreferences (`StorageService`)

Einfache Key-Value-Paare für Nachrichten, Zeremonien und Einstellungen.
JSON-Serialisierung via `json_serializable`.

### SQLite (`DatabaseService`)

Strukturierte relationale Daten für Backlog und Team. Tabellen:
- `backlog_items`: id, title, description, storyPoints, status, sprintNumber, acceptanceCriteria (JSON), createdAt
- `sprints`: sprintNumber, startDate, endDate, totalPoints, completedPoints
- `team_members`: id, name, role, avatarUrl

### Datenschutz

Alle Daten bleiben lokal auf dem Gerät. Die einzigen externen Verbindungen sind KI-Anfragen an die Google Gemini API. Es werden keine Nutzerdaten an Dritte weitergegeben.

---

## 11. Plattform-Konfiguration (macOS)

### Netzwerk-Entitlement (Pflicht für API-Anfragen)

Ohne `com.apple.security.network.client` schlagen alle Gemini-Anfragen kommentarlos fehl.

**`macos/Runner/DebugProfile.entitlements`** und **`Release.entitlements`:**
```xml
<key>com.apple.security.network.client</key><true/>
```

### Mikrofon-Entitlement (für Speech-to-Text)

Für die Spracheingabe wird zusätzlich benötigt:

**`macos/Runner/DebugProfile.entitlements`:**
```xml
<key>com.apple.security.device.microphone</key><true/>
```

> Nach Entitlement-Änderungen ist immer ein vollständiger Neustart (`flutter run`) erforderlich, kein Hot Restart.

---

## 12. Konfiguration & Anpassung

Zentrale Konfiguration in `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String geminiApiKey = 'DEIN_API_KEY_HIER'; // ⚠️ nicht committen!
  static const String appName = 'AgileAI';
  static const String appVersion = '1.0.0';
  static const String defaultModel = 'gemini-2.0-flash';
  static const String systemPrompt = '...';
  static const List<String> ceremonies = [...];
  static const List<Map<String, dynamic>> ceremonyDetails = [...];
  static const List<Map<String, dynamic>> knowledgeBase = [...]; // Glossar-Daten
}
```

### Neues MessageType hinzufügen

1. Enum-Wert in `lib/models/message.dart` ergänzen
2. `_getBackgroundColor()` in `message_bubble.dart` erweitern
3. `_getIcon()` in `message_bubble.dart` erweitern
4. `_getTypeLabel()` in `message_bubble.dart` ergänzen

---

## 13. Setup & Installation

### Voraussetzungen

- Flutter SDK ≥ 3.10.7
- Dart SDK
- Google Gemini API Key → [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

### Schritt-für-Schritt

```bash
# 1. Dependencies installieren
flutter pub get

# 2. JSON-Serialisierungscode generieren
dart run build_runner build --delete-conflicting-outputs

# 3. API Key eintragen (lib/config/app_config.dart)
#    oder über das Onboarding beim ersten Start eingeben

# 4. App starten
flutter run -d macos     # macOS
flutter run -d windows   # Windows
flutter run              # Android/iOS
```

### Linting & Tests

```bash
flutter analyze   # Statische Analyse
flutter test      # Unit- und Widget-Tests
```

---

## 14. Bekannte Einschränkungen & Hinweise

| Thema | Details |
|---|---|
| **API Key Sicherheit** | Key darf nie in öffentliche Repos committed werden. Für Produktion: Environment Variables nutzen. |
| **Free-Tier Rate Limits** | Bei `exceeded your quota`: kurz warten, sparsameres Modell wählen. |
| **Internet erforderlich** | Alle KI-Funktionen benötigen aktive Verbindung (Glossar ist offline). |
| **macOS Mikrofon** | Speech-to-Text benötigt `com.apple.security.device.microphone` in Debug-Entitlements. |
| **Hot Reload vs. Restart** | Dart-Änderungen: Hot Restart (`R`). Entitlements/pubspec-Änderungen: vollständiger Neustart. |
| **`*.g.dart` Dateien** | Niemals manuell bearbeiten. Immer `build_runner` nutzen. |
| **`_fallback()` muss synchron bleiben** | Wird mit `??` verwendet, daher kein `async` erlaubt. |
| **Radio-Buttons (Flutter ≥ 3.33)** | `groupValue`/`onChanged` sind deprecated. Migration auf `RadioGroup` bei nächstem Refactoring. |
| **`flutter_markdown` discontinued** | Paket wird nicht mehr gewartet. Migration zu `flutter_markdown_plus` empfohlen. |

---

## 15. Fehlerbehebung

| Fehler | Ursache | Lösung |
|---|---|---|
| `connection failed` | macOS Netzwerk-Entitlement fehlt | `com.apple.security.network.client` in beide Entitlements-Dateien, neu bauen |
| `model not found for api version` | Falscher Modellname | Modellname in Einstellungen oder `app_config.dart` korrigieren |
| `exceeded your quota` | Rate Limit | 1 Minute warten; sparsameres Modell wählen |
| `type 'Null' is not a subtype` | JSON-Deserialisierung schlägt fehl | `build_runner` neu ausführen |
| `RenderFlex overflowed` | Column zu groß | In `SingleChildScrollView` wrappen |
| `Provider not found above widget tree` | Provider nicht in `main.dart` registriert | `MultiProvider`-Liste prüfen |
| Spracheingabe funktioniert nicht (macOS) | Mikrofon-Entitlement fehlt | `com.apple.security.device.microphone` in `DebugProfile.entitlements` |

---

*Dokumentation aktualisiert für AgileAI v1.1.0 – Stand nach vollständiger Feature-Implementierung*
