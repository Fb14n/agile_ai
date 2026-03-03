import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/models/backlog_item.dart';
import 'package:agile_ai/providers/backlog_provider.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/widgets/backlog_item_card.dart';

class BacklogScreen extends StatefulWidget {
  const BacklogScreen({super.key});

  @override
  State<BacklogScreen> createState() => _BacklogScreenState();
}

class _BacklogScreenState extends State<BacklogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddItemDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Backlog Item hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Titel / User Story', border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Beschreibung (optional)',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                Navigator.pop(context);
                context.read<BacklogProvider>().addItem(
                      BacklogItem(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                      ),
                    );
              }
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  void _showKiResultDialog(BuildContext context, String title, String result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(result)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen')),
        ],
      ),
    );
  }

  void _showAssignSprintDialog(
      BuildContext context, BacklogProvider backlog, BacklogItem item) {
    final currentSprint =
        context.read<SettingsProvider>().currentSprintNumber;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Sprint zuweisen: ${item.title}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              backlog.assignToSprint(item.id, currentSprint);
            },
            child: Text('Sprint $currentSprint (aktuell)'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              backlog.assignToSprint(item.id, currentSprint + 1);
            },
            child: Text('Sprint ${currentSprint + 1} (nächster)'),
          ),
          if (item.sprintNumber != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                backlog.assignToSprint(item.id, 0);
              },
              child: const Text('Aus Sprint entfernen (→ Backlog)'),
            ),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context, BacklogItem item) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Status ändern'),
        children: BacklogStatus.values
            .where((s) => s != BacklogStatus.removed)
            .map((s) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<BacklogProvider>().updateStatus(item.id, s);
                  },
                  child: Text(_statusLabel(s)),
                ))
            .toList(),
      ),
    );
  }

  String _statusLabel(BacklogStatus s) {
    switch (s) {
      case BacklogStatus.todo:
        return 'To Do';
      case BacklogStatus.inProgress:
        return 'In Progress';
      case BacklogStatus.done:
        return 'Done';
      case BacklogStatus.removed:
        return 'Entfernt';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backlog'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Backlog', icon: Icon(Icons.list_alt, size: 16)),
            Tab(text: 'Aktueller Sprint', icon: Icon(Icons.directions_run, size: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(context),
          ),
        ],
      ),
      body: Consumer<BacklogProvider>(
        builder: (context, backlog, _) {
          if (backlog.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildItemList(context, backlog.backlogItems, backlog),
              _buildSprintView(context, backlog),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemList(
      BuildContext context, List<BacklogItem> items, BacklogProvider backlog) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Noch keine Backlog Items'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _showAddItemDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Item hinzufügen'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => backlog.removeItem(item.id),
          child: BacklogItemCard(
            item: item,
            onTap: () => _showStatusDialog(context, item),
            onEstimate: () async {
              final result = await backlog.estimateItem(item.id);
              if (context.mounted) {
                _showKiResultDialog(context, 'Story Point Schätzung', result);
              }
            },
            onAcceptanceCriteria: () async {
              final result = await backlog.generateAcceptanceCriteria(item.id);
              if (context.mounted) {
                _showKiResultDialog(context, 'Akzeptanzkriterien', result);
              }
            },
            onInvest: () async {
              final result = await backlog.validateInvest(item.id);
              if (context.mounted) {
                _showKiResultDialog(context, 'INVEST-Validierung', result);
              }
            },
            onDelete: () => backlog.removeItem(item.id),
            onAssignSprint: () => _showAssignSprintDialog(context, backlog, item),
          ),
        );
      },
    );
  }

  Widget _buildSprintView(BuildContext context, BacklogProvider backlog) {
    final sprintNumber =
        context.read<SettingsProvider>().currentSprintNumber;
    final items = backlog.currentSprintItems;
    final total = backlog.totalPointsCurrentSprint;
    final completed = backlog.completedPointsCurrentSprint;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(label: 'Sprint', value: '#$sprintNumber'),
              _StatChip(label: 'Gesamt', value: '$total SP'),
              _StatChip(label: 'Erledigt', value: '$completed SP'),
              _StatChip(
                  label: 'Fortschritt',
                  value: total > 0
                      ? '${(completed / total * 100).round()}%'
                      : '–'),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_run, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Keine Items in Sprint $sprintNumber'),
                    ],
                  ),
                )
              : _buildItemList(context, items, backlog),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
