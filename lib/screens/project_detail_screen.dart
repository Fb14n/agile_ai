import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/project_provider.dart';
import 'package:agile_ai/models/meeting.dart';
import 'package:agile_ai/models/user_story.dart';
import 'package:agile_ai/models/sprint.dart';
import 'package:agile_ai/screens/project_ai_chat_screen.dart';
import 'package:agile_ai/widgets/agile_ai_logo.dart';
import 'package:intl/intl.dart';

/// Project detail screen with tabs for overview, meetings, backlog, and AI chat
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final project = provider.currentProject;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Projekt')),
        body: const Center(child: AgileAILoadingIndicator(size: 64, message: 'Projekt laden...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder_special,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                project.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Projekteinstellungen',
            onPressed: () => _showProjectSettings(context, provider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Übersicht'),
            Tab(icon: Icon(Icons.event), text: 'Meetings'),
            Tab(icon: Icon(Icons.list_alt), text: 'Backlog'),
            Tab(icon: Icon(Icons.smart_toy), text: 'AI-Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, provider),
          _buildMeetingsTab(context, provider),
          _buildBacklogTab(context, provider),
          _buildAIChatTab(context),
        ],
      ),
    );
  }

  // ─── Project Settings Dialog ────────────────────────────────────────────────

  void _showProjectSettings(BuildContext context, ProjectProvider provider) {
    final project = provider.currentProject!;
    final nameController = TextEditingController(text: project.name);
    final descController = TextEditingController(text: project.description);
    int sprintLength = project.sprintLengthWeeks;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.settings),
                    const SizedBox(width: 8),
                    Text(
                      'Projekteinstellungen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Projektname',
                    prefixIcon: Icon(Icons.label_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Sprint Length
                Row(
                  children: [
                    const Icon(Icons.date_range, color: Colors.grey),
                    const SizedBox(width: 12),
                    const Text('Sprint-Länge:'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: sprintLength > 1
                          ? () => setModalState(() => sprintLength--)
                          : null,
                    ),
                    Text(
                      '$sprintLength Wochen',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: sprintLength < 8
                          ? () => setModalState(() => sprintLength++)
                          : null,
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Team Members
                Row(
                  children: [
                    const Icon(Icons.people_outline),
                    const SizedBox(width: 8),
                    Text(
                      'Team (${provider.teamMembers.length} Mitglieder)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (provider.teamMembers.isEmpty)
                  const Text('Keine Teammitglieder'),
                ...provider.teamMembers.map((member) => ListTile(
                      leading: CircleAvatar(
                        child: Text(member.name[0].toUpperCase()),
                      ),
                      title: Text(member.name),
                      subtitle: Text(member.role),
                      dense: true,
                    )),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await provider.updateProject(
                        project.copyWith(
                          name: nameController.text,
                          description: descController.text,
                          sprintLengthWeeks: sprintLength,
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Speichern'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Overview Tab ───────────────────────────────────────────────────────────

  Widget _buildOverviewTab(BuildContext context, ProjectProvider provider) {
    final project = provider.currentProject!;
    final sprints = provider.sprints;
    final currentSprint = sprints.where((s) => s.status == SprintStatus.active).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        'Projektübersicht',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(project.description),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.people_outline, '${project.teamSize}', 'Team'),
                      _buildStatItem(Icons.loop, 'Sprint ${project.currentSprintNumber}', 'Aktuell'),
                      _buildStatItem(Icons.speed, '${project.averageVelocity.toStringAsFixed(0)} SP', 'Velocity'),
                      _buildStatItem(Icons.calendar_month, '${project.sprintLengthWeeks}W', 'Sprint-Länge'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Current Sprint Card with action button
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        currentSprint != null ? Icons.flag : Icons.flag_outlined,
                        color: currentSprint != null ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentSprint != null
                              ? 'Aktueller Sprint: Sprint ${currentSprint.sprintNumber}'
                              : 'Kein aktiver Sprint',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (currentSprint == null)
                        FilledButton.tonalIcon(
                          onPressed: () => _showStartSprintDialog(context, provider),
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Starten'),
                        ),
                    ],
                  ),
                  if (currentSprint != null) ...[
                    const SizedBox(height: 8),
                    if (currentSprint.goal.isNotEmpty) ...[
                      Text(
                        currentSprint.goal,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    LinearProgressIndicator(
                      value: currentSprint.plannedStoryPoints > 0
                          ? currentSprint.completedStoryPoints / currentSprint.plannedStoryPoints
                          : 0,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${currentSprint.completedStoryPoints} / ${currentSprint.plannedStoryPoints} Story Points',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton.icon(
                          onPressed: () => _showCompleteSprintDialog(context, provider, currentSprint),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Sprint abschließen'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions - Meeting List
          Row(
            children: [
              const Icon(Icons.flash_on),
              const SizedBox(width: 8),
              Text(
                'Meeting starten',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMeetingList(context),
        ],
      ),
    );
  }

  // ─── Start Sprint Dialog ────────────────────────────────────────────────────

  void _showStartSprintDialog(BuildContext context, ProjectProvider provider) {
    final goalController = TextEditingController();
    final project = provider.currentProject!;
    final nextSprintNumber = project.currentSprintNumber + 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.rocket_launch, size: 48, color: Colors.blue),
        title: Text('Sprint $nextSprintNumber starten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Definiere ein Sprint-Ziel für das Team:'),
            const SizedBox(height: 16),
            TextField(
              controller: goalController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Sprint-Ziel',
                hintText: 'Was soll in diesem Sprint erreicht werden?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await provider.startNewSprint(goalController.text);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Sprint starten'),
          ),
        ],
      ),
    );
  }

  void _showCompleteSprintDialog(BuildContext context, ProjectProvider provider, Sprint sprint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.celebration, size: 48, color: Colors.green),
        title: const Text('Sprint abschließen?'),
        content: Text(
          'Sprint ${sprint.sprintNumber} wird abgeschlossen.\n\n'
          '${sprint.completedStoryPoints} von ${sprint.plannedStoryPoints} Story Points wurden erledigt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await provider.completeSprint(sprint.id);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text('Abschließen'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  // ─── Meeting List (instead of Grid) ─────────────────────────────────────────

  Widget _buildMeetingList(BuildContext context) {
    final meetingTypes = [
      ('daily', Icons.wb_sunny, 'Daily Standup', 'Tägliches Team-Sync', Colors.orange),
      ('planning', Icons.event_note, 'Sprint Planning', 'Sprint planen & Stories auswählen', Colors.blue),
      ('review', Icons.visibility, 'Sprint Review', 'Increment präsentieren', Colors.green),
      ('retrospective', Icons.refresh, 'Retrospektive', 'Was lief gut? Was verbessern?', Colors.purple),
      ('refinement', Icons.tune, 'Backlog Refinement', 'Stories schätzen & klären', Colors.teal),
    ];

    return Card(
      child: Column(
        children: meetingTypes.map((meeting) {
          final (type, icon, title, subtitle, color) = meeting;
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(title),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(
              context,
              '/project/${widget.projectId}/meeting/$type',
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Meetings Tab ───────────────────────────────────────────────────────────

  Widget _buildMeetingsTab(BuildContext context, ProjectProvider provider) {
    final meetings = provider.meetings;

    if (meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Noch keine Meetings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Starte dein erstes Meeting über die Übersicht',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Group meetings by type
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getMeetingTypeColor(meeting.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getMeetingTypeIcon(meeting.type),
                color: _getMeetingTypeColor(meeting.type),
              ),
            ),
            title: Text(_getMeetingTypeName(meeting.type)),
            subtitle: Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(DateFormat('dd.MM.yyyy HH:mm').format(meeting.date)),
                if (meeting.durationMinutes > 0) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.timer_outlined, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${meeting.durationMinutes} Min'),
                ],
              ],
            ),
            trailing: meeting.sentimentScore != null
                ? _buildSentimentChip(meeting.sentimentScore!)
                : const Icon(Icons.chevron_right),
            onTap: () {
              // Open meeting detail screen
              _showMeetingDetail(context, meeting);
            },
          ),
        );
      },
    );
  }

  Widget _buildSentimentChip(double score) {
    Color color;
    IconData icon;
    if (score >= 7) {
      color = Colors.green;
      icon = Icons.sentiment_very_satisfied;
    } else if (score >= 4) {
      color = Colors.orange;
      icon = Icons.sentiment_neutral;
    } else {
      color = Colors.red;
      icon = Icons.sentiment_very_dissatisfied;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showMeetingDetail(BuildContext context, Meeting meeting) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getMeetingTypeColor(meeting.type),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getMeetingTypeIcon(meeting.type),
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMeetingTypeName(meeting.type),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(meeting.date),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  if (meeting.summary.isNotEmpty) ...[
                    _buildDetailSection(
                      icon: Icons.summarize,
                      title: 'Zusammenfassung',
                      content: meeting.summary,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (meeting.actionItems.isNotEmpty) ...[
                    _buildDetailSection(
                      icon: Icons.checklist,
                      title: 'Action Items',
                      content: meeting.actionItems.map((e) => '• $e').join('\n'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildDetailSection(
                    icon: Icons.people,
                    title: 'Teilnehmer',
                    content: meeting.participants.join(', '),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  // ─── Backlog Tab ────────────────────────────────────────────────────────────

  Widget _buildBacklogTab(BuildContext context, ProjectProvider provider) {
    final stories = provider.userStories;

    if (stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Backlog ist leer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Füge User Stories über das Planning hinzu',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Group by status
    final todoStories = stories.where((s) => s.status == StoryStatus.todo).toList();
    final inProgressStories = stories.where((s) => s.status == StoryStatus.inProgress).toList();
    final doneStories = stories.where((s) => s.status == StoryStatus.done).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (inProgressStories.isNotEmpty) ...[
          _buildStorySection(context, 'In Arbeit', inProgressStories, Colors.blue),
          const SizedBox(height: 16),
        ],
        if (todoStories.isNotEmpty) ...[
          _buildStorySection(context, 'Zu erledigen', todoStories, Colors.orange),
          const SizedBox(height: 16),
        ],
        if (doneStories.isNotEmpty)
          _buildStorySection(context, 'Erledigt', doneStories, Colors.green),
      ],
    );
  }

  Widget _buildStorySection(
    BuildContext context,
    String title,
    List<UserStory> stories,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$title (${stories.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...stories.map((story) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Text(
                    '${story.storyPoints}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(story.title),
                subtitle: story.description.isNotEmpty
                    ? Text(
                        story.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: _buildPriorityChip(story.priority),
              ),
            )),
      ],
    );
  }

  Widget _buildPriorityChip(StoryPriority priority) {
    Color color;
    String label;
    switch (priority) {
      case StoryPriority.critical:
        color = Colors.red;
        label = 'Kritisch';
        break;
      case StoryPriority.high:
        color = Colors.orange;
        label = 'Hoch';
        break;
      case StoryPriority.medium:
        color = Colors.blue;
        label = 'Mittel';
        break;
      case StoryPriority.low:
        color = Colors.grey;
        label = 'Niedrig';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ─── AI Chat Tab ────────────────────────────────────────────────────────────

  Widget _buildAIChatTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI-Assistent',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Stelle Fragen zu deinem Projekt',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Der AI-Assistent kennt deinen Projektkontext und kann dir bei Scrum-Themen helfen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectAIChatScreen(projectId: widget.projectId),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat starten'),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  IconData _getMeetingTypeIcon(MeetingType type) {
    switch (type) {
      case MeetingType.daily:
        return Icons.wb_sunny;
      case MeetingType.planning:
        return Icons.event_note;
      case MeetingType.review:
        return Icons.visibility;
      case MeetingType.retrospective:
        return Icons.refresh;
      case MeetingType.refinement:
        return Icons.tune;
    }
  }

  Color _getMeetingTypeColor(MeetingType type) {
    switch (type) {
      case MeetingType.daily:
        return Colors.orange;
      case MeetingType.planning:
        return Colors.blue;
      case MeetingType.review:
        return Colors.green;
      case MeetingType.retrospective:
        return Colors.purple;
      case MeetingType.refinement:
        return Colors.teal;
    }
  }

  String _getMeetingTypeName(MeetingType type) {
    switch (type) {
      case MeetingType.daily:
        return 'Daily Standup';
      case MeetingType.planning:
        return 'Sprint Planning';
      case MeetingType.review:
        return 'Sprint Review';
      case MeetingType.retrospective:
        return 'Retrospektive';
      case MeetingType.refinement:
        return 'Refinement';
    }
  }
}
