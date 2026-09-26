import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thèmes clair et sombre (Material 3) : palette chaleureuse générée depuis
/// une couleur, police Poppins et formes arrondies.
///
/// Tous les écrans lisent ce thème : changer une valeur ici met à jour
/// toute l'app.
abstract final class AppTheme {
  static const Color _seedColor = Color(0xFFE85D04);

  /// Rayon des coins, partagé par les cartes, les champs et les boutons.
  static const double radius = 16;

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
      // `fidelity` garde un orange vif, proche de la couleur de départ.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final TextTheme textTheme = GoogleFonts.poppinsTextTheme(
      ThemeData(colorScheme: colors).textTheme,
    );
    final RoundedRectangleBorder roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      colorScheme: colors,
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainerLow,
        shape: roundedShape,
        clipBehavior: Clip.antiAlias,
      ),
      // Champs remplis, sans contour ; contour orange quand le champ est actif.
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIconColor: colors.onSurfaceVariant,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: roundedShape,
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: roundedShape,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: colors.outlineVariant),
        backgroundColor: colors.surfaceContainerLow,
        labelStyle: textTheme.labelLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainer,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (Set<WidgetState> states) => textTheme.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
