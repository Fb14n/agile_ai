class AppConfig {
  // LLM Configuration
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // App Information
  static const String appName = 'AgileAI';
  static const String appVersion = '1.0.0';
  
  // Scrum Ceremonies
  static const List<String> ceremonies = [
    'Daily Standup',
    'Sprint Planning',
    'Sprint Review',
    'Sprint Retrospective',
    'Backlog Refinement',
  ];
  
  // AI Prompts
  static const String systemPrompt = '''
You are an experienced Scrum Master assistant. Your role is to:
- Guide teams through Scrum ceremonies
- Provide helpful suggestions and best practices
- Analyze team sentiment and provide insights
- Generate sprint goals and summaries
- Be supportive, professional, and constructive

Always maintain a positive and encouraging tone while being practical and actionable.
''';
}
