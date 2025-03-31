import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../settings/data/repositories/user_settings_providers.dart';

import '../models/pallet.dart';
import '../repositories/pallet_repository.dart';
import '../repositories/supabase_pallet_repository_impl.dart';

part 'pallet_providers.g.dart';

/// Dummy provider for testing generator
@riverpod
String dummy(DummyRef ref) {
  return 'hello';
}

/// Provider for the Supabase implementation of PalletRepository.
///
/// Depends on the global Supabase client provider.
@riverpod
PalletRepository palletRepository(PalletRepositoryRef ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  // Only return an instance if the client is available (user logged in)
  // Otherwise, consumers should handle the null/error state appropriately.
  // Note: This follows a similar pattern to userSettingsRepositoryProvider
  // but avoids throwing directly, letting consumers decide.
  if (supabaseClient == null) {
    // Throwing here would make any dependent providers fail immediately.
    // Consider returning a specific error state or a dummy implementation
    // if downstream needs a non-null repository even when logged out.
    throw Exception('Supabase client not available. User might be logged out.');
  }
  return SupabasePalletRepositoryImpl(supabaseClient);
}

/// Provider to watch the list of pallets for the current user.
///
/// Depends on the palletRepositoryProvider and the auth state provider.
@riverpod
Stream<List<Pallet>> watchPallets(WatchPalletsRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  final currentUser = authState.valueOrNull?.session?.user;
  final userId = currentUser?.id;

  // If no user is logged in, return an empty stream.
  if (userId == null) {
    return Stream.value([]);
  }

  // Watch the repository provider. If it encounters an error (like Supabase
  // client not being ready), this provider will bubble up the error.
  final palletRepo = ref.watch(palletRepositoryProvider);
  return palletRepo.watchPallets(userId);
} 