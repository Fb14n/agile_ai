# 🤖 ScrumMaster AI

> ⚠️ **Important:** This application requires a Google Gemini API key to function. Without a valid API key, the app will not work at all.
> 
> 👉 **[How to get a free Google Gemini API key](https://aistudio.google.com/app/apikey)**
> 
> Once you have your key, open `lib/config/app_config.dart` and replace `YOUR_API_KEY_HERE` with your key.

An intelligent virtual Scrum Master that guides teams through Scrum ceremonies and provides AI-powered insights.

## ✨ Features

- 💬 **Intelligent Chatbot** - Communicate with an AI-powered Scrum Master
- 📅 **Scrum Ceremonies** - Support for all Scrum events:
  - Daily Standup
  - Sprint Planning
  - Sprint Review
  - Sprint Retrospective
  - Backlog Refinement
- 📊 **Sentiment Analysis** - Automatic mood analysis of meeting texts
- 🎯 **Sprint Goal Generation** - AI-generated Sprint Goals based on Backlog Items
- 🔍 **Retrospective Analysis** - Evaluation and action recommendations for retros
- 💾 **Local Storage** - All chat histories are stored locally
- 🌓 **Dark Mode** - Automatic Dark/Light Mode support

## 🚀 Installation & Setup

### Prerequisites

- Flutter SDK (>=3.10.7)
- Dart SDK
- Google Gemini API Key

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure API Key

Open `lib/config/app_config.dart` and insert your Google Gemini API Key:

```dart
static const String geminiApiKey = 'YOUR_API_KEY_HERE';
```

**How do I get an API Key?**

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google Account
3. Create a new API Key
4. Copy the key and paste it into the config

### 3. Generate code

Generate the JSON serialization files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the app

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

## 🏗️ Project Structure

```
lib/
├── config/          # App configuration & API Keys
├── models/          # Data models (Message, ScrumCeremony)
├── providers/       # State Management (ChatProvider)
├── screens/         # UI Screens (ChatScreen)
├── services/        # Backend services (AI, Storage)
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

## 🎯 Usage

### Regular Conversation
1. Open the app
2. Type a message
3. The ScrumMaster AI responds with helpful tips

### Starting a Ceremony
1. Tap the calendar icon (📅)
2. Select a ceremony
3. The AI guides you through the meeting

### Analyzing Sentiment
1. Open the menu (⋮)
2. Select "Analyze Sentiment"
3. Paste meeting text
4. Receive a mood rating

### Generating a Sprint Goal
1. Open the menu (⋮)
2. Select "Generate Sprint Goal"
3. Paste Backlog Items (one item per line)
4. Receive an AI-generated Sprint Goal

### Analyzing a Retrospective
1. Open the menu (⋮)
2. Select "Analyze Retrospective"
3. Paste retro points
4. Receive a summary and action recommendations

## 🤖 LLM Options

The app uses **Google Gemini Pro** by default. Alternatively, you can also use:

### OpenAI GPT-4
```dart
// In lib/services/ai_service.dart
// Use the package: openai_api
```

### Anthropic Claude
```dart
// In lib/services/ai_service.dart
// Use the package: anthropic_sdk_dart
```

### Local LLMs (Ollama)
```dart
// Install Ollama: https://ollama.ai
// Use the ollama_dart package
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS

## 🔧 Technology Stack

- **Framework:** Flutter 3.x
- **State Management:** Provider
- **LLM:** Google Gemini Pro
- **Storage:** Shared Preferences
- **UI:** Material Design 3

## 📝 License

This project was created for educational purposes.

## 🤝 Contribution

Feedback and suggestions for improvement are welcome!

## ⚠️ Notes

- The API Key should NEVER be committed to public repositories
- For production apps: store the API Key in environment variables
- The app requires an internet connection for AI features

## 📚 Further Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Google Gemini API](https://ai.google.dev/)
- [Scrum Guide](https://scrumguides.org/)

---

Good luck with your virtual Scrum Master! 🚀
