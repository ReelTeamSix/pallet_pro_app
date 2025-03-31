import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository_impl.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/repositories/pallet_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_providers.dart'; // To access supabaseClientProvider and userIdProvider

/// Provider for the PalletRepository implementation.
final palletRepositoryProvider = Provider<PalletRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(userIdProvider);
  return SupabasePalletRepository(client, userId);
});

/// FutureProvider to fetch the list of pallets for the current user.
final palletsProvider = FutureProvider<List<Pallet>>((ref) async {
  final repository = ref.watch(palletRepositoryProvider);
  try {
    return await repository.fetchPallets();
  } catch (e) {
    print('Error fetching pallets via provider: $e');
    rethrow;
  }
});

/// Family FutureProvider to fetch a single pallet by its ID.
final palletByIdProvider = FutureProvider.family<Pallet?, int>((ref, palletId) async {
  final repository = ref.watch(palletRepositoryProvider);
   try {
    return await repository.fetchPalletById(palletId);
  } catch (e) {
    print('Error fetching pallet $palletId via provider: $e');
    rethrow;
  }
}); 