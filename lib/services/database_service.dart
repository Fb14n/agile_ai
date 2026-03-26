import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:agile_ai/models/project.dart';
import 'package:agile_ai/models/sprint.dart';
import 'package:agile_ai/models/user_story.dart';
import 'package:agile_ai/models/meeting.dart';
import 'package:agile_ai/models/meeting_message.dart';
import 'package:agile_ai/models/project_team_member.dart';
import 'package:agile_ai/models/project_context.dart';

/// SQLite database for project-centric Scrum management.
/// Handles automatic schema migrations and initialization.
class DatabaseService {
  static Database? _db;
  static const int _version = 2;
  static const String _dbName = 'agile_ai.db';

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSchemaV1(db);
    if (version >= 2) {
      // Schema is created, will be seeded by SeedService if DB is empty
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from v1 to v2: Drop old tables, create new schema
      await db.execute('DROP TABLE IF EXISTS backlog_items');
      await db.execute('DROP TABLE IF EXISTS sprint_data');
      await db.execute('DROP TABLE IF EXISTS team_members');
      await _createSchemaV1(db);
    }
  }

  Future<void> _createSchemaV1(Database db) async {
    // Projects table
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        team_size INTEGER NOT NULL DEFAULT 5,
        sprint_length_weeks INTEGER NOT NULL DEFAULT 2,
        current_sprint_number INTEGER NOT NULL DEFAULT 1,
        average_velocity REAL NOT NULL DEFAULT 0.0,
        status TEXT NOT NULL DEFAULT 'active'
      )
    ''');

    // Sprints table
    await db.execute('''
      CREATE TABLE sprints (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        sprint_number INTEGER NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        goal TEXT NOT NULL DEFAULT '',
        planned_story_points INTEGER NOT NULL DEFAULT 0,
        completed_story_points INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'planning',
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    // User Stories table
    await db.execute('''
      CREATE TABLE user_stories (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        sprint_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        story_points INTEGER NOT NULL DEFAULT 0,
        priority TEXT NOT NULL DEFAULT 'medium',
        status TEXT NOT NULL DEFAULT 'todo',
        acceptance_criteria TEXT NOT NULL DEFAULT '[]',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
        FOREIGN KEY (sprint_id) REFERENCES sprints (id) ON DELETE SET NULL
      )
    ''');

    // Meetings table
    await db.execute('''
      CREATE TABLE meetings (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        sprint_id TEXT,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        duration_minutes INTEGER NOT NULL DEFAULT 0,
        participants TEXT NOT NULL DEFAULT '[]',
        summary TEXT NOT NULL DEFAULT '',
        action_items TEXT NOT NULL DEFAULT '[]',
        sentiment_score REAL,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
        FOREIGN KEY (sprint_id) REFERENCES sprints (id) ON DELETE SET NULL
      )
    ''');

    // Meeting Messages table
    await db.execute('''
      CREATE TABLE meeting_messages (
        id TEXT PRIMARY KEY,
        meeting_id TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        content TEXT NOT NULL,
        message_type TEXT NOT NULL DEFAULT 'user',
        timestamp INTEGER NOT NULL,
        metadata TEXT NOT NULL DEFAULT '{}',
        FOREIGN KEY (meeting_id) REFERENCES meetings (id) ON DELETE CASCADE
      )
    ''');

    // Project Team Members table
    await db.execute('''
      CREATE TABLE project_team_members (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'Developer',
        active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    // Project Context table
    await db.execute('''
      CREATE TABLE project_context (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        context_type TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_sprints_project ON sprints(project_id)');
    await db.execute('CREATE INDEX idx_user_stories_project ON user_stories(project_id)');
    await db.execute('CREATE INDEX idx_user_stories_sprint ON user_stories(sprint_id)');
    await db.execute('CREATE INDEX idx_meetings_project ON meetings(project_id)');
    await db.execute('CREATE INDEX idx_meeting_messages_meeting ON meeting_messages(meeting_id)');
    await db.execute('CREATE INDEX idx_team_members_project ON project_team_members(project_id)');
    await db.execute('CREATE INDEX idx_context_project ON project_context(project_id)');
  }

  // ─── Projects ──────────────────────────────────────────────────────────────

  Future<void> saveProject(Project project) async {
    final db = await database;
    await db.insert(
      'projects',
      {
        'id': project.id,
        'name': project.name,
        'description': project.description,
        'created_at': project.createdAt.millisecondsSinceEpoch,
        'updated_at': project.updatedAt.millisecondsSinceEpoch,
        'team_size': project.teamSize,
        'sprint_length_weeks': project.sprintLengthWeeks,
        'current_sprint_number': project.currentSprintNumber,
        'average_velocity': project.averageVelocity,
        'status': project.status.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Project>> loadAllProjects() async {
    final db = await database;
    final rows = await db.query('projects', orderBy: 'created_at DESC');
    return rows.map((r) => _projectFromMap(r)).toList();
  }

  Future<Project?> loadProject(String id) async {
    final db = await database;
    final rows = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _projectFromMap(rows.first);
  }

  Future<void> deleteProject(String id) async {
    final db = await database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Project _projectFromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      teamSize: map['team_size'] as int,
      sprintLengthWeeks: map['sprint_length_weeks'] as int,
      currentSprintNumber: map['current_sprint_number'] as int,
      averageVelocity: map['average_velocity'] as double,
      status: ProjectStatus.fromJson(map['status'] as String),
    );
  }

  // ─── Sprints ───────────────────────────────────────────────────────────────

  Future<void> saveSprint(Sprint sprint) async {
    final db = await database;
    await db.insert(
      'sprints',
      {
        'id': sprint.id,
        'project_id': sprint.projectId,
        'sprint_number': sprint.sprintNumber,
        'start_date': sprint.startDate.millisecondsSinceEpoch,
        'end_date': sprint.endDate.millisecondsSinceEpoch,
        'goal': sprint.goal,
        'planned_story_points': sprint.plannedStoryPoints,
        'completed_story_points': sprint.completedStoryPoints,
        'status': sprint.status.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Sprint>> loadSprintsByProject(String projectId) async {
    final db = await database;
    final rows = await db.query(
      'sprints',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'sprint_number ASC',
    );
    return rows.map((r) => _sprintFromMap(r)).toList();
  }

  Future<Sprint?> loadSprint(String id) async {
    final db = await database;
    final rows = await db.query('sprints', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _sprintFromMap(rows.first);
  }

  Sprint _sprintFromMap(Map<String, dynamic> map) {
    return Sprint(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      sprintNumber: map['sprint_number'] as int,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      goal: map['goal'] as String,
      plannedStoryPoints: map['planned_story_points'] as int,
      completedStoryPoints: map['completed_story_points'] as int,
      status: SprintStatus.fromJson(map['status'] as String),
    );
  }

  // ─── User Stories ──────────────────────────────────────────────────────────

  Future<void> saveUserStory(UserStory story) async {
    final db = await database;
    await db.insert(
      'user_stories',
      {
        'id': story.id,
        'project_id': story.projectId,
        'sprint_id': story.sprintId,
        'title': story.title,
        'description': story.description,
        'story_points': story.storyPoints,
        'priority': story.priority.name,
        'status': story.status.name,
        'acceptance_criteria': jsonEncode(story.acceptanceCriteria),
        'created_at': story.createdAt.millisecondsSinceEpoch,
        'updated_at': story.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserStory>> loadUserStoriesByProject(String projectId) async {
    final db = await database;
    final rows = await db.query(
      'user_stories',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => _userStoryFromMap(r)).toList();
  }

  Future<List<UserStory>> loadUserStoriesBySprint(String sprintId) async {
    final db = await database;
    final rows = await db.query(
      'user_stories',
      where: 'sprint_id = ?',
      whereArgs: [sprintId],
    );
    return rows.map((r) => _userStoryFromMap(r)).toList();
  }

  Future<void> deleteUserStory(String id) async {
    final db = await database;
    await db.delete('user_stories', where: 'id = ?', whereArgs: [id]);
  }

  UserStory _userStoryFromMap(Map<String, dynamic> map) {
    return UserStory(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      sprintId: map['sprint_id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      storyPoints: map['story_points'] as int,
      priority: StoryPriority.fromJson(map['priority'] as String),
      status: StoryStatus.fromJson(map['status'] as String),
      acceptanceCriteria: List<String>.from(jsonDecode(map['acceptance_criteria'] as String)),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  // ─── Meetings ──────────────────────────────────────────────────────────────

  Future<void> saveMeeting(Meeting meeting) async {
    final db = await database;
    await db.insert(
      'meetings',
      {
        'id': meeting.id,
        'project_id': meeting.projectId,
        'sprint_id': meeting.sprintId,
        'type': meeting.type.name,
        'date': meeting.date.millisecondsSinceEpoch,
        'duration_minutes': meeting.durationMinutes,
        'participants': jsonEncode(meeting.participants),
        'summary': meeting.summary,
        'action_items': jsonEncode(meeting.actionItems),
        'sentiment_score': meeting.sentimentScore,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Meeting>> loadMeetingsByProject(String projectId) async {
    final db = await database;
    final rows = await db.query(
      'meetings',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => _meetingFromMap(r)).toList();
  }

  Future<Meeting?> loadMeeting(String id) async {
    final db = await database;
    final rows = await db.query('meetings', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _meetingFromMap(rows.first);
  }

  Meeting _meetingFromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      sprintId: map['sprint_id'] as String?,
      type: MeetingType.fromJson(map['type'] as String),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      durationMinutes: map['duration_minutes'] as int,
      participants: List<String>.from(jsonDecode(map['participants'] as String)),
      summary: map['summary'] as String,
      actionItems: List<String>.from(jsonDecode(map['action_items'] as String)),
      sentimentScore: map['sentiment_score'] as double?,
    );
  }

  // ─── Meeting Messages ──────────────────────────────────────────────────────

  Future<void> saveMeetingMessage(MeetingMessage message) async {
    final db = await database;
    await db.insert(
      'meeting_messages',
      {
        'id': message.id,
        'meeting_id': message.meetingId,
        'is_user': message.isUser ? 1 : 0,
        'content': message.content,
        'message_type': message.messageType.name,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'metadata': jsonEncode(message.metadata),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MeetingMessage>> loadMessagesByMeeting(String meetingId) async {
    final db = await database;
    final rows = await db.query(
      'meeting_messages',
      where: 'meeting_id = ?',
      whereArgs: [meetingId],
      orderBy: 'timestamp ASC',
    );
    return rows.map((r) => _meetingMessageFromMap(r)).toList();
  }

  MeetingMessage _meetingMessageFromMap(Map<String, dynamic> map) {
    return MeetingMessage(
      id: map['id'] as String,
      meetingId: map['meeting_id'] as String,
      isUser: (map['is_user'] as int) == 1,
      content: map['content'] as String,
      messageType: MessageType.fromJson(map['message_type'] as String),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      metadata: Map<String, dynamic>.from(jsonDecode(map['metadata'] as String)),
    );
  }

  // ─── Team Members ──────────────────────────────────────────────────────────

  Future<void> saveTeamMember(ProjectTeamMember member) async {
    final db = await database;
    await db.insert(
      'project_team_members',
      {
        'id': member.id,
        'project_id': member.projectId,
        'name': member.name,
        'role': member.role,
        'active': member.active ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProjectTeamMember>> loadTeamMembersByProject(String projectId) async {
    final db = await database;
    final rows = await db.query(
      'project_team_members',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    return rows.map((r) => _teamMemberFromMap(r)).toList();
  }

  Future<void> deleteTeamMember(String id) async {
    final db = await database;
    await db.delete('project_team_members', where: 'id = ?', whereArgs: [id]);
  }

  ProjectTeamMember _teamMemberFromMap(Map<String, dynamic> map) {
    return ProjectTeamMember(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      active: (map['active'] as int) == 1,
    );
  }

  // ─── Project Context ───────────────────────────────────────────────────────

  Future<void> saveProjectContext(ProjectContext context) async {
    final db = await database;
    await db.insert(
      'project_context',
      {
        'id': context.id,
        'project_id': context.projectId,
        'context_type': context.contextType.name,
        'key': context.key,
        'value': context.value,
        'created_at': context.createdAt.millisecondsSinceEpoch,
        'updated_at': context.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProjectContext>> loadContextByProject(String projectId) async {
    final db = await database;
    final rows = await db.query(
      'project_context',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    return rows.map((r) => _projectContextFromMap(r)).toList();
  }

  Future<void> deleteProjectContext(String id) async {
    final db = await database;
    await db.delete('project_context', where: 'id = ?', whereArgs: [id]);
  }

  ProjectContext _projectContextFromMap(Map<String, dynamic> map) {
    return ProjectContext(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      contextType: ContextType.fromJson(map['context_type'] as String),
      key: map['key'] as String,
      value: map['value'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  // ─── Utilities ─────────────────────────────────────────────────────────────

  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM projects');
    final count = result.first['count'] as int;
    return count == 0;
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
