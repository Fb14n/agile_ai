import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/project_provider.dart';

/// Placeholder for project detail screen - to be fully implemented
class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final project = provider.currentProject;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Projekt')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sprint ${project.currentSprintNumber}',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(project.description),
                  const SizedBox(height: 16),
                  Text('Team: ${project.teamSize} Mitglieder'),
                  Text('Velocity: ${project.averageVelocity.toStringAsFixed(0)} SP'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMeetingButtons(context),
        ],
      ),
    );
  }

  Widget _buildMeetingButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meetings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/project/$projectId/meeting/daily'),
                  icon: const Icon(Icons.groups),
                  label: const Text('Daily Standup'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/project/$projectId/meeting/planning'),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Planning'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/project/$projectId/meeting/review'),
                  icon: const Icon(Icons.preview),
                  label: const Text('Review'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/project/$projectId/meeting/retrospective'),
                  icon: const Icon(Icons.insights),
                  label: const Text('Retrospective'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
