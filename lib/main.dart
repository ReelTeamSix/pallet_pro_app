import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pallet_pro_app/src/app.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';
import 'package:pallet_pro_app/src/features/auth/data/services/biometric_service.dart';

/// The Supabase instance for the application.
final supabase = Supabase.instance.client;

/// The entry point of the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  
  // Run the app as soon as possible while initializing Supabase in the background
  final ProviderContainer container = ProviderContainer();
  
  // Pre-check biometric availability in parallel
  final biometricFuture = BiometricService().isBiometricAvailable();
  
  // Start Supabase initialization in the background for better startup time
  final supabaseFuture = _initializeSupabase();
  
  // Start the app immediately without waiting for Supabase to fully initialize
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AppWithLifecycleObserver(),
    ),
  );
  
  // Continue initialization in the background
  await Future.wait([supabaseFuture, biometricFuture]);
}

/// Initialize Supabase with better error handling
Future<void> _initializeSupabase() async {
  try {
    // Get Supabase credentials from environment
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    // Debug info
    debugPrint('Initializing Supabase with URL: ${supabaseUrl?.isNotEmpty == true ? 'Present' : 'Missing!'}');
    debugPrint('Supabase Anon Key: ${supabaseAnonKey?.isNotEmpty == true ? 'Present' : 'Missing!'}');
    
    if (supabaseUrl == null || supabaseUrl.isEmpty || supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw Exception('Supabase credentials missing in .env file');
    }

    // Initialize Supabase with environment variables from .env file
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: !kReleaseMode, // Only enable debug mode in development
    );
    
    debugPrint('Supabase initialized successfully');
    
    // On web specifically, force a check to make sure auth state is populated
    if (kIsWeb) {
      // Wait a small amount of time to ensure auth state is properly populated
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Access auth state directly after initialization to ensure it's properly initialized
      final currentSession = Supabase.instance.client.auth.currentSession;
      debugPrint('Current session after init: ${currentSession != null ? 'exists' : 'null'}');
    }
  } catch (e, stack) {
    debugPrint('Error initializing Supabase: $e');
    debugPrint(stack.toString());
    // Continue anyway to let the app handle auth failure gracefully
  }
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
      final routerNotifier = ref.read(routerNotifierProvider.notifier);
      routerNotifier.appResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
