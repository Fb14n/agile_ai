import 'package:flutter/material.dart';

/// Placeholder for global statistics screen
class GlobalStatsScreen extends StatelessWidget {
  const GlobalStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Globale Statistiken'),
      ),
      body: const Center(
        child: Text('Statistiken über alle Projekte (Coming Soon)'),
      ),
    );
  }
}
