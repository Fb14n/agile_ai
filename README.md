# 🤖 AgileAI – KI-Scrum-Master

> ⚠️ **Wichtig:** Die App benötigt einen Google Gemini API Key.
> 👉 **[Kostenlosen Key erhalten](https://aistudio.google.com/app/apikey)**
> 
> Key beim ersten Start über das Onboarding oder in `lib/config/app_config.dart` eintragen.

Ein intelligenter, KI-gestützter Scrum Master für Flutter. Führt Teams durch alle Scrum-Zeremonien, analysiert Sentiment, verwaltet Backlog und Sprint – alles über Google Gemini.

## ✨ Features

| Bereich | Features |
|---|---|
| **Chat** | Freie Konversation, Spracheingabe, Chat exportieren |
| **Zeremonien** | Alle 5 Scrum-Events mit KI-Moderation, Tages-Tipps, Zeremonien-Log |
| **Backlog** | CRUD, Story Point Schätzung, INVEST-Validierung, Akzeptanzkriterien, Sprint-Zuweisung |
| **Sprint-View** | Kapazitätsanzeige (SP gesamt/erledigt/Fortschritt) |
| **Analytics** | Sentiment-Verlauf, Velocity-Chart, Team Health Score |
| **Team** | Teammitglieder CRUD mit Rolle |
| **Planning Poker** | 5-Phasen-Schätzworkshop mit KI-Moderation |
| **Glossar** | Offline-Scrum-Lexikon (durchsuchbar) |
| **Einstellungen** | Sprache (DE/EN), Modell, Persona, Sprint-Nummer |
| **Onboarding** | Erststart-Einrichtung |
| **KI-Tools** | Definition of Done, Scrum-Reife-Bewertung, Retro-Muster-Analyse |

## 🚀 Schnellstart

```bash
# Dependencies
flutter pub get

# JSON-Code generieren (nach Modell-Änderungen)
dart run build_runner build --delete-conflicting-outputs

# macOS starten
flutter run -d macos

# Windows
flutter run -d windows

# Android/iOS
flutter run
```

## 🏗️ Architektur

```
Screens/Widgets
      ↕
Provider (ChangeNotifier)
  ChatProvider · BacklogProvider · SettingsProvider · AnalyticsProvider · TeamProvider
      ↕
Services
  AiService (Gemini) · StorageService (SharedPreferences) · DatabaseService (SQLite)
```

Vollständige technische Dokumentation: **[DOCUMENTATION.md](DOCUMENTATION.md)**

## 📱 Plattformen

✅ macOS · ✅ Windows · ✅ Android · ✅ iOS

## ⚠️ Hinweise

- API Key **niemals** in öffentliche Repositories committen
- macOS: `com.apple.security.network.client` muss in beiden Entitlements-Dateien gesetzt sein
- Spracheingabe (macOS): zusätzlich `com.apple.security.device.microphone` in `DebugProfile.entitlements`
- Für KI-Funktionen ist eine Internetverbindung nötig (Glossar funktioniert offline)

## 🔧 Tech Stack

Flutter · Dart · Provider · Google Gemini · fl_chart · sqflite · SharedPreferences · Material Design 3

## 📚 Ressourcen

- [Flutter Docs](https://flutter.dev/docs)
- [Google Gemini API](https://ai.google.dev/)
- [Scrum Guide](https://scrumguides.org/)
