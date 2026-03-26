import 'package:flutter/foundation.dart';
import 'package:agile_ai/models/project_context.dart';
import 'package:agile_ai/services/project_service.dart';

/// Provider for project context editing
class ContextProvider with ChangeNotifier {
  final ProjectService _projectService;

  ContextProvider(this._projectService);

  List<ProjectContext> _contexts = [];
  bool _isLoading = false;
  String? _error;

  List<ProjectContext> get contexts => _contexts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadContexts(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _contexts = await _projectService.getProjectContext(projectId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load contexts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContext(ProjectContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _projectService.addContext(context);
      await loadContexts(context.projectId);
      _error = null;
    } catch (e) {
      _error = 'Failed to add context: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateContext(ProjectContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _projectService.updateContext(context);
      await loadContexts(context.projectId);
      _error = null;
    } catch (e) {
      _error = 'Failed to update context: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteContext(String contextId, String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _projectService.deleteContext(contextId);
      await loadContexts(projectId);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete context: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
