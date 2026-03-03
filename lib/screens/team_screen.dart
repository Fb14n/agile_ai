import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/team_provider.dart';
import 'package:agile_ai/models/team_member.dart';

/// Team management screen: add, edit, and delete members.
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, team, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Team'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_outlined),
                tooltip: 'Mitglied hinzufügen',
                onPressed: () => _showMemberDialog(context, team, null),
              ),
            ],
          ),
          body: team.members.isEmpty
              ? _buildEmptyState(context, team)
              : Column(
                  children: [
                    // Team summary
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.groups,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${team.members.length} Mitglieder',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Member list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: team.members.length,
                        itemBuilder: (_, i) => _MemberCard(
                          member: team.members[i],
                          onEdit: () => _showMemberDialog(
                              context, team, team.members[i]),
                          onDelete: () =>
                              _confirmDelete(context, team, team.members[i]),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, TeamProvider team) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Kein Team konfiguriert',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Füge Teammitglieder hinzu, um die KI\nbei Zeremonien besser zu kontextualisieren.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showMemberDialog(context, team, null),
            icon: const Icon(Icons.person_add),
            label: const Text('Mitglied hinzufügen'),
          ),
        ],
      ),
    );
  }

  void _showMemberDialog(
      BuildContext context, TeamProvider team, TeamMember? existing) {
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    String selectedRole = existing?.role ?? 'Developer';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(existing == null
              ? 'Mitglied hinzufügen'
              : 'Mitglied bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rolle',
                  border: OutlineInputBorder(),
                ),
                items: TeamMember.availableRoles
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  if (val != null)
                    setStateDialog(() => selectedRole = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                if (existing == null) {
                  team.addMember(TeamMember(
                      name: name, role: selectedRole));
                } else {
                  team.updateMember(
                      existing.copyWith(name: name, role: selectedRole));
                }
                Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Hinzufügen' : 'Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, TeamProvider team, TeamMember member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mitglied entfernen?'),
        content: Text('${member.name} wirklich aus dem Team entfernen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              team.removeMember(member.id);
              Navigator.pop(context);
            },
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Parse color from hex string
    Color avatarColor;
    try {
      avatarColor =
          Color(int.parse(member.colorHex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      avatarColor = Colors.deepPurple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor.withValues(alpha: 0.25),
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: TextStyle(
                color: avatarColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(member.name),
        subtitle: Text(member.role),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.red),
                onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
