# 🤖 AgileAI – AI-Powered Scrum Master

> ⚠️ **Important:** This app requires a Google Gemini API key to function.
> 👉 **[Get a free key at Google AI Studio](https://aistudio.google.com/app/apikey)**
>
> Enter the key during the onboarding flow on first launch, or set it directly in `lib/config/app_config.dart`.

An intelligent, AI-backed Scrum Master assistant built with Flutter. Guides teams through all Scrum ceremonies, analyzes sentiment, manages the backlog and sprint — all powered by Google Gemini.

## ✨ Features

| Area | Features |
|---|---|
| **Chat** | Free conversation with the AI Scrum Master, voice input, chat export |
| **Ceremonies** | All 5 Scrum events with AI facilitation, daily tips, ceremony log |
| **Backlog** | CRUD, AI story point estimation, INVEST validation, acceptance criteria, sprint assignment |
| **Sprint view** | Capacity display (total SP / completed SP / progress) |
| **Analytics** | Sentiment history chart, velocity chart, team health score |
| **Team** | Team member CRUD with role |
| **Planning Poker** | 5-phase estimation workshop with AI moderation |
| **Glossary** | Offline, searchable Scrum glossary |
| **Settings** | Language (DE/EN), AI model, persona, sprint number |
| **Onboarding** | First-launch setup wizard |
| **AI tools** | Definition of Done generator, Scrum maturity assessment, retro pattern analysis |

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code (required after model changes)
dart run build_runner build --delete-conflicting-outputs

# Run on macOS
flutter run -d macos

# Run on Windows
flutter run -d windows

# Run on Android / iOS
flutter run
```

## 🏗️ Architecture

```
Screens / Widgets
       ↕
Providers (ChangeNotifier)
  ChatProvider · BacklogProvider · SettingsProvider · AnalyticsProvider · TeamProvider
       ↕
Services
  AiService (Gemini) · StorageService (SharedPreferences) · DatabaseService (SQLite)
```

Full technical documentation (in German): **[DOCUMENTATION.md](DOCUMENTATION.md)**

## 📁 Project Structure

```
lib/
├── config/          # Central config: API key, model, prompts, ceremonies, glossary
├── models/          # Data models with JSON serialization (*.g.dart)
├── providers/       # State management (ChangeNotifier)
├── screens/         # All UI screens
├── services/        # AI, storage, and database services
├── widgets/         # Reusable UI components
└── main.dart        # App entry point, MultiProvider setup
```

## 📱 Supported Platforms

✅ macOS · ✅ Windows · ✅ Android · ✅ iOS

## ⚠️ Important Notes

- **Never commit your API key** to a public repository — use environment variables in production.
- **macOS sandbox:** `com.apple.security.network.client` must be set in both entitlements files for API calls to work.
- **macOS voice input:** additionally requires `com.apple.security.device.microphone` in `DebugProfile.entitlements`.
- AI features require an active internet connection. The glossary works fully offline.
- After changing `pubspec.yaml` or entitlements, a full restart (`flutter run`) is required — hot restart is not enough.

## 🔧 Tech Stack

Flutter · Dart · Provider · Google Gemini · fl_chart · sqflite · SharedPreferences · Material Design 3

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Google Gemini API](https://ai.google.dev/)
- [Scrum Guide](https://scrumguides.org/)
