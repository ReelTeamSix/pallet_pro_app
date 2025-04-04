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

// TEMPORARY: Mock data for UI testing until model issues are fixed

// Temporary simple model class for UI testing
class SimpleItem {
  final String id;
  final String? name;
  final String? description;
  final String palletId;
  final String condition;
  final int quantity;
  final double? purchasePrice;
  final String status;
  final String? storageLocation;
  final String? salesChannel;
  final DateTime? createdAt;
  
  SimpleItem({
    required this.id,
    this.name,
    this.description,
    required this.palletId,
    required this.condition,
    required this.quantity,
    this.purchasePrice,
    required this.status,
    this.storageLocation,
    this.salesChannel,
    this.createdAt,
  });
  
  factory SimpleItem.fromJson(Map<String, dynamic> json) {
    return SimpleItem(
      id: json['id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      palletId: json['pallet_id'] as String,
      condition: json['condition'] as String,
      quantity: json['quantity'] as int,
      purchasePrice: json['purchase_price'] as double?,
      status: json['status'] as String,
      storageLocation: json['storage_location'] as String?,
      salesChannel: json['sales_channel'] as String?,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String)
        : null,
    );
  }
}

// For temporary usage of SimpleItem, consider creating a separate provider like:
final simpleItemListProvider = FutureProvider<List<SimpleItem>>((ref) async {
  try {
    // Get items from the real repository via itemListProvider
    final itemsAsync = await ref.watch(itemListProvider.future);
    
    // Convert the real Item objects to SimpleItem objects
    final simpleItems = itemsAsync.map((item) => SimpleItem(
      id: item.id,
      name: item.name,
      description: item.description,
      palletId: item.palletId,
      condition: item.condition.name, // Convert enum to string
      quantity: item.quantity,
      purchasePrice: item.purchasePrice,
      status: item.status.name, // Convert enum to string
      storageLocation: item.storageLocation,
      salesChannel: item.salesChannel,
      createdAt: item.createdAt,
    )).toList();
    
    return simpleItems;
  } catch (e) {
    // If there's an error, return mock data as a fallback
    print('Error loading real items, falling back to mock data: $e');
    return _mockItems.map((json) => SimpleItem.fromJson(json)).toList();
  }
});

// TEMPORARY: Mock data for UI testing until model issues are fixed
final _mockItems = [
  {
    'id': 'i1',
    'name': 'Bluetooth Speaker',
    'description': 'Portable wireless speaker with good bass',
    'pallet_id': 'p1',
    'condition': 'new',
    'quantity': 2,
    'purchase_price': 25.99,
    'status': 'forSale',
    'created_at': '2023-10-16T10:30:00.000Z',
  },
  {
    'id': 'i2',
    'name': 'Wireless Earbuds',
    'description': 'True wireless earbuds with charging case',
    'pallet_id': 'p1',
    'condition': 'likeNew',
    'quantity': 3,
    'purchase_price': 15.50,
    'status': 'forSale',
    'created_at': '2023-10-16T11:15:00.000Z',
  },
  {
    'id': 'i3',
    'name': 'Smart Watch',
    'description': 'Fitness tracker with heart rate monitor',
    'pallet_id': 'p2',
    'condition': 'good',
    'quantity': 1,
    'purchase_price': 45.00,
    'status': 'forSale',
    'created_at': '2023-11-21T09:45:00.000Z',
  },
  {
    'id': 'i4',
    'name': 'USB-C Cable',
    'description': '6ft braided charging cable',
    'pallet_id': 'p3',
    'condition': 'new',
    'quantity': 5,
    'purchase_price': 3.99,
    'status': 'forSale',
    'created_at': '2023-12-06T14:20:00.000Z',
  }
];

// Add a SimpleItemListNotifier class with filter methods
class SimpleItemListNotifier extends StateNotifier<List<SimpleItem>> {
  List<SimpleItem> _originalItems = [];
  String? _statusFilter;
  
  SimpleItemListNotifier() : super([]);
  
  // Initialize with real data
  void initialize(List<SimpleItem> items) {
    _originalItems = List.from(items);
    _applyFilters();
  }
  
  // Real filter implementation
  void setFilters({String? statusFilter}) {
    _statusFilter = statusFilter;
    _applyFilters();
  }
  
  // Apply filters to _originalItems and update state
  void _applyFilters() {
    if (_statusFilter == null) {
      state = List.from(_originalItems); // No filters, show all items
    } else {
      // Apply status filter
      state = _originalItems.where((item) => 
        item.status == _statusFilter
      ).toList();
    }
  }
  
  // Clear all filters
  void clearFilters() {
    _statusFilter = null;
    state = List.from(_originalItems);
  }
  
  // Add a method to add items to the state
  void addItem(SimpleItem item) {
    _originalItems.add(item);
    _applyFilters(); // Apply any active filters to the updated list
  }
}

// Add a provider for the notifier
final simpleItemListNotifierProvider = StateNotifierProvider<SimpleItemListNotifier, List<SimpleItem>>((ref) {
  final notifier = SimpleItemListNotifier();
  
  // Listen to the real data from simpleItemListProvider
  ref.listen<AsyncValue<List<SimpleItem>>>(simpleItemListProvider, (_, next) {
    next.whenData((items) {
      // Update the notifier state when real data changes
      notifier.initialize(items);
    });
  });
  
  // Start with empty list - will be populated when data arrives
  notifier.initialize([]);
  
  return notifier;
});

/// Extension to allow easier access to the notifier
extension SimpleItemListNotifierExtension on FutureProvider<List<SimpleItem>> {
  StateNotifierProvider<SimpleItemListNotifier, List<SimpleItem>> get notifierProvider => simpleItemListNotifierProvider;
} 