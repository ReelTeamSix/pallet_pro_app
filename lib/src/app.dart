import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/theme/app_theme.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

// Cache the last known theme mode to prevent flicker during logout
final _cachedThemeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Provider that derives theme from settings but caches the last value
final themeModeProvider = Provider<ThemeMode>((ref) {
  // Watch the settings controller's AsyncValue state
  final settingsAsyncValue = ref.watch(userSettingsControllerProvider);

  final settings = settingsAsyncValue.valueOrNull;
  
  // If settings are available, calculate and cache the theme mode
  if (settings != null) {
    ThemeMode currentThemeMode;
    switch (settings.theme) {
      case 'dark':
        currentThemeMode = ThemeMode.dark;
        break;
      case 'light':
        currentThemeMode = ThemeMode.light;
        break;
      case 'system':
      default:
        currentThemeMode = ThemeMode.system;
        break;
    }
    
    // Update the cache with the current theme
    // Use Future.microtask to avoid modifying providers during build
    Future.microtask(() {
      ref.read(_cachedThemeModeProvider.notifier).state = currentThemeMode;
    });
    
    return currentThemeMode;
  }
  
  // If settings are null (logged out or loading), return cached theme
  // This prevents flicker when user logs out
  return ref.read(_cachedThemeModeProvider);
});

/// The main application widget.
class App extends ConsumerStatefulWidget {
  /// Creates a new [App] instance.
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  Timer? _splashSafetyTimer;

  @override
  void initState() {
    super.initState();

    // Additional safety measure - if we're stuck on splash for too long, force navigation
    // This timer logic is largely handled within the RouterNotifier now.
    // Consider removing this if redundant.
    // if (kIsWeb) {
    //   _splashSafetyTimer = Timer(const Duration(seconds: 4), () {
    //     debugPrint('App: Splash safety timer expired, forcing navigation to login');
    //
    //     // Get router and attempt to go to login directly
    //     final router = ref.read(routerProvider);
    //
    //     // The redirect logic in RouterNotifier should handle splash timeouts.
    //     // router.go('/login?from=app_safety_timer'); // Example direct navigation
    //   });
    // }
  }

  @override
  void dispose() {
    _splashSafetyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the derived theme mode provider directly
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    // The logic to calculate themeMode is now inside themeModeProvider
    // No need to watch userSettingsControllerProvider directly here for the theme
    // And crucially, no need to manually update a provider during build.
    // final settings = ref.watch(userSettingsControllerProvider).value; // No longer needed here for theme
    // ThemeMode currentThemeMode = ThemeMode.system; // Logic moved
    // if (settings != null) { ... } // Logic moved
    // if (currentThemeMode != ref.read(cachedThemeModeProvider)) { // REMOVED THIS BLOCK
    //   ref.read(cachedThemeModeProvider.notifier).state = currentThemeMode; // REMOVED THIS BLOCK
    // } // REMOVED THIS BLOCK
    // final themeMode = ref.watch(cachedThemeModeProvider); // Changed to themeModeProvider above

    return MaterialApp.router(
      title: 'Pallet Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: themeMode, // Use the derived theme mode
      routerConfig: router,
    );
  }
}
