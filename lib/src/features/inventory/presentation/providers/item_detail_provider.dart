import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_list_provider.dart';

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

    try {
      // The repository method name might be different - adjust as needed
      final result = await _itemRepository.getItemById(itemId);

      if (result.isSuccess) {
        return result.value; // Access the item data
      } else {
        // Throw the error contained in the Result or a fallback UnexpectedException
        throw result.error ?? UnexpectedException('Unknown error fetching item'); 
      }
    } catch (e) {
      // If it's already an AppException (or specific subtype from repo), rethrow
      if (e is AppException) {
        rethrow;
      }
      // Otherwise, wrap it before rethrowing
      throw UnexpectedException('Failed to fetch item: $e'); // Use UnexpectedException
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

// Mock data for item details (reusing the SimpleItem model from item_list_provider.dart)
final _mockItemDetails = [
  {
    'id': 'i1',
    'name': 'Bluetooth Speaker',
    'description': 'Portable wireless speaker with good bass',
    'pallet_id': 'p1',
    'condition': 'new',
    'quantity': 2,
    'purchase_price': 25.99,
    'status': 'forSale',
    'storage_location': 'Garage Shelf B2',
    'sales_channel': 'Facebook Marketplace',
    'created_at': '2023-10-16T10:30:00.000Z',
    'updated_at': '2023-10-16T10:30:00.000Z',
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
    'storage_location': 'Living Room Bin 1',
    'sales_channel': 'eBay',
    'created_at': '2023-10-16T11:15:00.000Z',
    'updated_at': '2023-10-16T11:15:00.000Z',
  },
  {
    'id': 'i3',
    'name': 'Smart Watch',
    'description': 'Fitness tracker with heart rate monitor',
    'pallet_id': 'p2',
    'condition': 'good',
    'quantity': 1,
    'purchase_price': 45.00,
    'status': 'sold',
    'storage_location': 'Office Desk Drawer',
    'sales_channel': 'Private Group',
    'created_at': '2023-11-21T09:45:00.000Z',
    'updated_at': '2023-11-21T09:45:00.000Z',
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
    'storage_location': 'Electronics Box',
    'sales_channel': null,
    'created_at': '2023-12-06T14:20:00.000Z',
    'updated_at': '2023-12-06T14:20:00.000Z',
  }
];

/// Provider that fetches a specific item by ID (mock implementation)
final itemDetailProviderMock = FutureProvider.family<SimpleItem?, String>((ref, itemId) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));
  
  try {
    // Find the matching item in our mock data
    final itemJson = _mockItemDetails.firstWhere(
      (i) => i['id'] == itemId,
      orElse: () => throw NotFoundException('Item not found with ID: $itemId'),
    );
    
    // Use cast<String, dynamic> to ensure the map type is correct for SimpleItem.fromJson
    return SimpleItem.fromJson(itemJson.cast<String, dynamic>());
  } catch (e) {
    if (e is! AppException) {
      throw UnexpectedException('Failed to fetch item: $e');
    }
    rethrow;
  }
}); 