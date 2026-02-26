# 📖 AgileAI – Technische Dokumentation

## Inhaltsverzeichnis

1. [Projektübersicht](#1-projektübersicht)
2. [Architektur & Technologie-Stack](#2-architektur--technologie-stack)
3. [Projektstruktur](#3-projektstruktur)
4. [Datenmodelle](#4-datenmodelle)
5. [Services](#5-services)
6. [State Management](#6-state-management)
7. [UI-Schichten](#7-ui-schichten)
8. [KI-Integration](#8-ki-integration)
9. [Lokale Datenspeicherung](#9-lokale-datenspeicherung)
10. [Plattform-Konfiguration (macOS)](#10-plattform-konfiguration-macos)
11. [Konfiguration & Anpassung](#11-konfiguration--anpassung)
12. [Setup & Installation](#12-setup--installation)
13. [Bekannte Einschränkungen & Hinweise](#13-bekannte-einschränkungen--hinweise)
14. [Fehlerbehebung](#14-fehlerbehebung)

---

## 1. Projektübersicht

**AgileAI** ist eine plattformübergreifende Flutter-Applikation, die als intelligenter virtueller Scrum Master fungiert. Sie unterstützt agile Teams dabei, Scrum-Zeremonien durchzuführen, Sentiment zu analysieren, Sprint Goals zu generieren und Retrospektiven auszuwerten – alles durch den Einsatz eines Large Language Models (LLM) über die Google Gemini API.

### Kernfunktionen

| Funktion | Beschreibung |
|---|---|
| **AI-Chatbot** | Freie Konversation mit einem KI-gestützten Scrum Master |
| **Scrum-Zeremonien** | Geführte Durchführung aller 5 Scrum-Events |
| **Sentiment-Analyse** | Automatische Stimmungsbewertung von Meeting-Texten (Skala 1–10) |
| **Sprint Goal Generierung** | KI erstellt ein Sprint Goal auf Basis von Backlog Items |
| **Retrospektiven-Analyse** | Zusammenfassung und Handlungsempfehlungen aus Retro-Punkten |
| **Lokaler Chat-Verlauf** | Persistente Speicherung aller Nachrichten auf dem Gerät |
| **Dark/Light Mode** | Automatische Anpassung an das System-Theme |

---

## 2. Architektur & Technologie-Stack

### Architekturmuster

Die App folgt dem **Provider-Pattern** (MVVM-ähnlich):

```
UI (Widgets/Screens)
        ↕  (Consumer / context.read)
State Management (Provider / ChangeNotifier)
        ↕
Services (AI, Storage)
        ↕
External (Google Gemini API / SharedPreferences)
```

### Technologie-Stack

| Bereich | Technologie | Version |
|---|---|---|
| Framework | Flutter | 3.x |
| Sprache | Dart | ^3.10.7 |
| State Management | Provider | ^6.1.1 |
| LLM / KI | Google Gemini API (`google_generative_ai`) | ^0.4.0 |
| Lokale Speicherung | SharedPreferences | ^2.2.2 |
| JSON Serialisierung | json_annotation + json_serializable | ^4.11.0 / ^6.7.1 |
| UUID Generierung | uuid | ^4.3.3 |
| Datum/Zeit Formatierung | intl | ^0.19.0 |
| UI Design | Material Design 3 | – |

---

## 3. Projektstruktur

```
agile_ai/
├── lib/
│   ├── main.dart                   # App-Einstiegspunkt, Theme-Konfiguration
│   ├── config/
│   │   └── app_config.dart         # Zentrale Konfiguration (API Key, Modell, Prompts)
│   ├── models/
│   │   ├── message.dart            # Datenmodell für Chat-Nachrichten
│   │   ├── message.g.dart          # Auto-generierter JSON-Code
│   │   ├── scrum_ceremony.dart     # Datenmodell für Scrum-Zeremonien
│   │   └── scrum_ceremony.g.dart   # Auto-generierter JSON-Code
│   ├── providers/
│   │   └── chat_provider.dart      # Zentraler State: Nachrichten, Loading, Logik
│   ├── screens/
│   │   └── chat_screen.dart        # Haupt-UI: Chat-Ansicht, Dialoge, Menü
│   ├── services/
│   │   ├── ai_service.dart         # Gemini API Integration, alle KI-Funktionen
│   │   └── storage_service.dart    # Lokale Persistenz via SharedPreferences
│   └── widgets/
│       ├── ceremony_selector.dart  # Bottom Sheet zur Zeremonien-Auswahl
│       └── message_bubble.dart     # Einzelne Chat-Nachricht (Bubble)
├── macos/
│   └── Runner/
│       ├── DebugProfile.entitlements   # macOS Sandbox-Berechtigungen (Debug)
│       └── Release.entitlements        # macOS Sandbox-Berechtigungen (Release)
├── android/                        # Android-spezifische Konfiguration
├── ios/                            # iOS-spezifische Konfiguration
├── windows/                        # Windows-spezifische Konfiguration
├── assets/
│   ├── images/                     # App-Bilder
│   └── icons/                      # App-Icons
├── pubspec.yaml                    # Abhängigkeiten & Asset-Konfiguration
├── README.md                       # Kurzübersicht & Schnellstart
└── DOCUMENTATION.md                # Diese Datei
```

---

## 4. Datenmodelle

### 4.1 `Message` (`lib/models/message.dart`)

Repräsentiert eine einzelne Chat-Nachricht.

```dart
class Message {
  final String id;           // UUID v4, automatisch generiert
  final String text;         // Nachrichteninhalt
  final bool isUser;         // true = Nutzer, false = KI
  final DateTime timestamp;  // Erstellungszeitpunkt
  final MessageType type;    // Nachrichtentyp (s.u.)
  final Map<String, dynamic>? metadata; // Optionale Zusatzdaten
}
```

#### `MessageType` Enum

| Wert | Verwendung | Bubble-Farbe |
|---|---|---|
| `text` | Normale Konversation | Grau |
| `ceremony` | Zeremonie-Antworten | Lila |
| `insight` | Retrospektiven-Analyse | Blau |
| `goal` | Sprint Goal | Grün |
| `sentiment` | Sentiment-Analyse | Orange |

JSON-Serialisierung wird über `json_serializable` automatisch generiert (`message.g.dart`).

---

### 4.2 `ScrumCeremony` (`lib/models/scrum_ceremony.dart`)

Repräsentiert eine laufende oder abgeschlossene Scrum-Zeremonie.

```dart
class ScrumCeremony {
  final String id;                      // UUID v4
  final String name;                    // z.B. "Daily Standup"
  final DateTime startTime;             // Startzeitpunkt
  final DateTime? endTime;              // Endzeitpunkt (optional)
  final List<String> participants;      // Teilnehmerliste
  final List<String> notes;             // Meeting-Notizen
  final String? summary;                // KI-generierte Zusammenfassung
  final Map<String, dynamic>? sentiment; // Sentiment-Daten
}
```

Unterstützt `copyWith()` für immutable Updates. Ebenfalls JSON-serialisiert.

---

## 5. Services

### 5.1 `AiService` (`lib/services/ai_service.dart`)

Zentrale Schnittstelle zur Google Gemini API. Verwaltet das Sprachmodell und die Chat-Session.

#### Initialisierung

```dart
AiService() {
  _model = GenerativeModel(
    model: 'gemma-3-27b-it',  // Aktuell konfiguriertes Modell
    apiKey: AppConfig.geminiApiKey,
    generationConfig: GenerationConfig(
      temperature: 0.7,    // Kreativität (0=deterministisch, 1=kreativ)
      topK: 40,            // Top-K Sampling
      topP: 0.95,          // Nucleus Sampling
      maxOutputTokens: 2048,
    ),
  );
  _chat = _model.startChat(history: [Content.text(AppConfig.systemPrompt)]);
}
```

#### Methoden

| Methode | Parameter | Rückgabe | Beschreibung |
|---|---|---|---|
| `sendMessage(text)` | `String` | `Future<String>` | Nachricht an Chat-Session senden |
| `analyzeSentiment(text)` | `String` | `Future<String>` | Stimmungsanalyse (Score 1–10 + Begründung) |
| `generateSprintGoal(items)` | `List<String>` | `Future<String>` | Sprint Goal aus Backlog Items generieren |
| `analyzeRetrospective(points)` | `List<String>` | `Future<String>` | Retro-Punkte auswerten |
| `facilitateCeremony(type, context)` | `String, String` | `Future<String>` | Zeremonie moderieren |
| `resetChat()` | – | `void` | Chat-Session zurücksetzen |

#### Chat-Session vs. Einzelanfragen

- `sendMessage()` und `facilitateCeremony()` verwenden die **persistente Chat-Session** (`_chat`) – der Konversationsverlauf bleibt erhalten.
- `analyzeSentiment()`, `generateSprintGoal()` und `analyzeRetrospective()` verwenden **direkte Einzelanfragen** (`_model.generateContent()`) – ohne Kontext.

---

### 5.2 `StorageService` (`lib/services/storage_service.dart`)

Verwaltet die persistente lokale Speicherung mit `SharedPreferences`.

#### Methoden

| Methode | Beschreibung |
|---|---|
| `saveMessages(messages)` | Serialisiert und speichert die Nachrichtenliste als JSON |
| `loadMessages()` | Lädt und deserialisiert gespeicherte Nachrichten |
| `saveCeremonies(ceremonies)` | Speichert Zeremonien als JSON |
| `loadCeremonies()` | Lädt gespeicherte Zeremonien |
| `saveApiKey(key)` | Speichert einen API Key lokal |
| `loadApiKey()` | Lädt den gespeicherten API Key |
| `clearAll()` | Löscht alle gespeicherten Daten |

#### Speicher-Keys

```dart
static const String _messagesKey   = 'messages';
static const String _ceremoniesKey = 'ceremonies';
static const String _apiKeyKey     = 'api_key';
```

---

## 6. State Management

### `ChatProvider` (`lib/providers/chat_provider.dart`)

Einzige `ChangeNotifier`-Klasse der App. Hält den gesamten App-State und vermittelt zwischen UI und Services.

#### State-Properties

```dart
List<Message> _messages      // Alle Chat-Nachrichten
bool _isLoading              // Ladeindikator für KI-Anfragen
ScrumCeremony? _currentCeremony  // Aktive Zeremonie (oder null)
```

#### Ablauf einer Nachricht (`sendMessage`)

```
1. User-Message-Objekt erstellen & zu _messages hinzufügen
2. notifyListeners() → UI zeigt Nachricht
3. _isLoading = true → UI zeigt Ladeindikator
4. AiService.sendMessage() aufrufen (async)
5. KI-Antwort als Message-Objekt erstellen & hinzufügen
6. Bei Fehler: Fehlernachricht als Message hinzufügen
7. _isLoading = false, saveMessages(), notifyListeners()
```

Dasselbe Prinzip gilt für `startCeremony()`, `analyzeSentiment()`, `generateSprintGoal()` und `analyzeRetrospective()`.

#### Registrierung in `main.dart`

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ChatProvider()),
  ],
  ...
)
```

---

## 7. UI-Schichten

### 7.1 `main.dart` – App-Einstiegspunkt

Konfiguriert:
- **Material Design 3** als UI-System
- **Deep Purple** als Seed-Color für das Farbschema
- **Light & Dark Theme** mit automatischer Systemanpassung (`ThemeMode.system`)
- `ChatScreen` als Home-Screen
- `ChatProvider` als globaler State-Provider

---

### 7.2 `ChatScreen` (`lib/screens/chat_screen.dart`)

Haupt-Screen der App. Enthält:

#### UI-Komponenten
- **AppBar** mit App-Name und Options-Menü (`⋮`)
- **ListView** mit allen `MessageBubble`-Widgets (scrollbar)
- **Empty State** wenn keine Nachrichten vorhanden (mit "Zeremonie starten"-Button)
- **Ladeindikator** (`CircularProgressIndicator`) während KI-Anfragen
- **Input-Leiste** mit Kalender-Icon, Textfeld und Sende-Button

#### Dialoge & Bottom Sheets

| Methode | Typ | Funktion |
|---|---|---|
| `_showCeremonySelector()` | Bottom Sheet | Zeremonien-Auswahl |
| `_showOptionsMenu()` | Bottom Sheet | Hauptmenü mit allen Features |
| `_showSentimentDialog()` | AlertDialog | Texteingabe für Sentiment |
| `_showSprintGoalDialog()` | AlertDialog | Backlog Items eingeben |
| `_showRetrospectiveDialog()` | AlertDialog | Retro-Punkte eingeben |

#### Auto-Scroll
Nach jeder neuen Nachricht scrollt die Liste automatisch ans Ende:
```dart
_scrollController.animateTo(
  _scrollController.position.maxScrollExtent,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOut,
);
```

---

### 7.3 `MessageBubble` (`lib/widgets/message_bubble.dart`)

Stellt eine einzelne Nachricht dar.

- **Nutzer-Nachrichten**: Rechtsbündig, Primary-Color Hintergrund, weißer Text
- **KI-Nachrichten**: Linksbündig, typenabhängige Farbe, dunkler Text
- **Typ-Label + Icon** für nicht-Text-Nachrichten (z.B. "🎯 Sprint-Ziel")
- **Zeitstempel** in `HH:mm` Format unten rechts
- Max. Breite: 75% der Bildschirmbreite

---

### 7.4 `CeremonySelector` (`lib/widgets/ceremony_selector.dart`)

Bottom Sheet zur Auswahl einer Scrum-Zeremonie.

- Zeigt alle 5 Zeremonien aus `AppConfig.ceremonies` als `ListTile`-Cards
- Jede Zeremonie hat ein passendes Icon und eine Kurzbeschreibung
- In `SingleChildScrollView` gewrapped um Overflow auf kleinen Bildschirmen zu vermeiden

#### Zeremonien & Icons

| Zeremonie | Icon | Beschreibung |
|---|---|---|
| Daily Standup | `Icons.groups` | Tägliches 15-minütiges Team-Meeting |
| Sprint Planning | `Icons.calendar_month` | Planung des kommenden Sprints |
| Sprint Review | `Icons.preview` | Präsentation der Sprint-Ergebnisse |
| Sprint Retrospective | `Icons.insights` | Reflexion über den letzten Sprint |
| Backlog Refinement | `Icons.list_alt` | Verfeinerung des Product Backlogs |

---

## 8. KI-Integration

### System-Prompt

Der System-Prompt definiert die Rolle des KI-Assistenten und wird beim Start der Chat-Session als erste Nachricht in die History eingefügt:

```
You are an experienced Scrum Master assistant. Your role is to:
- Guide teams through Scrum ceremonies
- Provide helpful suggestions and best practices
- Analyze team sentiment and provide insights
- Generate sprint goals and summaries
- Be supportive, professional, and constructive

Always maintain a positive and encouraging tone while being practical and actionable.
```

### Prompt-Templates

#### Sentiment-Analyse
```
Analysiere die Stimmung (Sentiment) des folgenden Textes aus einem Scrum-Meeting.
Bewerte die Stimmung auf einer Skala von 1-10 (1=sehr negativ, 10=sehr positiv)
und gib eine kurze Begründung.

Text: "{text}"

Format der Antwort:
Score: [Zahl 1-10]
Begründung: [Kurze Erklärung]
```

#### Sprint Goal Generierung
```
Basierend auf den folgenden Backlog Items, generiere ein klares, fokussiertes Sprint-Ziel.

Backlog Items:
- Item 1
- Item 2
...

Das Sprint-Ziel sollte:
- Klar und prägnant sein
- Den Wert für den Kunden hervorheben
- Das Team motivieren
- In 1-2 Sätzen formuliert sein
```

#### Retrospektiven-Analyse
```
Analysiere die folgenden Retrospektiven-Punkte und erstelle eine Zusammenfassung
mit konkreten Handlungsempfehlungen.

Erstelle:
1. Hauptthemen (3-5 Punkte)
2. Konkrete Aktionen für den nächsten Sprint
3. Positive Aspekte, die beibehalten werden sollten
```

### LLM-Modell-Konfiguration

| Parameter | Wert | Bedeutung |
|---|---|---|
| `model` | `gemma-3-27b-it` | Gemma 3 27B Instruction-Tuned |
| `temperature` | `0.7` | Ausgeglichene Kreativität |
| `topK` | `40` | Sampling aus Top-40 Tokens |
| `topP` | `0.95` | Nucleus Sampling bei 95% |
| `maxOutputTokens` | `2048` | Max. Antwortlänge |

### Alternative Modelle

Die App wurde mit verschiedenen Modellen getestet. Modell kann in `lib/services/ai_service.dart` geändert werden:

| Modell | Empfehlung |
|---|---|
| `gemma-3-27b-it` | Aktuell aktiv – leistungsstark, freier Zugang |
| `gemma-3-12b-it` | Kleiner, schneller, weniger Token-Verbrauch |
| `gemini-2.0-flash-lite` | Schnellstes Gemini-Modell, höchste Free-Tier-Limits |
| `gemini-2.0-flash` | Gutes Gleichgewicht Qualität/Geschwindigkeit |
| `gemini-2.5-flash` | Aktuellstes Flash-Modell |

---

## 9. Lokale Datenspeicherung

Alle Daten werden lokal auf dem Gerät gespeichert – es werden keine Nutzerdaten an externe Server (außer die KI-Anfragen an Google) gesendet.

### Speichermechanismus

`SharedPreferences` speichert Daten als Key-Value-Paare:

```
"messages"   → JSON-String der Nachrichtenliste
"ceremonies" → JSON-String der Zeremonieliste
"api_key"    → Optionaler gespeicherter API Key
```

### Serialisierung

Modelle werden mit `json_serializable` serialisiert:

```dart
// Speichern
final jsonList = messages.map((m) => m.toJson()).toList();
await prefs.setString('messages', jsonEncode(jsonList));

// Laden
final List<dynamic> jsonList = jsonDecode(jsonString);
return jsonList.map((json) => Message.fromJson(json)).toList();
```

---

## 10. Plattform-Konfiguration (macOS)

### App Sandbox & Netzwerk-Entitlements

macOS-Apps laufen in einer Sandbox und müssen explizit Netzwerkzugriff erlauben. Ohne diese Konfiguration schlagen alle API-Anfragen mit "connection failed" fehl.

**`macos/Runner/DebugProfile.entitlements`:**
```xml
<key>com.apple.security.app-sandbox</key><true/>
<key>com.apple.security.cs.allow-jit</key><true/>
<key>com.apple.security.network.client</key><true/>   <!-- Ausgehende HTTP-Anfragen -->
<key>com.apple.security.network.server</key><true/>
```

**`macos/Runner/Release.entitlements`:**
```xml
<key>com.apple.security.app-sandbox</key><true/>
<key>com.apple.security.network.client</key><true/>   <!-- Ausgehende HTTP-Anfragen -->
```

> ⚠️ `com.apple.security.network.client` ist das kritische Entitlement für API-Anfragen. Ohne es kann die App keine Verbindung zur Gemini API aufbauen.

---

## 11. Konfiguration & Anpassung

Alle zentralen Einstellungen befinden sich in `lib/config/app_config.dart`:

```dart
class AppConfig {
  // API Key – NIEMALS in öffentliche Repositories committen!
  static const String geminiApiKey = 'DEIN_API_KEY_HIER';

  // App-Metadaten
  static const String appName    = 'AgileAI';
  static const String appVersion = '1.0.0';

  // Verfügbare Scrum-Zeremonien
  static const List<String> ceremonies = [
    'Daily Standup',
    'Sprint Planning',
    'Sprint Review',
    'Sprint Retrospective',
    'Backlog Refinement',
  ];

  // System-Prompt für den KI-Assistenten
  static const String systemPrompt = '...';
}
```

### Modell wechseln

In `lib/services/ai_service.dart`:
```dart
_model = GenerativeModel(
  model: 'gemma-3-27b-it',  // Hier Modell ändern
  ...
);
```

---

## 12. Setup & Installation

### Voraussetzungen

- Flutter SDK (>=3.10.7)
- Dart SDK
- Google Gemini API Key → [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

### Schritt-für-Schritt

```bash
# 1. Dependencies installieren
flutter pub get

# 2. JSON-Serialisierungscode generieren
dart run build_runner build --delete-conflicting-outputs

# 3. API Key eintragen (lib/config/app_config.dart)
# static const String geminiApiKey = 'DEIN_KEY';

# 4. App starten
flutter run -d macos     # macOS
flutter run -d windows   # Windows
flutter run              # Android/iOS
```

> **Wichtig nach Dependency-Änderungen:** Immer vollständig neu bauen (`flutter run`), kein Hot Reload reicht.

---

## 13. Bekannte Einschränkungen & Hinweise

| Thema | Details |
|---|---|
| **API Key Sicherheit** | Der Key darf nie in öffentliche Git-Repos committed werden. Für Produktion: Environment Variables verwenden. |
| **Free-Tier Rate Limits** | Die Gemini/Gemma Free-Tier hat Limits (Anfragen/Minute & Tag). Bei Quota-Fehler: kurz warten und erneut versuchen. |
| **Internet erforderlich** | Alle KI-Funktionen benötigen eine aktive Internetverbindung. |
| **macOS Sandbox** | Ohne `com.apple.security.network.client` im Entitlements-File funktioniert kein API-Call. |
| **Hot Reload vs. Restart** | Reine Dart-Änderungen: Hot Restart (`R`) reicht. Entitlements- oder Dependency-Änderungen: vollständiger Neustart nötig. |
| **Keyboard-Event Warning** | Auf macOS erscheint eine Flutter-Framework-Warnung zu Keyboard-Events bei Fokuswechsel. Das ist ein bekannter Flutter-Bug und beeinflusst die Funktionalität nicht. |

---

## 14. Fehlerbehebung

| Fehler | Ursache | Lösung |
|---|---|---|
| `connection failed` | macOS Netzwerk-Entitlement fehlt | `com.apple.security.network.client` in Entitlements-Dateien hinzufügen, neu bauen |
| `model not found for api version` | Falscher Modellname | Modellname in `ai_service.dart` korrigieren (z.B. `gemma-3-27b-it`) |
| `exceeded your quota` | Rate Limit erreicht | 1 Minute warten; ggf. sparsameres Modell wählen |
| `LateInitializationError: _chat already initialized` | `late final` erlaubt keine Neuzuweisung | `late final ChatSession` → `late ChatSession` ändern |
| `RenderFlex overflowed` | Column zu groß für verfügbaren Platz | Column in `SingleChildScrollView` wrappen |
| `flutter pub get` schlägt fehl | Dependency-Konflikt | `flutter pub upgrade` oder Versionsconstraint anpassen |

---

*Dokumentation erstellt für AgileAI v1.0.0*
