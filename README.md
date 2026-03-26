# AgileAI - Project-Centric Scrum Management

> ⚠️ **Important:** This app requires a Google Gemini API key to function.
> 👉 **[Get a free key at Google AI Studio](https://makersuite.google.com/app/apikey)**
>
> Create a `.env` file in the project root with your key (see Installation step 3).

**AgileAI** ist eine Flutter-Anwendung, die als KI-gestützter Scrum Master fungiert. Teams können projekt-spezifische Scrum Ceremonies durchführen, wobei die gesamte Historie als Kontext gespeichert wird für kontinuierliche KI-Unterstützung.

## 🎯 Features

### Projekt-Management
- ✅ **Projekt-zentrierte Struktur**: Jedes Projekt hat eigene Sprints, User Stories, Meetings und Kontext
- ✅ **Fantasy-Projekt**: Beim ersten Start wird automatisch das Demo-Projekt "QuantumHealth" angelegt
- ✅ **Statistiken**: Projekt-spezifische und globale Statistiken

### Scrum Ceremonies
- ✅ **Daily Standup** - Schnelles Team-Sync mit Blocker-Erkennung
- ✅ **Sprint Planning** - Sprint-Ziele definieren und Stories auswählen
- ✅ **Sprint Review** - Increment präsentieren und Feedback sammeln
- ✅ **Sprint Retrospective** - Reflexion mit Sentiment-Analyse
- ✅ **Backlog Refinement** - User Stories schätzen und priorisieren

### KI-Features
- ✅ **Kontext-Gedächtnis**: Alle Meetings werden gespeichert und als Kontext genutzt
- ✅ **Sentiment-Analyse**: Automatische Team-Stimmungs-Erkennung
- ✅ **Action Items**: KI extrahiert Handlungsempfehlungen
- ✅ **Editierbarer Kontext**: Projekt-spezifische Informationen können manuell angepasst werden

### Datenbank
- ✅ **SQLite** mit automatischer Schema-Migration
- ✅ **Automatische Initialisierung** beim ersten App-Start
- ✅ **Seed-Data**: Fantasy-Projekt mit realistischen Daten

## 📋 Prerequisites

- **Flutter SDK** 3.10.7 oder höher
- **Dart** 3.10.7 oder höher
- **Google Gemini API Key** ([Hier erhalten](https://makersuite.google.com/app/apikey))

## 🚀 Installation

### 1. Repository klonen

```bash
git clone <repository-url>
cd agile_ai
```

### 2. Dependencies installieren

```bash
flutter pub get
```

### 3. API Key konfigurieren

Erstelle eine `.env` Datei im Projekt-Root:

```bash
cp .env.example .env
```

Öffne `.env` und trage deinen Gemini API Key ein:

```
GEMINI_API_KEY=your_actual_api_key_here
```

**⚠️ Wichtig**: Die `.env` Datei wird nicht ins Git committed! Nutze `.env.example` als Template.

### 4. JSON Serialization Code generieren

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. App starten

```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Android
flutter run -d <device-id>

# iOS
flutter run -d <device-id>
```

## 📁 Projekt-Struktur

```
lib/
├── config/               # App-Konfiguration (Theme, AppConfig)
├── models/               # Datenmodelle (@JsonSerializable)
│   ├── project.dart
│   ├── sprint.dart
│   ├── user_story.dart
│   ├── meeting.dart
│   ├── meeting_message.dart
│   ├── project_team_member.dart
│   └── project_context.dart
├── providers/            # State Management (Provider)
│   ├── project_provider.dart
│   ├── meeting_provider.dart
│   ├── context_provider.dart
│   ├── settings_provider.dart
│   └── analytics_provider.dart
├── screens/              # UI Screens
│   ├── project_list_screen.dart
│   ├── project_detail_screen.dart
│   ├── meeting_screen.dart
│   ├── global_stats_screen.dart
│   └── settings_screen.dart
├── services/             # Business Logic
│   ├── database_service.dart    # SQLite Wrapper
│   ├── seed_service.dart        # Demo-Daten
│   ├── project_service.dart     # Projekt-CRUD
│   ├── meeting_service.dart     # Meeting-Management
│   └── ai_service.dart          # Gemini Integration
├── widgets/              # Wiederverwendbare UI-Komponenten
└── main.dart             # Entry Point
```

## 🗄️ Datenbank

### Automatische Initialisierung

Die Datenbank wird beim ersten App-Start automatisch initialisiert:

1. **Schema-Erstellung**: Alle Tabellen werden angelegt (v1 Migration)
2. **Seed-Data**: Das Fantasy-Projekt "QuantumHealth" wird eingefügt (v2 Migration)
3. **Fertig**: Die App ist sofort nutzbar!

### Schema

Die Datenbank besteht aus 7 Tabellen:

- `projects` - Projekt-Stammdaten
- `sprints` - Sprint-Informationen
- `user_stories` - User Stories / Backlog Items
- `meetings` - Meeting-Historie
- `meeting_messages` - Chat-Verlauf in Meetings
- `project_team_members` - Team-Mitglieder
- `project_context` - Editierbarer Projekt-Kontext

Details siehe [DATABASE.md](DATABASE.md)

## 🎭 Fantasy-Projekt "QuantumHealth"

Beim ersten Start wird automatisch ein Demo-Projekt angelegt:

- **Name**: QuantumHealth - Smart Medical Platform
- **Team**: 6 Mitglieder (Alice, Bob, Charlie, Diana, Eve, Frank)
- **Sprints**: 3 Sprints (Sprint 3 aktiv)
- **User Stories**: 8 Stories (3 Done, 2 In Progress, 3 Backlog)
- **Meetings**: 3 dokumentierte Meetings mit Chat-Verläufen
  - Sprint Planning
  - Daily Standup
  - Sprint Retrospective

Dies dient als Onboarding und zeigt die Funktionalität der App.

## 🛠️ Development

### Commands

```bash
# Dependencies installieren
flutter pub get

# JSON Serialization Code generieren
dart run build_runner build --delete-conflicting-outputs

# Code analysieren
flutter analyze

# Tests ausführen
flutter test

# App bauen
flutter build macos     # macOS
flutter build windows   # Windows
flutter build apk       # Android
flutter build ios       # iOS
```

### Code Generation

Nach Änderungen an Models mit `@JsonSerializable`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Dies generiert die `*.g.dart` Dateien für JSON-Serialisierung.

## ⚙️ Konfiguration

### AI Model wechseln

In `lib/config/app_config.dart`:

```dart
static const String defaultModel = 'gemma-3-27b-it';  // Ändern auf gewünschtes Modell
```

Verfügbare Models: `gemini-2.5-flash`, `gemini-2.0-flash`, `gemma-3-27b-it`, etc.

### System Prompt anpassen

In `lib/config/app_config.dart` in der `systemPrompt()` Methode.

### Sprache ändern

Über die Settings-Screen in der App oder direkt in `AppConfig.defaultLanguage`.

## 🔒 Sicherheit

- ✅ API Keys werden **NICHT** ins Git committed (`.env` ist in `.gitignore`)
- ✅ Nutze `.env.example` als Template
- ✅ Datenbank-Dateien (`.db`) werden nicht committed
- ✅ Für Produktion: API Key in Umgebungsvariablen auslagern

## 🐛 Troubleshooting

### "No .env file found"
→ Erstelle `.env` Datei mit `GEMINI_API_KEY=...`

### "API key not valid"
→ Prüfe ob der Key korrekt in `.env` eingetragen ist

### macOS: Network requests fail
→ Prüfe Entitlements in `macos/Runner/*.entitlements` - `com.apple.security.network.client` muss vorhanden sein

### Build-Fehler nach Model-Änderungen
→ Führe `dart run build_runner build --delete-conflicting-outputs` aus

### Datenbank zurücksetzen
→ Lösche die `.db` Datei im App-Verzeichnis und starte neu

## 📖 Weitere Dokumentation

- [DATABASE.md](DATABASE.md) - Detaillierte Datenbank-Dokumentation
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Plattform-spezifische Setup-Anleitung

## 🤝 Contributing

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/amazing-feature`)
3. Commit deine Änderungen (`git commit -m 'Add amazing feature'`)
4. Push zum Branch (`git push origin feature/amazing-feature`)
5. Erstelle einen Pull Request

## 📄 License

MIT License

## 🙏 Credits

- **AI Model**: Google Gemini
- **Framework**: Flutter & Dart
- **State Management**: Provider
- **Database**: SQLite

---

Made with ❤️ by the AgileAI Team
