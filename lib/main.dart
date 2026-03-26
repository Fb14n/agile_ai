import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:agile_ai/providers/chat_provider.dart';
import 'package:agile_ai/providers/settings_provider.dart';
import 'package:agile_ai/providers/backlog_provider.dart';
import 'package:agile_ai/providers/team_provider.dart';
import 'package:agile_ai/providers/analytics_provider.dart';
import 'package:agile_ai/screens/main_screen.dart';
import 'package:agile_ai/screens/onboarding_screen.dart';
import 'package:agile_ai/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Independent providers first
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        // Providers depending on SettingsProvider
        ChangeNotifierProxyProvider<SettingsProvider, ChatProvider>(
          create: (ctx) => ChatProvider(ctx.read<SettingsProvider>()),
          update: (_, settings, prev) => prev ?? ChatProvider(settings),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, BacklogProvider>(
          create: (ctx) => BacklogProvider(ctx.read<SettingsProvider>()),
          update: (_, settings, prev) => prev ?? BacklogProvider(settings),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
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
            seedColor: Colors.deepPurple,
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
        themeMode: ThemeMode.system,
        home: const _AppRoot(),
      ),
    );
  }
}

/// Shows a loading indicator until settings are loaded,
/// then routes to either OnboardingScreen or MainScreen.
class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (!settings.isLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!settings.onboardingComplete) {
          return const OnboardingScreen();
        }
        return const MainScreen();
      },
    );
  }
}
