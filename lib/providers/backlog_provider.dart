import 'package:flutter/foundation.dart';
import 'package:agile_ai/models/backlog_item.dart';
import 'package:agile_ai/models/sprint_data.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/services/database_service.dart';

class BacklogProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final SettingsProvider _settingsProvider;

  List<BacklogItem> _items = [];
  List<SprintData> _sprints = [];
  bool _isLoading = false;

  BacklogProvider(this._settingsProvider) {
    _load();
  }

  List<BacklogItem> get items => List.unmodifiable(_items);
  List<SprintData> get sprints => List.unmodifiable(_sprints);
  bool get isLoading => _isLoading;

  List<BacklogItem> get backlogItems =>
      _items.where((i) => i.sprintNumber == null && i.status == BacklogStatus.todo).toList();

  List<BacklogItem> itemsForSprint(int sprintNumber) =>
      _items.where((i) => i.sprintNumber == sprintNumber).toList();

  List<BacklogItem> get currentSprintItems =>
      itemsForSprint(_settingsProvider.currentSprintNumber);

  Future<void> _load() async {
    _items = await _db.loadBacklogItems();
    _sprints = await _db.loadAllSprints();
    notifyListeners();
  }

  Future<void> addItem(BacklogItem item) async {
    _items.add(item);
    await _db.saveBacklogItem(item);
    notifyListeners();
  }

  Future<void> updateItem(BacklogItem updated) async {
    final index = _items.indexWhere((i) => i.id == updated.id);
    if (index != -1) {
      _items[index] = updated;
      await _db.saveBacklogItem(updated);
      notifyListeners();
    }
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _db.deleteBacklogItem(id);
    notifyListeners();
  }

  Future<void> assignToSprint(String itemId, int sprintNumber) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      // sprintNumber == 0 bedeutet: aus Sprint entfernen → zurück in Backlog
      final newSprint = sprintNumber <= 0 ? null : sprintNumber;
      _items[index] = _items[index].copyWith(
        sprintNumber: newSprint,
        clearSprintNumber: newSprint == null,
      );
      await _db.saveBacklogItem(_items[index]);
      notifyListeners();
    }
  }

  Future<void> updateStatus(String itemId, BacklogStatus status) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(status: status);
      await _db.saveBacklogItem(_items[index]);
      notifyListeners();
    }
  }

  // ─── KI-Aktionen ──────────────────────────────────────────────────────────

  Future<String> estimateItem(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _settingsProvider.aiService.estimateStoryPoints(
        '${item.title}\n${item.description}',
      );
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> generateAcceptanceCriteria(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    _isLoading = true;
    notifyListeners();
    try {
      return await _settingsProvider.aiService
          .generateAcceptanceCriteria('${item.title}\n${item.description}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> validateInvest(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    _isLoading = true;
    notifyListeners();
    try {
      return await _settingsProvider.aiService
          .validateInvest('${item.title}\n${item.description}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Sprint-Verwaltung ────────────────────────────────────────────────────

  Future<void> saveSprint(SprintData sprint) async {
    final index = _sprints.indexWhere((s) => s.sprintNumber == sprint.sprintNumber);
    if (index != -1) {
      _sprints[index] = sprint;
    } else {
      _sprints.add(sprint);
    }
    await _db.saveSprintData(sprint);
    notifyListeners();
  }

  int get totalPointsCurrentSprint => currentSprintItems
      .where((i) => i.storyPoints != null)
      .fold(0, (sum, i) => sum + i.storyPoints!);

  int get completedPointsCurrentSprint => currentSprintItems
      .where((i) => i.status == BacklogStatus.done && i.storyPoints != null)
      .fold(0, (sum, i) => sum + i.storyPoints!);
}
