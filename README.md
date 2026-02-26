# 🤖 ScrumMaster AI

Ein intelligenter virtueller Scrum Master, der Teams durch Scrum-Zeremonien führt und KI-gestützte Insights bietet.

## ✨ Features

- 💬 **Intelligenter Chatbot** - Kommunikation mit einem KI-gestützten Scrum Master
- 📅 **Scrum-Zeremonien** - Unterstützung für alle Scrum-Events:
  - Daily Standup
  - Sprint Planning
  - Sprint Review
  - Sprint Retrospective
  - Backlog Refinement
- 📊 **Sentiment-Analyse** - Automatische Stimmungsanalyse von Meeting-Texten
- 🎯 **Sprint-Ziel Generierung** - KI-generierte Sprint Goals basierend auf Backlog Items
- 🔍 **Retrospektiven-Analyse** - Auswertung und Handlungsempfehlungen für Retros
- 💾 **Lokale Speicherung** - Alle Chat-Verläufe werden lokal gespeichert
- 🌓 **Dark Mode** - Automatische Dark/Light Mode Unterstützung

## 🚀 Installation & Setup

### Voraussetzungen

- Flutter SDK (>=3.10.7)
- Dart SDK
- Google Gemini API Key

### 1. Dependencies installieren

```bash
flutter pub get
```

### 2. API Key konfigurieren

Öffne `lib/config/app_config.dart` und füge deinen Google Gemini API Key ein:

```dart
static const String geminiApiKey = 'DEIN_API_KEY_HIER';
```

**Wie bekomme ich einen API Key?**

1. Besuche [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Melde dich mit deinem Google Account an
3. Erstelle einen neuen API Key
4. Kopiere den Key und füge ihn in die Config ein

### 3. Code generieren

Generiere die JSON Serialisierungs-Dateien:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. App starten

#### Android / iOS (Simulator/Emulator)
```bash
flutter run
```

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

## 🏗️ Projektstruktur

```
lib/
├── config/          # App-Konfiguration & API Keys
├── models/          # Datenmodelle (Message, ScrumCeremony)
├── providers/       # State Management (ChatProvider)
├── screens/         # UI Screens (ChatScreen)
├── services/        # Backend-Services (AI, Storage)
├── widgets/         # Wiederverwendbare UI-Komponenten
└── main.dart        # App Entry Point
```

## 🎯 Verwendung

### Normale Konversation
1. Öffne die App
2. Tippe eine Nachricht ein
3. Der ScrumMaster AI antwortet mit hilfreichen Tipps

### Zeremonie starten
1. Tippe auf das Kalender-Icon (📅)
2. Wähle eine Zeremonie aus
3. Der AI führt dich durch das Meeting

### Sentiment analysieren
1. Öffne das Menü (⋮)
2. Wähle "Sentiment analysieren"
3. Füge Meeting-Text ein
4. Erhalte eine Stimmungsbewertung

### Sprint-Ziel generieren
1. Öffne das Menü (⋮)
2. Wähle "Sprint-Ziel generieren"
3. Füge Backlog Items ein (ein Item pro Zeile)
4. Erhalte ein KI-generiertes Sprint Goal

### Retrospektive analysieren
1. Öffne das Menü (⋮)
2. Wähle "Retrospektive analysieren"
3. Füge Retro-Punkte ein
4. Erhalte Zusammenfassung und Handlungsempfehlungen

## 🤖 LLM-Optionen

Die App nutzt standardmäßig **Google Gemini Pro**. Alternativ kannst du auch:

### OpenAI GPT-4 verwenden
```dart
// In lib/services/ai_service.dart
// Verwende das Package: openai_api
```

### Anthropic Claude verwenden
```dart
// In lib/services/ai_service.dart
// Verwende das Package: anthropic_sdk_dart
```

### Lokale LLMs (Ollama)
```dart
// Installiere Ollama: https://ollama.ai
// Verwende ollama_dart Package
```

## 📱 Unterstützte Plattformen

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS

## 🔧 Technologie-Stack

- **Framework:** Flutter 3.x
- **State Management:** Provider
- **LLM:** Google Gemini Pro
- **Storage:** Shared Preferences
- **UI:** Material Design 3

## 📝 Lizenz

Dieses Projekt wurde für Bildungszwecke erstellt.

## 🤝 Contribution

Feedback und Verbesserungsvorschläge sind willkommen!

## ⚠️ Hinweise

- Der API Key sollte NIEMALS in öffentlichen Repositories committed werden
- Für Produktiv-Apps: API Key in Environment Variables auslagern
- Die App benötigt eine Internetverbindung für die AI-Funktionen

## 📚 Weitere Ressourcen

- [Flutter Documentation](https://flutter.dev/docs)
- [Google Gemini API](https://ai.google.dev/)
- [Scrum Guide](https://scrumguides.org/)

---

Viel Erfolg mit deinem virtuellen Scrum Master! 🚀
