import 'package:flutter/foundation.dart';

/// Simplified analytics provider for project-centric structure
class AnalyticsProvider extends ChangeNotifier {
  AnalyticsProvider();

  // Placeholder for future analytics implementation
  Future<void> refresh() async {
    notifyListeners();
  }

  // Future: Load project-specific analytics data
  Future<Map<String, dynamic>> getProjectAnalytics(String projectId) async {
    // TODO: Implement project-specific analytics
    return {};
  }
}
