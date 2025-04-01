import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';

/// Notifier responsible for managing the state of the item list.
///
/// It fetches items using the [ItemRepository] and handles loading, data,
/// and error states. Currently fetches all items, may be refined later.
class ItemListNotifier extends AsyncNotifier<List<Item>> {
  late final ItemRepository _itemRepository;

  @override
  Future<List<Item>> build() async {
    _itemRepository = ref.watch(itemRepositoryProvider);
    // Initial fetch of items
    return _fetchItems();
  }

  Future<List<Item>> _fetchItems() async {
    // Note: This fetches ALL items. Consider adding filtering by pallet later.
    final result = await _itemRepository.fetchItems();
    switch (result) {
      case Success(value: final items):
        return items;
      case Failure(exception: final exception):
        throw exception;
    }
  }

  /// Refreshes the item list.
  Future<void> refreshItems() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchItems());
  }

  // --- Methods for adding, updating, deleting items will be added later ---
}

/// Provider for the [ItemListNotifier].
///
/// Exposes the asynchronous state ([AsyncValue]) of the item list.
final itemListProvider = AsyncNotifierProvider<ItemListNotifier, List<Item>>(
  ItemListNotifier.new,
); 