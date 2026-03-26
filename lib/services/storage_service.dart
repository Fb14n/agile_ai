import 'package:shared_preferences/shared_preferences.dart';
import 'package:agile_ai/models/app_settings.dart';

/// Storage service for persisting app settings and API key using SharedPreferences.
/// NOTE: Messages, ceremonies, and all Scrum data are now stored in SQLite via DatabaseService.
class StorageService {
  static const String _apiKeyKey = 'api_key';
  static const String _langKey = 'settings_language';
  static const String _modelKey = 'settings_model';
  static const String _personaKey = 'settings_persona';
  static const String _onboardingKey = 'settings_onboarding';
  static const String _sprintNumberKey = 'settings_sprint_number';

  // ─── API key ──────────────────────────────────────────────────────────────

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  Future<String?> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, settings.language);
    await prefs.setString(_modelKey, settings.aiModel);
    await prefs.setString(_personaKey, settings.personaStyle);
    await prefs.setBool(_onboardingKey, settings.onboardingComplete);
    await prefs.setInt(_sprintNumberKey, settings.currentSprintNumber);
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      language: prefs.getString(_langKey) ?? 'de',
      aiModel: prefs.getString(_modelKey) ?? 'gemma-3-27b-it',
      personaStyle: prefs.getString(_personaKey) ?? 'coach',
      onboardingComplete: prefs.getBool(_onboardingKey) ?? false,
      currentSprintNumber: prefs.getInt(_sprintNumberKey) ?? 1,
    );
  }

  // ─── Clear ────────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

