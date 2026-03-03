import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:agile_ai/models/backlog_item.dart';
import 'package:agile_ai/models/sprint_data.dart';
import 'package:agile_ai/models/team_member.dart';

/// SQLite database for structured, queryable data.
/// Replaces SharedPreferences for BacklogItems, SprintData, and TeamMembers.
class DatabaseService {
  static Database? _db;
  static const int _version = 1;
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
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE backlog_items (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sprint_data (
        sprint_number INTEGER PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE team_members (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');
  }

  // ─── Backlog items ─────────────────────────────────────────────────────────

  Future<void> saveBacklogItem(BacklogItem item) async {
    final db = await database;
    await db.insert(
      'backlog_items',
      {'id': item.id, 'data': jsonEncode(item.toJson())},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BacklogItem>> loadBacklogItems() async {
    final db = await database;
    final rows = await db.query('backlog_items', orderBy: 'rowid ASC');
    return rows
        .map((r) => BacklogItem.fromJson(jsonDecode(r['data'] as String)))
        .toList();
  }

  Future<void> deleteBacklogItem(String id) async {
    final db = await database;
    await db.delete('backlog_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveAllBacklogItems(List<BacklogItem> items) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('backlog_items');
    for (final item in items) {
      batch.insert('backlog_items', {
        'id': item.id,
        'data': jsonEncode(item.toJson()),
      });
    }
    await batch.commit(noResult: true);
  }

  // ─── Sprint data ───────────────────────────────────────────────────────────

  Future<void> saveSprintData(SprintData sprint) async {
    final db = await database;
    await db.insert(
      'sprint_data',
      {'sprint_number': sprint.sprintNumber, 'data': jsonEncode(sprint.toJson())},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SprintData>> loadAllSprints() async {
    final db = await database;
    final rows = await db.query('sprint_data', orderBy: 'sprint_number ASC');
    return rows
        .map((r) => SprintData.fromJson(jsonDecode(r['data'] as String)))
        .toList();
  }

  Future<void> deleteSprintData(int sprintNumber) async {
    final db = await database;
    await db.delete('sprint_data',
        where: 'sprint_number = ?', whereArgs: [sprintNumber]);
  }

  // ─── Team members ──────────────────────────────────────────────────────────

  Future<void> saveTeamMember(TeamMember member) async {
    final db = await database;
    await db.insert(
      'team_members',
      {'id': member.id, 'data': jsonEncode(member.toJson())},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TeamMember>> loadTeamMembers() async {
    final db = await database;
    final rows = await db.query('team_members', orderBy: 'rowid ASC');
    return rows
        .map((r) => TeamMember.fromJson(jsonDecode(r['data'] as String)))
        .toList();
  }

  Future<void> deleteTeamMember(String id) async {
    final db = await database;
    await db.delete('team_members', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
