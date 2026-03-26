import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/project_provider.dart';
import 'package:agile_ai/models/project.dart';
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
        title: const Text('AgileAI - Projekte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Globale Statistiken',
            onPressed: () => Navigator.pushNamed(context, '/global-stats'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Einstellungen',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.projects.isEmpty
              ? _buildEmptyState()
              : _buildProjectGrid(provider.projects),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Neues Projekt'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 100, color: Colors.grey[400]),
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
          ElevatedButton.icon(
            onPressed: () => _showCreateProjectDialog(),
            icon: const Icon(Icons.add),
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
          Text(
            'Aktive Projekte (${activeProjects.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: activeProjects.length,
            itemBuilder: (context, index) =>
                _buildProjectCard(activeProjects[index]),
          ),
        ],
        if (archivedProjects.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text(
            'Archiviert (${archivedProjects.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
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
      child: InkWell(
        onTap: () => _openProject(project),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleProjectAction(value, project),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                      const PopupMenuItem(value: 'archive', child: Text('Archivieren')),
                      const PopupMenuItem(value: 'delete', child: Text('Löschen')),
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
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${project.teamSize}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${project.averageVelocity.toStringAsFixed(0)} SP',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Sprint ${project.currentSprintNumber}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF009688), // Teal primary color
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchivedProjectTile(Project project) {
    return ListTile(
      leading: Icon(Icons.archive, color: Colors.grey[400]),
      title: Text(project.name),
      subtitle: Text(
        'Archiviert am ${DateFormat('dd.MM.yyyy').format(project.updatedAt)}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleProjectAction(value, project),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'restore', child: Text('Wiederherstellen')),
          const PopupMenuItem(value: 'delete', child: Text('Löschen')),
        ],
      ),
      onTap: () => _openProject(project),
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
        title: const Text('Projekt löschen?'),
        content: Text(
          'Möchtest du "${project.name}" wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProjectProvider>().deleteProject(project.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
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
          title: const Text('Neues Projekt'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Projektname',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Teamgröße'),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sprint-Länge'),
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
            ElevatedButton(
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
              child: const Text('Erstellen'),
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
        title: const Text('Projekt bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Projektname',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
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
          ElevatedButton(
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
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
