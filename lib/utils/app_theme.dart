// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AppTheme {
  static const Color primaryPurple = Color(0xFF5B21B6);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color cardBackground = Color(0xFF1E1E3F);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color warningRed = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E1E3F),
      Color(0xFF5B21B6),
      Color(0xFF1E1E3F),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primaryPurple, primaryPink],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.purple,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primaryPurple.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
          decoration: TextDecoration.none,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          decoration: TextDecoration.none,
        ),
        bodySmall: TextStyle(
          color: Colors.white60,
          fontSize: 12,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }
}