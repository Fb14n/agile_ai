# Database Schema Documentation

AgileAI uses SQLite for persistent storage with an automatically initialized schema and migrations.

## Overview

- **Database Type**: SQLite
- **Location**: `<app_data_directory>/agile_ai.db`
- **Current Version**: 2
- **Auto-initialization**: Yes
- **Seed Data**: Fantasy project "QuantumHealth"

## Schema Version History

### V1 - Initial Schema
Created 7 core tables for project-centric Scrum management.

### V2 - Seed Data
Automatically seeds the database with the "QuantumHealth" fantasy project if the database is empty on first launch.

## Tables

### `projects`

Project metadata and settings.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Primary key (UUID) |
| `name` | TEXT | Project name |
| `description` | TEXT | Project description |
| `created_at` | INTEGER | Creation timestamp (milliseconds) |
| `updated_at` | INTEGER | Last update timestamp |
| `team_size` | INTEGER | Number of team members |
| `sprint_length_weeks` | INTEGER | Sprint duration in weeks (1-4) |
| `current_sprint_number` | INTEGER | Current sprint number |
| `average_velocity` | REAL | Average story points per sprint |
| `status` | TEXT | 'active' or 'archived' |

**Indexes**: None (typically few projects)

**Example**:
```sql
SELECT * FROM projects WHERE status = 'active';
```

### `sprints`

Sprint information per project.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Primary key (UUID) |
| `project_id` | TEXT | Foreign key to projects |
| `sprint_number` | INTEGER | Sprint number within project |
| `start_date` | INTEGER | Sprint start timestamp |
| `end_date` | INTEGER | Sprint end timestamp |
| `goal` | TEXT | Sprint goal |
| `planned_story_points` | INTEGER | Planned SP for sprint |
| `completed_story_points` | INTEGER | Actual completed SP |
| `status` | TEXT | 'planning', 'active', or 'completed' |

**Indexes**: `idx_sprints_project` on `project_id`

**Example**:
```sql
SELECT * FROM sprints 
WHERE project_id = ? AND status = 'active';
```

### `user_stories`

User stories / backlog items.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Primary key (UUID) |
| `project_id` | TEXT | Foreign key to projects |
| `sprint_id` | TEXT | Foreign key to sprints (nullable) |
| `title` | TEXT | Story title |
| `description` | TEXT | Detailed description |
| `story_points` | INTEGER | Estimated story points |
| `priority` | TEXT | 'low', 'medium', 'high', 'critical' |
| `status` | TEXT | 'todo', 'inProgress', 'done' |
| `acceptance_criteria` | TEXT | JSON array of strings |
| `created_at` | INTEGER | Creation timestamp |
| `updated_at` | INTEGER | Last update timestamp |

**Indexes**:
- `idx_user_stories_project` on `project_id`
- `idx_user_stories_sprint` on `sprint_id`

**Example**:
```sql
SELECT * FROM user_stories 
WHERE project_id = ? AND sprint_id IS NULL  -- Backlog stories
ORDER BY priority DESC, created_at DESC;
```

### `meetings`

Meeting metadata and summaries.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Primary key (UUID) |
| `project_id` | TEXT | Foreign key to projects |
| `sprint_id` | TEXT | Foreign key to sprints (nullable) |
| `type` | TEXT | 'daily', 'planning', 'review', 'retrospective', 'refinement' |
| `date` | INTEGER | Meeting timestamp |
| `duration_minutes` | INTEGER | Meeting duration |
| `participants` | TEXT | JSON array of participant names |
| `summary` | TEXT | AI-generated meeting summary |
| `action_items` | TEXT | JSON array of action items |
| `sentiment_score` | REAL | Team sentiment (0-10, nullable) |

**Indexes**: `idx_meetings_project` on `project_id`

**Example**:
```sql
SELECT * FROM meetings 
WHERE project_id = ? AND type = 'retrospective'
ORDER BY date DESC 
LIMIT 5;
```

### `meeting_messages`

Chat messages within meetings.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Primary key (UUID) |
| `meeting_id` | TEXT | Foreign key to meetings |
| `is_user` | INTEGER | 1 if user message, 0 if AI |
| `content` | TEXT | Message text content |
| `message_type` | TEXT | 'user', 'assistant', 'system', 'analysis', 'suggestion', 'warning' |
| `timestamp` | INTEGER | Message timestamp |
| `metadata` | TEXT | JSON object for extra data |

**Indexes**: `idx_meeting_messages_meeting` on `meeting_id`

**Example**:
```sql
SELECT * FROM meeting_messages 
WHERE meeting_id = ?
ORDER BY timestamp ASC;
```

### `project_team_members`

Team members associated with projects.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Primary key (UUID) |
| `project_id` | TEXT | Foreign key to projects |
| `name` | TEXT | Member name |
| `role` | TEXT | Role (e.g., 'Developer', 'Product Owner') |
| `active` | INTEGER | 1 if active, 0 if inactive |

**Indexes**: `idx_team_members_project` on `project_id`

**Example**:
```sql
SELECT * FROM project_team_members 
WHERE project_id = ? AND active = 1;
```

### `project_context`

Editable project-specific context for AI.

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Primary key (UUID) |
| `project_id` | TEXT | Foreign key to projects |
| `context_type` | TEXT | 'teamInfo', 'techStack', 'definitionOfDone', 'sprintGoal', 'customNote' |
| `key` | TEXT | Context key/name |
| `value` | TEXT | Context value |
| `created_at` | INTEGER | Creation timestamp |
| `updated_at` | INTEGER | Last update timestamp |

**Indexes**: `idx_context_project` on `project_id`

**Example**:
```sql
SELECT * FROM project_context 
WHERE project_id = ? AND context_type = 'techStack';
```

## Relationships

```
projects (1) ──┬──> (N) sprints
               ├──> (N) user_stories
               ├──> (N) meetings
               ├──> (N) project_team_members
               └──> (N) project_context

sprints (1) ──┬──> (N) user_stories
              └──> (N) meetings

meetings (1) ──> (N) meeting_messages
```

## Foreign Key Constraints

All foreign keys use `ON DELETE CASCADE` except:
- `user_stories.sprint_id` uses `ON DELETE SET NULL` (story stays in backlog if sprint deleted)
- `meetings.sprint_id` uses `ON DELETE SET NULL` (meeting stays associated with project)

## Migration Strategy

Migrations are handled automatically in `DatabaseService`:

1. **onCreate**: Runs `_createSchemaV1()` when database is created
2. **onUpgrade**: Runs migrations sequentially (v1→v2, v2→v3, etc.)

To add a new migration:

```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // v1 → v2 migration
  }
  if (oldVersion < 3) {
    // v2 → v3 migration
    await db.execute('ALTER TABLE projects ADD COLUMN new_field TEXT');
  }
}
```

## Querying the Database

### Get current sprint with statistics

```sql
SELECT s.*, 
       COUNT(us.id) as total_stories,
       SUM(CASE WHEN us.status = 'done' THEN 1 ELSE 0 END) as done_stories
FROM sprints s
LEFT JOIN user_stories us ON us.sprint_id = s.id
WHERE s.project_id = ? AND s.status = 'active'
GROUP BY s.id;
```

### Get project with team and context

```sql
SELECT 
  p.*,
  COUNT(DISTINCT tm.id) as team_count,
  COUNT(DISTINCT pc.id) as context_count
FROM projects p
LEFT JOIN project_team_members tm ON tm.project_id = p.id AND tm.active = 1
LEFT JOIN project_context pc ON pc.project_id = p.id
WHERE p.id = ?
GROUP BY p.id;
```

### Get meeting history for AI context

```sql
SELECT 
  m.type,
  m.date,
  m.summary,
  GROUP_CONCAT(mm.content, '\n') as conversation
FROM meetings m
LEFT JOIN meeting_messages mm ON mm.meeting_id = m.id
WHERE m.project_id = ?
GROUP BY m.id
ORDER BY m.date DESC
LIMIT 10;
```

## Backup & Export

To backup the database:

```dart
final dbPath = await getDatabasesPath();
final dbFile = File(join(dbPath, 'agile_ai.db'));
final backupFile = File('/path/to/backup/agile_ai_backup_${DateTime.now().millisecondsSinceEpoch}.db');
await dbFile.copy(backupFile.path);
```

## Performance Considerations

- All tables use UUID primary keys for global uniqueness
- Indexes are created on frequently queried foreign keys
- JSON fields (`acceptance_criteria`, `participants`, `action_items`, `metadata`) are stored as TEXT
- Timestamps are stored as INTEGER (milliseconds since epoch) for efficient comparison
- Consider VACUUM after bulk deletions

## Schema Visualization

```
┌─────────────────────┐
│     projects        │
│ ─────────────────── │
│ id (PK)             │
│ name                │
│ description         │
│ status              │
└──┬──────────────────┘
   │
   ├──> ┌────────────────────┐
   │    │      sprints       │
   │    │ ────────────────── │
   │    │ id (PK)            │
   │    │ project_id (FK)    │
   │    │ sprint_number      │
   │    │ status             │
   │    └──┬─────────────────┘
   │       │
   ├──────┼──> ┌──────────────────────┐
   │      │    │    user_stories      │
   │      │    │ ──────────────────── │
   │      │    │ id (PK)              │
   │      │    │ project_id (FK)      │
   │      │    │ sprint_id (FK, null) │
   │      │    │ title                │
   │      │    │ status               │
   │      │    └──────────────────────┘
   │      │
   ├──────┴──> ┌──────────────────────┐
   │           │      meetings        │
   │           │ ──────────────────── │
   │           │ id (PK)              │
   │           │ project_id (FK)      │
   │           │ sprint_id (FK, null) │
   │           │ type                 │
   │           └──┬───────────────────┘
   │              │
   │              └──> ┌──────────────────────────┐
   │                   │   meeting_messages       │
   │                   │ ──────────────────────── │
   │                   │ id (PK)                  │
   │                   │ meeting_id (FK)          │
   │                   │ content                  │
   │                   └──────────────────────────┘
   │
   ├──> ┌─────────────────────────────┐
   │    │  project_team_members       │
   │    │ ─────────────────────────── │
   │    │ id (PK)                     │
   │    │ project_id (FK)             │
   │    │ name                        │
   │    │ role                        │
   │    └─────────────────────────────┘
   │
   └──> ┌──────────────────────────┐
        │   project_context        │
        │ ──────────────────────── │
        │ id (PK)                  │
        │ project_id (FK)          │
        │ context_type             │
        │ key                      │
        │ value                    │
        └──────────────────────────┘
```

## Resetting the Database

To completely reset:

1. Close the app
2. Delete `agile_ai.db` in the app data directory
3. Restart the app → Database will be recreated with seed data

---

**Last Updated**: 2026-03-26
**Schema Version**: 2
