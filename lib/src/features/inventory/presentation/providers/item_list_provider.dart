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
    final result = await _itemRepository.getAllItems();

    if (result.isSuccess) {
        return result.value;
    } else {
        throw result.error ?? AppException('Unknown error fetching items');
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
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String)
        : null,
    );
  }
}

// Mock provider that returns fixed data
final itemListProvider = FutureProvider<List<SimpleItem>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));
  
  // Return mock data
  return _mockItems.map((json) => SimpleItem.fromJson(json)).toList();
}); 