import 'package:flutter/material.dart';
import 'package:agile_ai/config/app_config.dart';

/// Offline Scrum glossary based on AppConfig.knowledgeBase.
/// No API call required.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty) return AppConfig.knowledgeBase;
    final q = _searchQuery.toLowerCase();
    return AppConfig.knowledgeBase
        .map((cat) {
          final entries = (cat['entries'] as List)
              .where((e) =>
                  (e['term'] as String).toLowerCase().contains(q) ||
                  (e['definition'] as String).toLowerCase().contains(q))
              .toList();
          if (entries.isEmpty) return null;
          return {...cat, 'entries': entries};
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _filteredCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrum-Glossar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Begriff suchen...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
                filled: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text('Kein Begriff gefunden',
                  style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final entries =
                    cat['entries'] as List<Map<String, dynamic>>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                      child: Text(
                        cat['category'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Card(
                      child: Column(
                        children: entries.asMap().entries.map((e) {
                          final isLast = e.key == entries.length - 1;
                          return Column(
                            children: [
                              ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                title: Text(
                                  e.value['term'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 12),
                                    child: Text(
                                      e.value['definition'] as String,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              if (!isLast)
                                const Divider(height: 1, indent: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
