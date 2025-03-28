import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/theme/app_theme.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

/// The theme mode provider.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// The main application widget.
class App extends ConsumerWidget {
  /// Creates a new [App] instance.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pallet Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
