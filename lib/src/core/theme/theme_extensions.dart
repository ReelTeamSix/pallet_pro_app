import 'package:flutter/material.dart';
import 'package:pallet_pro_app/src/core/theme/app_theme.dart';

/// Extension methods for [BuildContext] to access theme properties.
extension ThemeExtensions on BuildContext {
  /// Gets the current theme.
  ThemeData get theme => Theme.of(this);

  /// Gets the current text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Gets the current color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Gets the primary color from the current theme.
  Color get primaryColor => colorScheme.primary;

  /// Gets the secondary color from the current theme.
  Color get secondaryColor => colorScheme.secondary;

  /// Gets the background color from the current theme.
  Color get backgroundColor => colorScheme.background;

  /// Gets the surface color from the current theme.
  Color get surfaceColor => colorScheme.surface;

  /// Gets the error color from the current theme.
  Color get errorColor => colorScheme.error;

  /// Gets the on-primary color from the current theme.
  Color get onPrimaryColor => colorScheme.onPrimary;

  /// Gets the on-secondary color from the current theme.
  Color get onSecondaryColor => colorScheme.onSecondary;

  /// Gets the on-background color from the current theme.
  Color get onBackgroundColor => colorScheme.onBackground;

  /// Gets the on-surface color from the current theme.
  Color get onSurfaceColor => colorScheme.onSurface;

  /// Gets the on-error color from the current theme.
  Color get onErrorColor => colorScheme.onError;

  /// Gets the extra small spacing value.
  double get spacingXs => AppTheme.spacingXs;

  /// Gets the small spacing value.
  double get spacingSm => AppTheme.spacingSm;

  /// Gets the medium spacing value.
  double get spacingMd => AppTheme.spacingMd;

  /// Gets the large spacing value.
  double get spacingLg => AppTheme.spacingLg;

  /// Gets the extra large spacing value.
  double get spacingXl => AppTheme.spacingXl;

  /// Gets the extra extra large spacing value.
  double get spacingXxl => AppTheme.spacingXxl;

  /// Gets the small border radius value.
  double get borderRadiusSm => AppTheme.borderRadiusSm;

  /// Gets the medium border radius value.
  double get borderRadiusMd => AppTheme.borderRadiusMd;

  /// Gets the large border radius value.
  double get borderRadiusLg => AppTheme.borderRadiusLg;

  /// Gets the extra large border radius value.
  double get borderRadiusXl => AppTheme.borderRadiusXl;

  /// Gets the circular border radius value.
  double get borderRadiusCircular => AppTheme.borderRadiusCircular;

  /// Gets the no elevation value.
  double get elevationNone => AppTheme.elevationNone;

  /// Gets the low elevation value.
  double get elevationLow => AppTheme.elevationLow;

  /// Gets the medium elevation value.
  double get elevationMedium => AppTheme.elevationMedium;

  /// Gets the high elevation value.
  double get elevationHigh => AppTheme.elevationHigh;

  /// Gets the extra high elevation value.
  double get elevationXHigh => AppTheme.elevationXHigh;

  /// Checks if the current theme is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Gets the display large text style.
  TextStyle? get displayLarge => textTheme.displayLarge;

  /// Gets the display medium text style.
  TextStyle? get displayMedium => textTheme.displayMedium;

  /// Gets the display small text style.
  TextStyle? get displaySmall => textTheme.displaySmall;

  /// Gets the headline large text style.
  TextStyle? get headlineLarge => textTheme.headlineLarge;

  /// Gets the headline medium text style.
  TextStyle? get headlineMedium => textTheme.headlineMedium;

  /// Gets the headline small text style.
  TextStyle? get headlineSmall => textTheme.headlineSmall;

  /// Gets the title large text style.
  TextStyle? get titleLarge => textTheme.titleLarge;

  /// Gets the title medium text style.
  TextStyle? get titleMedium => textTheme.titleMedium;

  /// Gets the title small text style.
  TextStyle? get titleSmall => textTheme.titleSmall;

  /// Gets the body large text style.
  TextStyle? get bodyLarge => textTheme.bodyLarge;

  /// Gets the body medium text style.
  TextStyle? get bodyMedium => textTheme.bodyMedium;

  /// Gets the body small text style.
  TextStyle? get bodySmall => textTheme.bodySmall;

  /// Gets the label large text style.
  TextStyle? get labelLarge => textTheme.labelLarge;

  /// Gets the label medium text style.
  TextStyle? get labelMedium => textTheme.labelMedium;

  /// Gets the label small text style.
  TextStyle? get labelSmall => textTheme.labelSmall;
}
