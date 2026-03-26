import 'package:agile_ai/models/project.dart';
import 'package:agile_ai/models/sprint.dart';
import 'package:agile_ai/models/user_story.dart';
import 'package:agile_ai/models/project_team_member.dart';
import 'package:agile_ai/models/project_context.dart';
import 'package:agile_ai/services/database_service.dart';

/// Service for project-related business logic and CRUD operations.
class ProjectService {
  final DatabaseService _dbService;

  ProjectService(this._dbService);

  // ─── Projects ──────────────────────────────────────────────────────────────

  Future<List<Project>> getAllProjects() async {
    return await _dbService.loadAllProjects();
  }

  Future<Project?> getProject(String id) async {
    return await _dbService.loadProject(id);
  }

  Future<void> createProject(Project project) async {
    await _dbService.saveProject(project);
  }

  Future<void> updateProject(Project project) async {
    await _dbService.saveProject(project.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteProject(String id) async {
    await _dbService.deleteProject(id);
  }

  Future<void> archiveProject(String id) async {
    final project = await _dbService.loadProject(id);
    if (project != null) {
      await _dbService.saveProject(
        project.copyWith(
          status: ProjectStatus.archived,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  // ─── Sprints ───────────────────────────────────────────────────────────────

  Future<List<Sprint>> getSprintsByProject(String projectId) async {
    return await _dbService.loadSprintsByProject(projectId);
  }

  Future<Sprint?> getCurrentSprint(String projectId) async {
    final sprints = await _dbService.loadSprintsByProject(projectId);
    return sprints.where((s) => s.status == SprintStatus.active).firstOrNull;
  }

  Future<void> createSprint(Sprint sprint) async {
    await _dbService.saveSprint(sprint);
  }

  Future<void> updateSprint(Sprint sprint) async {
    await _dbService.saveSprint(sprint);
  }

  Future<void> completeSprint(String sprintId) async {
    final sprint = await _dbService.loadSprint(sprintId);
    if (sprint != null) {
      await _dbService.saveSprint(
        sprint.copyWith(status: SprintStatus.completed),
      );
      
      // Update project average velocity
      final project = await _dbService.loadProject(sprint.projectId);
      if (project != null) {
        final allSprints = await _dbService.loadSprintsByProject(sprint.projectId);
        final completedSprints = allSprints.where((s) => s.status == SprintStatus.completed);
        
        if (completedSprints.isNotEmpty) {
          final avgVelocity = completedSprints
              .map((s) => s.completedStoryPoints)
              .reduce((a, b) => a + b) / completedSprints.length;
          
          await _dbService.saveProject(
            project.copyWith(
              averageVelocity: avgVelocity,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
    }
  }

  // ─── User Stories ──────────────────────────────────────────────────────────

  Future<List<UserStory>> getUserStoriesByProject(String projectId) async {
    return await _dbService.loadUserStoriesByProject(projectId);
  }

  Future<List<UserStory>> getUserStoriesBySprint(String sprintId) async {
    return await _dbService.loadUserStoriesBySprint(sprintId);
  }

  Future<List<UserStory>> getBacklogStories(String projectId) async {
    final stories = await _dbService.loadUserStoriesByProject(projectId);
    return stories.where((s) => s.sprintId == null).toList();
  }

  Future<void> createUserStory(UserStory story) async {
    await _dbService.saveUserStory(story);
  }

  Future<void> updateUserStory(UserStory story) async {
    await _dbService.saveUserStory(story.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteUserStory(String id) async {
    await _dbService.deleteUserStory(id);
  }

  Future<void> assignStoryToSprint(String storyId, String sprintId) async {
    final stories = await _dbService.loadUserStoriesByProject('');
    final story = stories.where((s) => s.id == storyId).firstOrNull;
    if (story != null) {
      await _dbService.saveUserStory(
        story.copyWith(sprintId: sprintId, updatedAt: DateTime.now()),
      );
    }
  }

  // ─── Team Members ──────────────────────────────────────────────────────────

  Future<List<ProjectTeamMember>> getTeamMembers(String projectId) async {
    return await _dbService.loadTeamMembersByProject(projectId);
  }

  Future<void> addTeamMember(ProjectTeamMember member) async {
    await _dbService.saveTeamMember(member);
  }

  Future<void> updateTeamMember(ProjectTeamMember member) async {
    await _dbService.saveTeamMember(member);
  }

  Future<void> removeTeamMember(String id) async {
    await _dbService.deleteTeamMember(id);
  }

  // ─── Project Context ───────────────────────────────────────────────────────

  Future<List<ProjectContext>> getProjectContext(String projectId) async {
    return await _dbService.loadContextByProject(projectId);
  }

  Future<void> addContext(ProjectContext context) async {
    await _dbService.saveProjectContext(context);
  }

  Future<void> updateContext(ProjectContext context) async {
    await _dbService.saveProjectContext(context.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteContext(String id) async {
    await _dbService.deleteProjectContext(id);
  }

  /// Builds a comprehensive context string for AI system prompt
  Future<String> buildAIContext(String projectId) async {
    final project = await _dbService.loadProject(projectId);
    if (project == null) return '';

    final team = await _dbService.loadTeamMembersByProject(projectId);
    final context = await _dbService.loadContextByProject(projectId);
    final currentSprint = await getCurrentSprint(projectId);

    final buffer = StringBuffer();
    buffer.writeln('# Projekt: ${project.name}');
    buffer.writeln(project.description);
    buffer.writeln();
    buffer.writeln('## Team (${team.length} Mitglieder)');
    for (final member in team) {
      buffer.writeln('- ${member.name} (${member.role})');
    }
    buffer.writeln();
    
    if (currentSprint != null) {
      buffer.writeln('## Aktueller Sprint ${currentSprint.sprintNumber}');
      buffer.writeln('Goal: ${currentSprint.goal}');
      buffer.writeln('Status: ${currentSprint.completedStoryPoints}/${currentSprint.plannedStoryPoints} SP');
      buffer.writeln();
    }

    if (context.isNotEmpty) {
      buffer.writeln('## Projekt-Kontext');
      for (final ctx in context) {
        buffer.writeln('**${ctx.key}:** ${ctx.value}');
      }
    }

    return buffer.toString();
  }

  // ─── Statistics ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProjectStatistics(String projectId) async {
    final stories = await _dbService.loadUserStoriesByProject(projectId);
    final sprints = await _dbService.loadSprintsByProject(projectId);
    
    final totalStories = stories.length;
    final doneStories = stories.where((s) => s.status == StoryStatus.done).length;
    final inProgressStories = stories.where((s) => s.status == StoryStatus.inProgress).length;
    
    final totalSP = stories.fold<int>(0, (sum, s) => sum + s.storyPoints);
    final completedSP = stories
        .where((s) => s.status == StoryStatus.done)
        .fold<int>(0, (sum, s) => sum + s.storyPoints);
    
    final completedSprints = sprints.where((s) => s.status == SprintStatus.completed).length;
    
    return {
      'totalStories': totalStories,
      'doneStories': doneStories,
      'inProgressStories': inProgressStories,
      'completionRate': totalStories > 0 ? (doneStories / totalStories * 100).toStringAsFixed(1) : '0.0',
      'totalStoryPoints': totalSP,
      'completedStoryPoints': completedSP,
      'completedSprints': completedSprints,
      'totalSprints': sprints.length,
    };
  }
}
