import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pallet_pro_app/src/app.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

/// The Supabase instance for the application.
final supabase = Supabase.instance.client;

/// The entry point of the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with environment variables from .env file
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    debug: false,
  );

  // Run the app wrapped in a ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: AppWithLifecycleObserver(),
    ),
  );
}

/// A widget that observes app lifecycle changes.
class AppWithLifecycleObserver extends ConsumerStatefulWidget {
  /// Creates a new [AppWithLifecycleObserver] instance.
  const AppWithLifecycleObserver({super.key});

  @override
  ConsumerState<AppWithLifecycleObserver> createState() => _AppWithLifecycleObserverState();
}

class _AppWithLifecycleObserverState extends ConsumerState<AppWithLifecycleObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Notify the router that the app was resumed
      final router = ref.read(routerProvider);
      // Access the RouterNotifier directly from the provider
      final routerNotifier = ref.read(routerProvider.notifier);
      routerNotifier.appResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
