import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_repository_impl.dart';
import 'package:pallet_pro_app/src/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart'; // Import model for FutureProvider

/// Provides the Supabase client instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for the authenticated user from Supabase auth state stream.
/// This is more reliable than checking currentUser directly.
final authUserStreamProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((state) => state.session?.user);
});

/// Provider for the UserSettingsRepository implementation.
/// Depends directly on the auth user stream.
final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  // Watch the user stream directly
  final authUserAsyncValue = ref.watch(authUserStreamProvider);

  // Get the user ID only if data is available and not null
  final userId = authUserAsyncValue.when(
    data: (user) => user?.id, // Return user ID or null
    loading: () => null,      // Return null while loading
    error: (err, stack) => null, // Return null on error
  );

  // If we don't have a userId, the repository cannot function.
  // Throw an exception that the UserSettingsController can handle.
  if (userId == null) {
    throw AuthException('User not available for UserSettingsRepository');
  }

  // Return the repository implementation with the valid user ID
  return SupabaseUserSettingsRepository(client, userId);
});

/// FutureProvider to fetch user settings.
/// Handles loading and error states automatically.
final userSettingsProvider = FutureProvider<UserSettings>((ref) async {
  final repository = ref.watch(userSettingsRepositoryProvider);
  try {
    return await repository.getUserSettings();
  } catch (e) {
    // Log or handle error appropriately
    print('Error fetching user settings via provider: $e');
    // Rethrow to let the UI handle the error state
    rethrow;
  }
}); 