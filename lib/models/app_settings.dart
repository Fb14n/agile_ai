/// App settings – not JSON-serialized, stored directly via SharedPreferences.
class AppSettings {
  final String aiModel;          // Gemini/Gemma model ID
  final String personaStyle;     // 'coach' | 'direct' | 'formal' | 'casual'
  final String themeMode;        // 'light' | 'dark' | 'system'
  final bool onboardingComplete;

  const AppSettings({
    this.aiModel = 'gemma-3-27b-it',
    this.personaStyle = 'coach',
    this.themeMode = 'system',
    this.onboardingComplete = false,
  });

  AppSettings copyWith({
    String? aiModel,
    String? personaStyle,
    String? themeMode,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      aiModel: aiModel ?? this.aiModel,
      personaStyle: personaStyle ?? this.personaStyle,
      themeMode: themeMode ?? this.themeMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
