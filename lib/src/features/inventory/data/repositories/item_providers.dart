import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository_impl.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/repositories/item_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_providers.dart'; // Access common providers

/// Provider for the ItemRepository implementation.
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(userIdProvider);
  return SupabaseItemRepository(client, userId);
});

/// Family FutureProvider to fetch items for a specific pallet.
final itemsByPalletProvider = FutureProvider.family<List<Item>, int>((ref, palletId) async {
  final repository = ref.watch(itemRepositoryProvider);
  try {
    return await repository.fetchItemsByPallet(palletId);
  } catch (e) {
     print('Error fetching items for pallet $palletId via provider: $e');
     rethrow;
  }
});

/// Family FutureProvider to fetch a single item by its ID.
final itemByIdProvider = FutureProvider.family<Item?, int>((ref, itemId) async {
  final repository = ref.watch(itemRepositoryProvider);
   try {
    return await repository.fetchItemById(itemId);
  } catch (e) {
    print('Error fetching item $itemId via provider: $e');
    rethrow;
  }
});

// Note: Providers for create/update/delete actions are usually handled differently.
// Typically, you'd call the repository methods directly from a StateNotifier or
// another provider that manages the state mutation, invalidating FutureProviders
// like `itemsByPalletProvider` afterwards to refresh the data. 