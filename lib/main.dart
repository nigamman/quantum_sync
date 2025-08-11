// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/game_screen.dart';
import 'screens/instructions_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(QuantumSyncApp());
}

class QuantumSyncApp extends StatelessWidget {
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
      },
    );
  }
}