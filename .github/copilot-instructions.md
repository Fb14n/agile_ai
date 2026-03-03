# AgileAI – Copilot Instructions

Flutter app that acts as an AI-powered virtual Scrum Master, guiding teams through Scrum ceremonies via a chat interface backed by Google Gemini.

## Commands

```bash
# Install dependencies
flutter pub get

# Regenerate JSON serialization code (required after editing any @JsonSerializable model)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run -d macos     # macOS
flutter run -d windows   # Windows
flutter run              # Android/iOS

# Lint
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart
```

## Architecture

The app uses a **Provider-based MVVM** pattern with a single `ChangeNotifier`:

```
Screens/Widgets  →  ChatProvider (ChangeNotifier)  →  AiService / StorageService
                                                              ↓
                                                    Google Gemini API / SharedPreferences
```

- **`lib/config/app_config.dart`** — single source of truth for API key, Gemini model name, system prompt, and the ceremonies list. Change the model or system prompt here, not in `ai_service.dart`.
- **`lib/providers/chat_provider.dart`** — the only `ChangeNotifier`. Owns `_messages`, `_isLoading`, and `_currentCeremony`. All AI calls go through here; it writes to storage after every state change.
- **`lib/services/ai_service.dart`** — wraps the Gemini SDK. Two distinct usage patterns:
  - **Persistent chat session** (`_chat`): used by `sendMessage()` and `facilitateCeremony()` — maintains conversation history.
  - **Stateless single requests** (`_model.generateContent()`): used by `analyzeSentiment()`, `generateSprintGoal()`, `analyzeRetrospective()` — no context carried over.
- **`lib/services/storage_service.dart`** — persists messages and ceremonies as JSON via `SharedPreferences`. Keys: `"messages"`, `"ceremonies"`, `"api_key"`.

## Key Conventions

### Models and code generation
Models in `lib/models/` use `@JsonSerializable` with generated `*.g.dart` files. After editing a model, always run:
```bash
dart run build_runner build --delete-conflicting-outputs
```
Never manually edit `*.g.dart` files.

### MessageType drives UI rendering
`MessageType` (defined in `message.dart`) controls bubble color and label icon in `MessageBubble`. When adding a new AI response category, add a new enum value and handle it in `lib/widgets/message_bubble.dart`.

### Error handling pattern
Errors are surfaced as chat messages (not exceptions or dialogs). In `ChatProvider`, every async method wraps its AI call in try/catch and appends an error `Message(isUser: false)` on failure, then always clears `_isLoading` in `finally`.

### API key
The key lives in `lib/config/app_config.dart` (`AppConfig.geminiApiKey`). It must **never be committed to a public repository**. For production, move it to environment variables.

### macOS sandbox
For network calls to work on macOS, `com.apple.security.network.client` must be present in both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`. Without it, all Gemini API calls fail silently with "connection failed".

### After dependency changes
`flutter run` (full rebuild) is required after changing `pubspec.yaml` or entitlements. Hot restart (`R`) is sufficient for Dart-only changes.
