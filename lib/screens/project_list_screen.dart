import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/project_provider.dart';
import 'package:agile_ai/models/project.dart';
import 'package:agile_ai/widgets/agile_ai_logo.dart';
import 'package:intl/intl.dart';

/// Main screen showing list of all projects
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CustomPaint(
              size: const Size(28, 28),
              painter: _AppBarLogoPainter(),
            ),
            const SizedBox(width: 10),
            const Text('Meine Projekte'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Globale Statistiken',
            onPressed: () => Navigator.pushNamed(context, '/global-stats'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Einstellungen',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: AgileAILoadingIndicator(size: 64, message: 'Projekte laden...'))
          : provider.projects.isEmpty
              ? _buildEmptyState()
              : _buildProjectGrid(provider.projects),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Neues Projekt'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Noch keine Projekte',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Erstelle dein erstes Projekt, um loszulegen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreateProjectDialog(),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Projekt erstellen'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid(List<Project> projects) {
    final activeProjects = projects.where((p) => p.status == ProjectStatus.active).toList();
    final archivedProjects = projects.where((p) => p.status == ProjectStatus.archived).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (activeProjects.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.play_circle_filled, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Aktive Projekte (${activeProjects.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: activeProjects.length,
            itemBuilder: (context, index) =>
                _buildProjectCard(activeProjects[index]),
          ),
        ],
        if (archivedProjects.isNotEmpty) ...[
          const SizedBox(height: 32),
          Row(
            children: [
              Icon(Icons.archive_outlined, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Archiviert (${archivedProjects.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...archivedProjects.map((p) => _buildArchivedProjectTile(p)),
        ],
      ],
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () => _openProject(project),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.folder_special,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) => _handleProjectAction(value, project),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Bearbeiten'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined),
                            SizedBox(width: 8),
                            Text('Archivieren'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Löschen', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const Divider(),
              Row(
                children: [
                  _buildStatChip(Icons.people_outline, '${project.teamSize}'),
                  const SizedBox(width: 8),
                  _buildStatChip(Icons.speed, '${project.averageVelocity.toStringAsFixed(0)} SP'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.loop,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sprint ${project.currentSprintNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildArchivedProjectTile(Project project) {
    return Card(
      color: Colors.grey[100],
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.archive, color: Colors.grey[600]),
        ),
        title: Text(project.name),
        subtitle: Row(
          children: [
            const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              'Archiviert am ${DateFormat('dd.MM.yyyy').format(project.updatedAt)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleProjectAction(value, project),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.unarchive_outlined, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Wiederherstellen'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Löschen', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _openProject(project),
      ),
    );
  }

  void _openProject(Project project) {
    context.read<ProjectProvider>().selectProject(project.id);
    Navigator.pushNamed(context, '/project/${project.id}');
  }

  void _handleProjectAction(String action, Project project) {
    switch (action) {
      case 'edit':
        _showEditProjectDialog(project);
        break;
      case 'archive':
        context.read<ProjectProvider>().archiveProject(project.id);
        break;
      case 'delete':
        _confirmDelete(project);
        break;
      case 'restore':
        context.read<ProjectProvider>().updateProject(
              project.copyWith(status: ProjectStatus.active),
            );
        break;
    }
  }

  void _confirmDelete(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber, color: Colors.red, size: 48),
        title: const Text('Projekt löschen?'),
        content: Text(
          'Möchtest du "${project.name}" wirklich löschen?\n\nDiese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton.icon(
            onPressed: () {
              context.read<ProjectProvider>().deleteProject(project.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.delete),
            label: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    int teamSize = 5;
    int sprintLength = 2;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          icon: const Icon(Icons.create_new_folder, size: 48),
          title: const Text('Neues Projekt'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Projektname',
                    prefixIcon: Icon(Icons.drive_file_rename_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Teamgröße: $teamSize'),
                          Slider(
                            value: teamSize.toDouble(),
                            min: 1,
                            max: 15,
                            divisions: 14,
                            label: '$teamSize',
                            onChanged: (value) => setState(() => teamSize = value.toInt()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sprint-Länge: $sprintLength Wochen'),
                          Slider(
                            value: sprintLength.toDouble(),
                            min: 1,
                            max: 4,
                            divisions: 3,
                            label: '$sprintLength Wochen',
                            onChanged: (value) => setState(() => sprintLength = value.toInt()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final project = Project(
                    name: nameController.text,
                    description: descController.text,
                    teamSize: teamSize,
                    sprintLengthWeeks: sprintLength,
                  );
                  context.read<ProjectProvider>().createProject(project);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Erstellen'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProjectDialog(Project project) {
    final nameController = TextEditingController(text: project.name);
    final descController = TextEditingController(text: project.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.edit, size: 48),
        title: const Text('Projekt bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Projektname',
                prefixIcon: Icon(Icons.drive_file_rename_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<ProjectProvider>().updateProject(
                      project.copyWith(
                        name: nameController.text,
                        description: descController.text,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter für das AgileAI Logo in der AppBar
class _AppBarLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF009688)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Sprint Circle
    final circlePath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        -0.8,
        4.5,
      );
    canvas.drawPath(circlePath, paint);

    // Stylized "A"
    final aPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.25, size.height * 0.78)
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.75, size.height * 0.78)
      ..moveTo(size.width * 0.33, size.height * 0.55)
      ..lineTo(size.width * 0.67, size.height * 0.55);

    canvas.drawPath(aPath, paint);

    // AI Dot
    final dotPaint = Paint()
      ..color = const Color(0xFF00BCD4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.08,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
