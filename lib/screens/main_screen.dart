import 'package:flutter/material.dart';
import 'package:agile_ai/screens/chat_screen.dart';
import 'package:agile_ai/screens/backlog_screen.dart';
import 'package:agile_ai/screens/analytics_screen.dart';
import 'package:agile_ai/screens/ceremonies_screen.dart';
import 'package:agile_ai/screens/more_screen.dart';

/// Haupt-Navigationshülle der App mit BottomNavigationBar.
/// Alle Screens werden in einem IndexedStack gehalten, damit ihr State
/// erhalten bleibt wenn zwischen Tabs gewechselt wird.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    ChatScreen(),
    BacklogScreen(),
    AnalyticsScreen(),
    CeremoniesScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Backlog',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Zeremonien',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'Mehr',
          ),
        ],
      ),
    );
  }
}
