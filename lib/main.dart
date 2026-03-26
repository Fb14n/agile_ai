import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/providers/analytics_provider.dart';
import 'package:agile_ai/providers/project_provider.dart';
import 'package:agile_ai/providers/meeting_provider.dart';
import 'package:agile_ai/providers/context_provider.dart';
import 'package:agile_ai/services/database_service.dart';
import 'package:agile_ai/services/seed_service.dart';
import 'package:agile_ai/services/project_service.dart';
import 'package:agile_ai/services/meeting_service.dart';
import 'package:agile_ai/services/ai_service.dart';
import 'package:agile_ai/screens/project_list_screen.dart';
import 'package:agile_ai/screens/project_detail_screen.dart';
import 'package:agile_ai/screens/meeting_screen.dart';
import 'package:agile_ai/screens/global_stats_screen.dart';
import 'package:agile_ai/screens/settings_screen.dart';
import 'package:agile_ai/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env: $e');
  }

  // Initialize database and seed if empty
  final dbService = DatabaseService();
  await dbService.database; // Trigger initialization
  
  // Seed fantasy project if database is empty
  final isEmpty = await dbService.isDatabaseEmpty();
  if (isEmpty) {
    final seedService = SeedService(dbService);
    await seedService.seedFantasyProject();
  }

  runApp(MyApp(dbService: dbService));
}

class MyApp extends StatelessWidget {
  final DatabaseService dbService;

  const MyApp({super.key, required this.dbService});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final aiService = AiService();
    final projectService = ProjectService(dbService);
    final meetingService = MeetingService(dbService, aiService);

    return MultiProvider(
      providers: [
        // Services
        Provider<DatabaseService>.value(value: dbService),
        Provider<ProjectService>.value(value: projectService),
        Provider<MeetingService>.value(value: meetingService),
        Provider<AiService>.value(value: aiService),
        
        // State providers
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider(projectService)),
        ChangeNotifierProvider(create: (_) => MeetingProvider(meetingService, projectService)),
        ChangeNotifierProvider(create: (_) => ContextProvider(projectService)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 2,
              ),
              cardTheme: const CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 2,
              ),
              cardTheme: const CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            themeMode: _getThemeMode(settings.themeMode),
            home: const ProjectListScreen(),
            routes: {
              '/global-stats': (context) => const GlobalStatsScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              // Dynamic routing for project-specific screens
              final uri = Uri.parse(settings.name ?? '');
              
              // /project/:id
              if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'project') {
                final projectId = uri.pathSegments[1];
                return MaterialPageRoute(
                  builder: (context) => ProjectDetailScreen(projectId: projectId),
                );
              }
              
              // /project/:id/meeting/:type
              if (uri.pathSegments.length == 4 &&
                  uri.pathSegments[0] == 'project' &&
                  uri.pathSegments[2] == 'meeting') {
                final projectId = uri.pathSegments[1];
                final meetingType = uri.pathSegments[3];
                return MaterialPageRoute(
                  builder: (context) => MeetingScreen(
                    projectId: projectId,
                    meetingType: meetingType,
                  ),
                );
              }
              
              return null;
            },
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
