import 'package:flutter/foundation.dart';
import 'package:agile_ai/models/app_settings.dart';
import 'package:agile_ai/services/storage_service.dart';
import 'package:agile_ai/services/ai_service.dart';

/// Verwaltet alle App-weiten Einstellungen: Sprache, KI-Modell, Persona.
/// Alle anderen Provider erhalten eine Referenz auf diesen Provider,
/// damit sie AiService mit den richtigen Einstellungen neu konfigurieren können.
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  AppSettings _settings = const AppSettings();
  AiService? _sharedAiService;

  bool _isLoaded = false;

  AppSettings get settings => _settings;
  String get language => _settings.language;
  String get aiModel => _settings.aiModel;
  String get personaStyle => _settings.personaStyle;
  bool get onboardingComplete => _settings.onboardingComplete;
  int get currentSprintNumber => _settings.currentSprintNumber;
  bool get isLoaded => _isLoaded;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    _settings = await _storage.loadSettings();
    _isLoaded = true;
    notifyListeners();
  }

  /// Gibt einen (geteilten) AiService zurück, der mit aktuellen Settings konfiguriert ist
  AiService get aiService {
    _sharedAiService ??= AiService(
      language: _settings.language,
      persona: _settings.personaStyle,
      modelId: _settings.aiModel,
    );
    return _sharedAiService!;
  }

  Future<void> setLanguage(String lang) async {
    _settings = _settings.copyWith(language: lang);
    _sharedAiService?.reconfigure(language: lang);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setAiModel(String modelId) async {
    _settings = _settings.copyWith(aiModel: modelId);
    _sharedAiService?.reconfigure(modelId: modelId);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setPersonaStyle(String persona) async {
    _settings = _settings.copyWith(personaStyle: persona);
    _sharedAiService?.reconfigure(persona: persona);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _settings = _settings.copyWith(onboardingComplete: true);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setSprintNumber(int number) async {
    _settings = _settings.copyWith(currentSprintNumber: number);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> resetAllData() async {
    await _storage.clearAll();
    _settings = const AppSettings(onboardingComplete: true);
    _sharedAiService = null;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }
}
