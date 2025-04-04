import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/services/item_status_manager.dart';

/// Notifier responsible for managing the state of the item list.
///
/// It fetches items using the [ItemRepository] and handles loading, data,
/// and error states. Currently fetches all items, may be refined later.
class ItemListNotifier extends AsyncNotifier<List<Item>> {
  late final ItemRepository _itemRepository;
  late final ItemStatusManager _statusManager;

  // Current filter states
  ItemStatus? _statusFilter;
  String? _storageLocationFilter;
  String? _salesChannelFilter;
  String? _palletSourceFilter;

  ItemStatus? get statusFilter => _statusFilter;
  String? get storageLocationFilter => _storageLocationFilter;
  String? get salesChannelFilter => _salesChannelFilter;
  String? get palletSourceFilter => _palletSourceFilter;

  @override
  Future<List<Item>> build() async {
    _itemRepository = ref.watch(itemRepositoryProvider);
    _statusManager = ref.watch(itemStatusManagerProvider);
    // Initial fetch of items
    return _fetchItems();
  }

  Future<List<Item>> _fetchItems() async {
    // Apply current filters
    final result = await _itemRepository.getAllItems(
      statusFilter: _statusFilter,
      storageLocationFilter: _storageLocationFilter,
      salesChannelFilter: _salesChannelFilter,
      palletSourceFilter: _palletSourceFilter,
    );

    if (result.isSuccess) {
        return result.value;
    } else {
        throw result.error ?? UnexpectedException('Unknown error fetching items');
    }
  }

  /// Refreshes the item list.
  Future<void> refreshItems() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchItems());
  }

  /// Sets filters and refreshes the item list.
  Future<void> setFilters({
    ItemStatus? statusFilter,
    String? storageLocationFilter,
    String? salesChannelFilter,
    String? palletSourceFilter,
  }) async {
    // Only refresh if filters actually changed
    bool filtersChanged = false;
    
    if (statusFilter != _statusFilter) {
      _statusFilter = statusFilter;
      filtersChanged = true;
    }
    
    if (storageLocationFilter != _storageLocationFilter) {
      _storageLocationFilter = storageLocationFilter;
      filtersChanged = true;
    }
    
    if (salesChannelFilter != _salesChannelFilter) {
      _salesChannelFilter = salesChannelFilter;
      filtersChanged = true;
    }
    
    if (palletSourceFilter != _palletSourceFilter) {
      _palletSourceFilter = palletSourceFilter;
      filtersChanged = true;
    }
    
    if (filtersChanged) {
      await refreshItems();
    }
  }

  /// Clears all filters and refreshes the item list.
  Future<void> clearFilters() async {
    if (_statusFilter != null || 
        _storageLocationFilter != null || 
        _salesChannelFilter != null || 
        _palletSourceFilter != null) {
      _statusFilter = null;
      _storageLocationFilter = null;
      _salesChannelFilter = null;
      _palletSourceFilter = null;
      await refreshItems();
    }
  }

  /// Updates an item.
  Future<Result<Item>> updateItem(Item item) async {
    state = const AsyncValue.loading();
    final result = await _itemRepository.updateItem(item);
    
    return result.when(
      success: (updatedItem) async {
        await refreshItems();
        return Result.success(updatedItem);
      },
      failure: (exception) {
        state = AsyncError(exception, StackTrace.current);
        return Result.failure(exception);
      },
    );
  }

  /// Adds a new item.
  Future<Result<Item>> addItem(Item item) async {
    state = const AsyncValue.loading();
    final result = await _itemRepository.createItem(item);
    
    return result.when(
      success: (createdItem) async {
        await refreshItems();
        return Result.success(createdItem);
      },
      failure: (exception) {
        state = AsyncError(exception, StackTrace.current);
        return Result.failure(exception);
      },
    );
  }

  /// Marks an item as listed for sale.
  /// Uses the centralized ItemStatusManager for the actual logic.
  Future<Result<Item>> markItemAsListed({
    required String itemId,
    required double listingPrice,
    required String listingPlatform,
    DateTime? listingDate,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _statusManager.markAsListed(
      itemId: itemId,
      listingPrice: listingPrice,
      listingPlatform: listingPlatform,
      listingDate: listingDate,
    );
    
    // Refresh item list if successful
    if (result.isSuccess) {
      await refreshItems();
    } else {
      state = AsyncError(result.error ?? UnexpectedException('Unknown error'), StackTrace.current);
    }
    
    return result;
  }

  /// Marks an item as sold.
  /// Uses the centralized ItemStatusManager for the actual logic.
  Future<Result<Item>> markItemAsSold({
    required String itemId,
    required double soldPrice,
    required String sellingPlatform,
    DateTime? soldDate,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _statusManager.markAsSold(
      itemId: itemId,
      soldPrice: soldPrice,
      sellingPlatform: sellingPlatform,
      soldDate: soldDate,
    );
    
    // Refresh item list if successful
    if (result.isSuccess) {
      await refreshItems();
    } else {
      state = AsyncError(result.error ?? UnexpectedException('Unknown error'), StackTrace.current);
    }
    
    return result;
  }

  /// Marks an item as back in stock.
  /// Uses the centralized ItemStatusManager for the actual logic.
  Future<Result<Item>> markItemAsInStock(String itemId) async {
    state = const AsyncValue.loading();
    
    final result = await _statusManager.markAsInStock(itemId);
    
    // Refresh item list if successful
    if (result.isSuccess) {
      await refreshItems();
    } else {
      state = AsyncError(result.error ?? UnexpectedException('Unknown error'), StackTrace.current);
    }
    
    return result;
  }
}

/// Provider for the [ItemListNotifier].
///
/// Exposes the asynchronous state ([AsyncValue]) of the item list.
final itemListProvider =
    AsyncNotifierProvider<ItemListNotifier, List<Item>>(
  ItemListNotifier.new,
);

// Helper extension for item status conversion
extension ItemStatusStringConverter on ItemStatus {
  String get name {
    switch (this) {
      case ItemStatus.inStock: return 'in_stock';
      case ItemStatus.forSale: return 'for_sale';
      case ItemStatus.listed: return 'listed';
      case ItemStatus.sold: return 'sold';
    }
  }
}

// Helper extension for item condition conversion
extension ItemConditionStringConverter on ItemCondition {
  String get name {
    switch (this) {
      case ItemCondition.newItem: return 'New';
      case ItemCondition.openBox: return 'Open Box';
      case ItemCondition.usedGood: return 'Used - Good';
      case ItemCondition.usedFair: return 'Used - Fair';
      case ItemCondition.damaged: return 'Damaged';
      case ItemCondition.forParts: return 'For Parts';
    }
  }
} 