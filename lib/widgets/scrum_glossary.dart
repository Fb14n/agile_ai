import 'package:flutter/material.dart';

class ScrumGlossary {
  static const Map<String, ScrumTerm> terms = {
    'Daily Standup': ScrumTerm(
      name: 'Daily Standup',
      shortDescription: 'Tägliches 15-minütiges Team-Meeting',
      fullDescription:
          'Das Daily Standup (auch Daily Scrum) ist ein kurzes, tägliches Meeting, '
          'bei dem jedes Teammitglied drei Fragen beantwortet: Was habe ich gestern gemacht? '
          'Was plane ich heute? Gibt es Blocker?',
      icon: Icons.groups,
      color: Color(0xFF4CAF50),
    ),
    'Sprint Planning': ScrumTerm(
      name: 'Sprint Planning',
      shortDescription: 'Planung des kommenden Sprints',
      fullDescription:
          'Im Sprint Planning plant das Team, welche Aufgaben im nächsten Sprint '
          'umgesetzt werden. Das Team definiert ein Sprint-Ziel und wählt passende '
          'User Stories aus dem Product Backlog.',
      icon: Icons.calendar_month,
      color: Color(0xFF2196F3),
    ),
    'Sprint Review': ScrumTerm(
      name: 'Sprint Review',
      shortDescription: 'Präsentation der Sprint-Ergebnisse',
      fullDescription:
          'Im Sprint Review präsentiert das Team die im Sprint fertiggestellten Funktionen '
          'den Stakeholdern. Es wird Feedback eingeholt und der Product Backlog ggf. angepasst.',
      icon: Icons.preview,
      color: Color(0xFF9C27B0),
    ),
    'Sprint Retrospective': ScrumTerm(
      name: 'Sprint Retrospective',
      shortDescription: 'Reflexion über den letzten Sprint',
      fullDescription:
          'In der Retrospektive reflektiert das Team über den vergangenen Sprint: '
          'Was lief gut? Was kann verbessert werden? Welche konkreten Maßnahmen setzen wir um?',
      icon: Icons.insights,
      color: Color(0xFFFF9800),
    ),
    'Backlog Refinement': ScrumTerm(
      name: 'Backlog Refinement',
      shortDescription: 'Verfeinerung des Product Backlogs',
      fullDescription:
          'Beim Backlog Refinement (früher Backlog Grooming) werden User Stories '
          'detailliert, geschätzt und priorisiert. Das Team klärt offene Fragen und '
          'bereitet Stories für zukünftige Sprints vor.',
      icon: Icons.list_alt,
      color: Color(0xFF607D8B),
    ),
    'Sprint Goal': ScrumTerm(
      name: 'Sprint Goal',
      shortDescription: 'Ziel des aktuellen Sprints',
      fullDescription:
          'Das Sprint-Ziel ist ein kurzes Statement, das beschreibt, was im Sprint '
          'erreicht werden soll. Es gibt dem Team Fokus und Orientierung.',
      icon: Icons.flag,
      color: Color(0xFFF44336),
    ),
    'Product Backlog': ScrumTerm(
      name: 'Product Backlog',
      shortDescription: 'Liste aller Anforderungen',
      fullDescription:
          'Der Product Backlog ist eine priorisierte Liste aller Funktionen, '
          'Verbesserungen und Bugfixes, die für das Produkt umgesetzt werden sollen.',
      icon: Icons.inventory_2,
      color: Color(0xFF3F51B5),
    ),
    'User Story': ScrumTerm(
      name: 'User Story',
      shortDescription: 'Anforderung aus Nutzersicht',
      fullDescription:
          'Eine User Story beschreibt eine Funktionalität aus Sicht des Nutzers: '
          '"Als [Rolle] möchte ich [Funktion], damit [Nutzen]."',
      icon: Icons.person,
      color: Color(0xFF00BCD4),
    ),
    'Blocker': ScrumTerm(
      name: 'Blocker / Impediment',
      shortDescription: 'Hindernis, das Fortschritt blockiert',
      fullDescription:
          'Ein Blocker (oder Impediment) ist ein Hindernis, das das Team daran hindert, '
          'seine Arbeit fortzusetzen. Der Scrum Master hilft dabei, Blocker zu beseitigen.',
      icon: Icons.block,
      color: Color(0xFFE91E63),
    ),
    'Velocity': ScrumTerm(
      name: 'Velocity',
      shortDescription: 'Arbeitsgeschwindigkeit des Teams',
      fullDescription:
          'Die Velocity ist ein Maß für die Arbeitsgeschwindigkeit eines Teams. '
          'Sie wird meist in Story Points pro Sprint gemessen und hilft bei der Planung.',
      icon: Icons.speed,
      color: Color(0xFF795548),
    ),
  };

  static ScrumTerm? getTerm(String name) {
    return terms[name];
  }

  static List<ScrumTerm> getAllTerms() {
    return terms.values.toList();
  }
}

class ScrumTerm {
  final String name;
  final String shortDescription;
  final String fullDescription;
  final IconData icon;
  final Color color;

  const ScrumTerm({
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.icon,
    required this.color,
  });
}

class ScrumTermTooltip extends StatelessWidget {
  final String termName;
  final Widget child;

  const ScrumTermTooltip({
    super.key,
    required this.termName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final term = ScrumGlossary.getTerm(termName);
    if (term == null) return child;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.info_outline, size: 18),
          onPressed: () => showTermDialog(context, term),
          tooltip: 'Was ist ${term.name}?',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  static void showTermDialog(BuildContext context, ScrumTerm term) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(term.icon, color: term.color, size: 48),
        title: Text(term.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              term.shortDescription,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: term.color,
                  ),
            ),
            const SizedBox(height: 16),
            Text(term.fullDescription),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Verstanden'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showGlossary(context);
            },
            icon: const Icon(Icons.book),
            label: const Text('Alle Begriffe'),
          ),
        ],
      ),
    );
  }

  static void showGlossary(BuildContext context) {
    final terms = ScrumGlossary.getAllTerms();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.book,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Scrum Glossar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: terms.length,
                  itemBuilder: (context, index) {
                    final term = terms[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: term.color.withOpacity(0.1),
                          child: Icon(term.icon, color: term.color),
                        ),
                        title: Text(
                          term.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(term.shortDescription),
                        onTap: () {
                          Navigator.of(context).pop();
                          showTermDialog(context, term);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
