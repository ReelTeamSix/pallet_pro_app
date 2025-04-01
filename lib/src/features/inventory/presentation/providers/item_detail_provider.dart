import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';

/// Notifier responsible for managing the state of a single item's details.
///
/// It fetches a specific item by its ID using the [ItemRepository] and handles
/// loading, data, and error states.
class ItemDetailNotifier extends AutoDisposeFamilyAsyncNotifier<Item?, String> {
  late ItemRepository _itemRepository;

  @override
  Future<Item?> build(String arg) async {
    _itemRepository = ref.watch(itemRepositoryProvider);
    final itemId = arg;
    // Cancel any pending operations if the notifier is disposed
    // or the family argument changes.
    ref.onDispose(() {
      // Cleanup logic if needed
    });

    return _fetchItem(itemId);
  }

  Future<Item?> _fetchItem(String itemId) async {
    // Check if itemId is empty or invalid if necessary
    if (itemId.isEmpty) {
      return null; // Or throw a specific argument error
    }

    final result = await _itemRepository.fetchItemById(itemId);
    switch (result) {
      case Success(value: final item):
        // The repository might return null if not found, or a specific type.
        // Assuming fetchItemById returns Result<Item?> or handles not found.
        return item; // This could be null if the item doesn't exist
      case Failure(exception: final exception):
        // Re-throw to let AsyncValue handle the error state.
        // Consider mapping specific exceptions (like NotFoundException) if needed.
        throw exception;
    }
  }

  /// Refreshes the item details for the current item ID.
  Future<void> refreshItem() async {
    final itemId = arg; // Access the family argument
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchItem(itemId));
  }

  // --- Methods for updating or deleting the specific item can be added later ---
}

/// Provider for the [ItemDetailNotifier].
///
/// Exposes the asynchronous state ([AsyncValue]) of a single item, accessed
/// by its ID.
/// Use `ref.watch(itemDetailProvider(itemId))` to get the state.
final itemDetailProvider =
    AsyncNotifierProvider.autoDispose.family<ItemDetailNotifier, Item?, String>(
  ItemDetailNotifier.new,
); 