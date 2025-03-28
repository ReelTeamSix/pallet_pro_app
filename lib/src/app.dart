import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/theme/app_theme.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';

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
    if (kIsWeb) {
      _splashSafetyTimer = Timer(const Duration(seconds: 4), () {
        debugPrint('App: Splash safety timer expired, forcing navigation to login');
        
        // Get router and attempt to go to login directly
        final router = ref.read(routerProvider);
        
        // Use a context-free way to check current location and navigate if needed
        final routerNotifier = ref.read(routerNotifierProvider.notifier);
        routerNotifier.checkAndNavigateFromSplash();
      });
    }
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
