import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The application theme.
class AppTheme {
  /// Creates a new [AppTheme] instance.
  const AppTheme._();

  // Colors
  static const _primaryLight = Color(0xFF1565C0); // Blue 800
  static const _primaryDark = Color(0xFF42A5F5); // Blue 400
  static const _secondaryLight = Color(0xFF00796B); // Teal 700
  static const _secondaryDark = Color(0xFF4DB6AC); // Teal 300
  static const _errorLight = Color(0xFFD32F2F); // Red 700
  static const _errorDark = Color(0xFFEF5350); // Red 400
  static const _backgroundLight = Color(0xFFF5F5F5); // Grey 100
  static const _backgroundDark = Color(0xFF121212); // Material Dark Background
  static const _surfaceLight = Color(0xFFFFFFFF); // White
  static const _surfaceDark = Color(0xFF1E1E1E); // Material Dark Surface
  static const _onPrimaryLight = Color(0xFFFFFFFF); // White
  static const _onPrimaryDark = Color(0xFF000000); // Black
  static const _onSecondaryLight = Color(0xFFFFFFFF); // White
  static const _onSecondaryDark = Color(0xFF000000); // Black
  static const _onBackgroundLight = Color(0xFF000000); // Black
  static const _onBackgroundDark = Color(0xFFFFFFFF); // White
  static const _onSurfaceLight = Color(0xFF000000); // Black
  static const _onSurfaceDark = Color(0xFFFFFFFF); // White
  static const _onErrorLight = Color(0xFFFFFFFF); // White
  static const _onErrorDark = Color(0xFF000000); // Black

  // Spacing
  /// Extra small spacing.
  static const double spacingXs = 4.0;
  /// Small spacing.
  static const double spacingSm = 8.0;
  /// Medium spacing.
  static const double spacingMd = 16.0;
  /// Large spacing.
  static const double spacingLg = 24.0;
  /// Extra large spacing.
  static const double spacingXl = 32.0;
  /// Extra extra large spacing.
  static const double spacingXxl = 48.0;

  // Border Radius
  /// Small border radius.
  static const double borderRadiusSm = 4.0;
  /// Medium border radius.
  static const double borderRadiusMd = 8.0;
  /// Large border radius.
  static const double borderRadiusLg = 12.0;
  /// Extra large border radius.
  static const double borderRadiusXl = 16.0;
  /// Circular border radius.
  static const double borderRadiusCircular = 999.0;

  // Elevation
  /// No elevation.
  static const double elevationNone = 0.0;
  /// Low elevation.
  static const double elevationLow = 2.0;
  /// Medium elevation.
  static const double elevationMedium = 4.0;
  /// High elevation.
  static const double elevationHigh = 8.0;
  /// Extra high elevation.
  static const double elevationXHigh = 16.0;

  // Typography
  static TextTheme _createTextTheme(bool isLight) {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final color = isLight ? _onSurfaceLight : _onSurfaceDark;
    
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: color,
        fontSize: 57,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: color,
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: color,
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: color,
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: color,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: color,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: color,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Light theme data.
  static ThemeData lightThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primaryLight,
      onPrimary: _onPrimaryLight,
      secondary: _secondaryLight,
      onSecondary: _onSecondaryLight,
      error: _errorLight,
      onError: _onErrorLight,
      background: _backgroundLight,
      onBackground: _onBackgroundLight,
      surface: _surfaceLight,
      onSurface: _onSurfaceLight,
    ),
    textTheme: _createTextTheme(true),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryLight,
      foregroundColor: _onPrimaryLight,
      elevation: elevationLow,
    ),
    cardTheme: CardTheme(
      color: _surfaceLight,
      elevation: elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryLight,
        foregroundColor: _onPrimaryLight,
        elevation: elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        side: const BorderSide(color: _primaryLight),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryLight,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: _primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: _errorLight),
      ),
      contentPadding: const EdgeInsets.all(spacingMd),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryLight,
      foregroundColor: _onPrimaryLight,
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.grey,
      thickness: 1,
      space: spacingMd,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade200,
      labelStyle: const TextStyle(color: _onSurfaceLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusCircular),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: _primaryLight,
      unselectedLabelColor: Colors.grey,
      indicatorColor: _primaryLight,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceLight,
      selectedItemColor: _primaryLight,
      unselectedItemColor: Colors.grey,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _onSurfaceLight,
      contentTextStyle: TextStyle(color: _surfaceLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
      ),
    ),
  );

  /// Dark theme data.
  static ThemeData darkThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _primaryDark,
      onPrimary: _onPrimaryDark,
      secondary: _secondaryDark,
      onSecondary: _onSecondaryDark,
      error: _errorDark,
      onError: _onErrorDark,
      background: _backgroundDark,
      onBackground: _onBackgroundDark,
      surface: _surfaceDark,
      onSurface: _onSurfaceDark,
    ),
    textTheme: _createTextTheme(false),
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceDark,
      foregroundColor: _onSurfaceDark,
      elevation: elevationLow,
    ),
    cardTheme: CardTheme(
      color: _surfaceDark,
      elevation: elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: _onPrimaryDark,
        elevation: elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        side: const BorderSide(color: _primaryDark),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryDark,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: _errorDark),
      ),
      contentPadding: const EdgeInsets.all(spacingMd),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryDark,
      foregroundColor: _onPrimaryDark,
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.grey,
      thickness: 1,
      space: spacingMd,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade800,
      labelStyle: const TextStyle(color: _onSurfaceDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusCircular),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: _primaryDark,
      unselectedLabelColor: Colors.grey,
      indicatorColor: _primaryDark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceDark,
      selectedItemColor: _primaryDark,
      unselectedItemColor: Colors.grey,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _onSurfaceDark,
      contentTextStyle: TextStyle(color: _surfaceDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
      ),
    ),
  );
}
