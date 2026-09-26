import 'package:flutter/material.dart';

/// Thèmes clair et sombre (Material 3), générés depuis une couleur.
abstract final class AppTheme {
  static const Color _seedColor = Color(0xFFE85D04);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: brightness,
      ),
    );
  }
}