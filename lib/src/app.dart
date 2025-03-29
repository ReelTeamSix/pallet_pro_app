import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/theme/app_theme.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';

/// Provider for persisting theme mode across auth state changes
final cachedThemeModeProvider = StateProvider<ThemeMode>((ref) {
  // Default to light theme
  return ThemeMode.light;
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
    // Watch user settings to determine theme mode
    final userSettingsAsync = ref.watch(userSettingsControllerProvider);
    
    // Update cached theme when settings change, but keep previous theme during transitions
    userSettingsAsync.whenData((settings) {
      if (settings != null) {
        final newThemeMode = settings.useDarkMode ? ThemeMode.dark : ThemeMode.light;
        ref.read(cachedThemeModeProvider.notifier).state = newThemeMode;
      }
    });
    
    // Use cached theme mode, which persists across auth state changes
    final themeMode = ref.watch(cachedThemeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pallet Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: themeMode, // Use the cached theme mode
      routerConfig: router,
    );
  }
}
