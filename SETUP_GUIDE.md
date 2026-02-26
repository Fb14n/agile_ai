# AgileAI - Setup Instructions

## 🎯 Quick Start (Deutsch)

### 1. Setup ausführen
```bash
./setup.sh
```

### 2. API Key konfigurieren

**WICHTIG:** Öffne `lib/config/app_config.dart` und füge deinen API Key ein:

```dart
static const String geminiApiKey = 'DEIN_API_KEY_HIER';
```

**API Key erhalten:**
- Besuche: https://makersuite.google.com/app/apikey
- Melde dich an
- Erstelle einen neuen API Key
- Kopiere und füge ihn ein

### 3. App starten

**Android/iOS:**
```bash
flutter run
```

**Windows:**
```bash
flutter run -d windows
```

**macOS:**
```bash
flutter run -d macos
```

## 🤖 LLM Alternativen

### Google Gemini (Standard) ✅
- **Kostenlos:** 60 Anfragen/Minute
- **Einfach:** API Key + fertig
- **Empfohlen für:** Erste Schritte

### OpenAI GPT-4
```yaml
# In pubspec.yaml hinzufügen:
dependencies:
  openai_api: ^2.0.0
```

```dart
// In lib/services/ai_service.dart:
import 'package:openai_api/openai_api.dart';

final openai = OpenAI(apiKey: 'sk-...');
```

### Anthropic Claude
```yaml
dependencies:
  anthropic_sdk_dart: ^0.1.0
```

### Ollama (Lokal, Offline)
```bash
# Ollama installieren
# macOS/Linux:
curl -fsSL https://ollama.ai/install.sh | sh

# Windows:
# Download von https://ollama.ai

# Model herunterladen
ollama pull llama2

# Server starten
ollama serve
```

```yaml
dependencies:
  ollama_dart: ^0.1.0
```

```dart
// In lib/services/ai_service.dart:
final ollama = OllamaClient(baseUrl: 'http://localhost:11434');
```

**Vorteile Ollama:**
- ✅ Komplett offline
- ✅ Keine API-Kosten
- ✅ Datenschutz (alles lokal)
- ❌ Benötigt starken PC (8GB+ RAM)

## 📱 Plattform-spezifische Hinweise

### macOS
```bash
# Permissions für Netzwerk:
# DebugProfile.entitlements und Release.entitlements prüfen
```

### Windows
```bash
# Visual Studio 2022 oder Build Tools benötigt
```

### Android
```bash
# Internet Permission bereits konfiguriert
```

### iOS
```bash
# Internet Permission bereits konfiguriert
```

## 🔧 Troubleshooting

### "API Key ungültig"
- ✅ Prüfe, ob der Key korrekt kopiert wurde
- ✅ Keine Leerzeichen am Anfang/Ende
- ✅ Key zwischen ' ' setzen

### "Build failed"
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### "No connected devices"
```bash
# Simulator/Emulator starten
flutter emulators --launch <emulator_id>

# Oder verfügbare Geräte anzeigen:
flutter devices
```

## 📚 Projektstruktur

```
lib/
├── config/
│   └── app_config.dart         # ⚠️ API Key hier eintragen
├── models/
│   ├── message.dart            # Chat-Nachrichten
│   ├── message.g.dart          # Auto-generiert
│   ├── scrum_ceremony.dart     # Zeremonien-Modell
│   └── scrum_ceremony.g.dart   # Auto-generiert
├── providers/
│   └── chat_provider.dart      # State Management
├── screens/
│   └── chat_screen.dart        # Haupt-UI
├── services/
│   ├── ai_service.dart         # LLM Integration
│   └── storage_service.dart    # Lokaler Speicher
├── widgets/
│   ├── ceremony_selector.dart  # Zeremonien-Auswahl
│   └── message_bubble.dart     # Chat-Bubble
└── main.dart                   # App Entry Point
```

## 🎨 Features testen

### 1. Normale Chat-Nachricht
- Öffne App
- Tippe: "Was ist ein Daily Standup?"
- AI antwortet

### 2. Zeremonie starten
- Klicke auf Kalender-Icon (📅)
- Wähle "Daily Standup"
- AI führt durch das Meeting

### 3. Sentiment-Analyse
- Menü öffnen (⋮)
- "Sentiment analysieren"
- Text eingeben: "Das Team ist frustriert wegen der vielen Bugs"
- AI analysiert Stimmung

### 4. Sprint-Ziel generieren
- Menü → "Sprint-Ziel generieren"
- Eingeben:
  ```
  User Login implementieren
  Dashboard erstellen
  API Integration
  ```
- AI generiert Sprint Goal

### 5. Retrospektive
- Menü → "Retrospektive analysieren"
- Eingeben:
  ```
  Zu viele Meetings
  Code Review dauert zu lange
  Gute Zusammenarbeit im Team
  ```
- AI gibt Handlungsempfehlungen

## 💡 Tipps

### Performance verbessern
```dart
// In app_config.dart:
generationConfig: GenerationConfig(
  temperature: 0.5,  // Weniger kreativ = schneller
  maxOutputTokens: 1024,  // Kürzere Antworten
),
```

### Kosten sparen
- Verwende Ollama (lokal)
- Setze `maxOutputTokens` niedriger
- Cache häufige Antworten

### Datenschutz
- ⚠️ API Keys nie in Git committen
- ✅ Verwende Environment Variables für Production
- ✅ Oder nutze Ollama (alles lokal)

## 🌍 Sprache ändern

Die App ist auf Deutsch, aber du kannst sie leicht auf Englisch umstellen:

```dart
// In lib/config/app_config.dart:
static const String systemPrompt = '''
You are an experienced Scrum Master...
''';
```

## ⚡ Next Steps

1. **API Key eintragen** ← ZUERST!
2. **App starten** mit `flutter run`
3. **Features testen**
4. **LLM wechseln** (optional)
5. **Anpassen** nach Bedarf

Viel Erfolg! 🚀

---

**Probleme?** Schaue in die [README.md](README.md) oder öffne ein Issue!
