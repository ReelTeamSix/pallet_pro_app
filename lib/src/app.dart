import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/theme/app_theme.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';

/// The main application widget.
class App extends ConsumerWidget {
  /// Creates a new [App] instance.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user settings to determine theme mode
    final userSettingsAsync = ref.watch(userSettingsControllerProvider);
    final themeMode = userSettingsAsync.when(
      data: (settings) => (settings?.useDarkMode ?? false) ? ThemeMode.dark : ThemeMode.light,
      loading: () => ThemeMode.light, // Default to light while loading
      error: (err, stack) => ThemeMode.light, // Default to light on error
    );
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pallet Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: themeMode, // Use themeMode derived from user settings
      routerConfig: router,
    );
  }
}
