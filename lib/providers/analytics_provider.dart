import 'package:flutter/foundation.dart';
import 'package:agile_ai/models/scrum_ceremony.dart';
import 'package:agile_ai/models/sprint_data.dart';
import 'package:agile_ai/services/storage_service.dart';
import 'package:agile_ai/services/database_service.dart';

/// Aggregates sentiment data, velocity, and retro themes from stored data.
class AnalyticsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final DatabaseService _db = DatabaseService();

  List<ScrumCeremony> _ceremonies = [];
  List<SprintData> _sprints = [];

  AnalyticsProvider() {
    _load();
  }

  Future<void> _load() async {
    _ceremonies = await _storage.loadCeremonies();
    _sprints = await _db.loadAllSprints();
    notifyListeners();
  }

  Future<void> refresh() => _load();

  List<ScrumCeremony> get allCeremonies => List.unmodifiable(_ceremonies);

  // ─── Sentiment ────────────────────────────────────────────────────────────

  /// Sentiment scores from the last n ceremonies that have sentiment data.
  List<Map<String, dynamic>> get sentimentHistory {
    return _ceremonies
        .where((c) => c.sentiment != null && c.sentiment!['score'] != null)
        .map((c) => {
              'date': c.startTime,
              'ceremony': c.name,
              'score': (c.sentiment!['score'] as num).toDouble(),
            })
        .toList()
      ..sort((a, b) =>
          (a['date'] as DateTime).compareTo(b['date'] as DateTime));
  }

  double get averageSentiment {
    final scores = sentimentHistory.map((s) => s['score'] as double).toList();
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  String get sentimentTrend {
    final history = sentimentHistory;
    if (history.length < 2) return 'neutral';
    final last = history.last['score'] as double;
    final prev = history[history.length - 2]['score'] as double;
    if (last > prev + 0.5) return 'up';
    if (last < prev - 0.5) return 'down';
    return 'neutral';
  }

  // ─── Velocity ─────────────────────────────────────────────────────────────

  List<SprintData> get velocityHistory =>
      _sprints.where((s) => s.velocity != null).toList();

  double get averageVelocity {
    final vels = velocityHistory.map((s) => s.velocity!).toList();
    if (vels.isEmpty) return 0;
    return vels.reduce((a, b) => a + b) / vels.length;
  }

  // ─── Ceremony statistics ──────────────────────────────────────────────────

  int get totalCeremonies => _ceremonies.length;

  Map<String, int> get ceremonyCounts {
    final counts = <String, int>{};
    for (final c in _ceremonies) {
      counts[c.name] = (counts[c.name] ?? 0) + 1;
    }
    return counts;
  }

  int get totalActionItems =>
      _ceremonies.fold(0, (sum, c) => sum + c.actionItems.length);

  int get completedActionItems => _ceremonies.fold(
      0, (sum, c) => sum + c.actionItems.where((a) => a.completed).length);

  double get actionItemCompletionRate {
    if (totalActionItems == 0) return 0;
    return completedActionItems / totalActionItems;
  }

  /// Returns the last retro summaries.
  List<String> get retroSummaries => _ceremonies
      .where((c) =>
          c.name == 'Sprint Retrospective' && c.summary != null)
      .map((c) => c.summary!)
      .toList();

  // ─── Team health score (0.0–1.0) ─────────────────────────────────────────

  double get teamHealthScore {
    double score = 0.5; // baseline
    if (averageSentiment > 0) {
      score += (averageSentiment / 10) * 0.3;
    }
    if (totalActionItems > 0) {
      score += actionItemCompletionRate * 0.2;
    }
    return score.clamp(0.0, 1.0);
  }

  String get healthLabel {
    final s = teamHealthScore;
    if (s >= 0.75) return '🟢 Gut';
    if (s >= 0.5) return '🟡 Mittel';
    return '🔴 Verbesserungsbedarf';
  }
}
