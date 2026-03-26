import 'package:flutter/foundation.dart';
import 'package:agile_ai/models/project.dart';
import 'package:agile_ai/models/sprint.dart';
import 'package:agile_ai/models/user_story.dart';
import 'package:agile_ai/models/meeting.dart';
import 'package:agile_ai/models/project_team_member.dart';
import 'package:agile_ai/services/project_service.dart';

/// Provider for project-related state management
class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService;

  ProjectProvider(this._projectService);

  // Current state
  List<Project> _projects = [];
  Project? _currentProject;
  List<Sprint> _sprints = [];
  List<UserStory> _userStories = [];
  List<Meeting> _meetings = [];
  List<ProjectTeamMember> _teamMembers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;
  List<Sprint> get sprints => _sprints;
  Sprint? get currentSprint =>
      _sprints.where((s) => s.status == SprintStatus.active).firstOrNull;
  List<UserStory> get userStories => _userStories;
  List<UserStory> get backlogStories =>
      _userStories.where((s) => s.sprintId == null).toList();
  List<Meeting> get meetings => _meetings;
  List<ProjectTeamMember> get teamMembers => _teamMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCurrentProject => _currentProject != null;

  // ─── Project Management ────────────────────────────────────────────────────

  Future<void> loadProjects() async {
    _setLoading(true);
    try {
      _projects = await _projectService.getAllProjects();
      _error = null;
    } catch (e) {
      _error = 'Failed to load projects: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectProject(String projectId) async {
    _setLoading(true);
    try {
      _currentProject = await _projectService.getProject(projectId);
      if (_currentProject != null) {
        await _loadProjectData(projectId);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to select project: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadProjectData(String projectId) async {
    _sprints = await _projectService.getSprintsByProject(projectId);
    _userStories = await _projectService.getUserStoriesByProject(projectId);
    _meetings = await _projectService.getMeetingsByProject(projectId);
    _teamMembers = await _projectService.getTeamMembers(projectId);
  }

  Future<void> createProject(Project project) async {
    _setLoading(true);
    try {
      await _projectService.createProject(project);
      await loadProjects();
      _error = null;
    } catch (e) {
      _error = 'Failed to create project: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProject(Project project) async {
    _setLoading(true);
    try {
      await _projectService.updateProject(project);
      if (_currentProject?.id == project.id) {
        _currentProject = project;
      }
      await loadProjects();
      _error = null;
    } catch (e) {
      _error = 'Failed to update project: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProject(String projectId) async {
    _setLoading(true);
    try {
      await _projectService.deleteProject(projectId);
      if (_currentProject?.id == projectId) {
        _currentProject = null;
        _sprints = [];
        _userStories = [];
        _teamMembers = [];
      }
      await loadProjects();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete project: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> archiveProject(String projectId) async {
    _setLoading(true);
    try {
      await _projectService.archiveProject(projectId);
      await loadProjects();
      _error = null;
    } catch (e) {
      _error = 'Failed to archive project: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Sprint Management ─────────────────────────────────────────────────────

  Future<void> startNewSprint(String goal) async {
    if (_currentProject == null) return;
    
    _setLoading(true);
    try {
      final nextSprintNumber = _currentProject!.currentSprintNumber + 1;
      final sprint = Sprint(
        projectId: _currentProject!.id,
        sprintNumber: nextSprintNumber,
        goal: goal,
        status: SprintStatus.active,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: _currentProject!.sprintLengthWeeks * 7)),
      );
      
      await _projectService.createSprint(sprint);
      
      // Update project's current sprint number
      await _projectService.updateProject(
        _currentProject!.copyWith(currentSprintNumber: nextSprintNumber),
      );
      
      _currentProject = _currentProject!.copyWith(currentSprintNumber: nextSprintNumber);
      await _loadProjectData(_currentProject!.id);
      _error = null;
    } catch (e) {
      _error = 'Failed to start sprint: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createSprint(Sprint sprint) async {
    _setLoading(true);
    try {
      await _projectService.createSprint(sprint);
      if (_currentProject != null) {
        await _loadProjectData(_currentProject!.id);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to create sprint: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeSprint(String sprintId) async {
    _setLoading(true);
    try {
      await _projectService.completeSprint(sprintId);
      if (_currentProject != null) {
        await _loadProjectData(_currentProject!.id);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to complete sprint: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── User Story Management ─────────────────────────────────────────────────

  Future<void> createUserStory(UserStory story) async {
    _setLoading(true);
    try {
      await _projectService.createUserStory(story);
      if (_currentProject != null) {
        _userStories = await _projectService.getUserStoriesByProject(_currentProject!.id);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to create user story: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserStory(UserStory story) async {
    _setLoading(true);
    try {
      await _projectService.updateUserStory(story);
      if (_currentProject != null) {
        _userStories = await _projectService.getUserStoriesByProject(_currentProject!.id);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to update user story: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUserStory(String storyId) async {
    _setLoading(true);
    try {
      await _projectService.deleteUserStory(storyId);
      if (_currentProject != null) {
        _userStories = await _projectService.getUserStoriesByProject(_currentProject!.id);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to delete user story: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Team Management ───────────────────────────────────────────────────────

  Future<void> addTeamMember(ProjectTeamMember member) async {
    _setLoading(true);
    try {
      await _projectService.addTeamMember(member);
      if (_currentProject != null) {
        _teamMembers = await _projectService.getTeamMembers(_currentProject!.id);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to add team member: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeTeamMember(String memberId) async {
    _setLoading(true);
    try {
      await _projectService.removeTeamMember(memberId);
      if (_currentProject != null) {
        _teamMembers = await _projectService.getTeamMembers(_currentProject!.id);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to remove team member: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Statistics ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStatistics() async {
    if (_currentProject == null) return {};
    return await _projectService.getProjectStatistics(_currentProject!.id);
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
