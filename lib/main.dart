// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'screens/splash_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/game_screen.dart';
import 'screens/instructions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'services/ad_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await AdService.initialize();

  runApp(QuantumSyncApp());
}

class QuantumSyncApp extends StatefulWidget {
  @override
  _QuantumSyncAppState createState() => _QuantumSyncAppState();
}

class _QuantumSyncAppState extends State<QuantumSyncApp> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Flexible (downloads in background, prompts to restart)
        await InAppUpdate.startFlexibleUpdate();
      }
    } catch (e) {
      print("Update check failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Quantum Sync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: SplashScreen(),
      routes: {
        '/menu': (context) => MenuScreen(),
        '/game': (context) => GameScreen(),
        '/instructions': (context) => InstructionsScreen(),
        '/settings': (context) => SettingsScreen(),
        '/about': (context) => AboutScreen(),
      },
    );
  }
}