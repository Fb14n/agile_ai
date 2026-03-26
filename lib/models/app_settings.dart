/// App settings – not JSON-serialized, stored directly via SharedPreferences.
class AppSettings {
  final String language;         // 'de' | 'en'
  final String aiModel;          // Gemini/Gemma model ID
  final String personaStyle;     // 'coach' | 'direct' | 'formal' | 'casual'
  final String themeMode;        // 'light' | 'dark' | 'system'
  final bool onboardingComplete;
  final int currentSprintNumber;

  const AppSettings({
    this.language = 'de',
    this.aiModel = 'gemma-3-27b-it',
    this.personaStyle = 'coach',
    this.themeMode = 'system',
    this.onboardingComplete = false,
    this.currentSprintNumber = 1,
  });

  AppSettings copyWith({
    String? language,
    String? aiModel,
    String? personaStyle,
    String? themeMode,
    bool? onboardingComplete,
    int? currentSprintNumber,
  }) {
    return AppSettings(
      language: language ?? this.language,
      aiModel: aiModel ?? this.aiModel,
      personaStyle: personaStyle ?? this.personaStyle,
      themeMode: themeMode ?? this.themeMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      currentSprintNumber: currentSprintNumber ?? this.currentSprintNumber,
    );
  }
}
