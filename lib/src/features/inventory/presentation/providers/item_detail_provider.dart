import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/exceptions/database_exception.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/storage_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/services/item_status_manager.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_list_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_photo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/entities/simple_item.dart';

/// Notifier responsible for managing the state of a single item's details.
///
/// It fetches a specific item by its ID using the [ItemRepository] and handles
/// loading, data, and error states.
class ItemDetailNotifier extends AutoDisposeFamilyAsyncNotifier<Item?, String> {
  late ItemRepository _itemRepository;
  late StorageRepository _storageRepository;
  late ItemPhotoRepository _itemPhotoRepository;
  late ItemStatusManager _statusManager;

  @override
  Future<Item?> build(String arg) async {
    _itemRepository = ref.watch(itemRepositoryProvider);
    _storageRepository = ref.watch(storageRepositoryProvider);
    _itemPhotoRepository = ref.watch(itemPhotoRepositoryProvider);
    _statusManager = ref.watch(itemStatusManagerProvider);
    
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
      
      if (result.isSuccess && result.value != null) {
        // Also fetch the item's photos
        try {
          final photosResult = await _itemPhotoRepository.getItemPhotos(itemId);
          if (photosResult.isSuccess) {
            if (kDebugMode) {
              print('Fetched ${photosResult.value.length} photos for item $itemId');
            }
          } else {
            if (kDebugMode) {
              print('Failed to fetch photos: ${photosResult.error?.message}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching photos: $e');
          }
        }
      }
      
      return result.fold(
        (item) => item,
        (error) => throw error, // Re-throw for AsyncValue to catch
      );
    } catch (e) {
      throw e; // Let AsyncValue handle this exception
    }
  }

  /// Refreshes the item data.
  Future<void> refreshItem() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchItem(arg));
  }

  /// Uploads photos for the item and returns the storage paths.
  /// 
  /// This method handles uploading photos to the storage repository
  /// and returns the list of storage paths for the uploaded photos.
  Future<Result<List<String>>> uploadItemPhotos(List<XFile> photos) async {
    final item = state.value;
    if (item == null) {
      return Result.failure(
        UnexpectedException('Cannot upload photos: Item not found'),
      );
    }

    try {
      final List<String> uploadedPaths = [];
      
      // Loop through each photo and upload it
      for (final photo in photos) {
        // Generate a unique filename using timestamp and original filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final originalFilename = photo.name;
        final fileExtension = originalFilename.split('.').last;
        final fileName = 'photo_${timestamp}.$fileExtension';
        
        // Upload the photo to storage
        final path = await _storageRepository.uploadItemPhoto(
          itemId: item.id,
          fileName: fileName,
          file: photo,
        );
        
        // Save the photo reference in the database
        final saveResult = await _itemPhotoRepository.saveItemPhoto(
          itemId: item.id,
          storagePath: path,
        );
        
        if (saveResult.isSuccess) {
          uploadedPaths.add(path);
        } else {
          // Log the error but continue with other photos
          print('Error saving photo metadata: ${saveResult.error?.message}');
        }
      }
      
      // Return the list of paths
      return Result.success(uploadedPaths);
    } catch (e) {
      return Result.failure(
        e is AppException ? e : UnexpectedException('Failed to upload photos: $e'),
      );
    }
  }

  /// Updates the item with new details.
  Future<Result<Item>> updateItem(Item updatedItem) async {
    try {
      state = const AsyncValue.loading();
      
      final result = await _itemRepository.updateItem(updatedItem);
      
      if (result.isSuccess) {
        // Update the state with the updated item
        state = AsyncValue.data(result.value);
        return Result.success(result.value);
      } else {
        // Revert to previous state on error
        await refreshItem();
        return Result.failure(result.error ?? UnexpectedException('Unknown error updating item'));
      }
    } catch (e) {
      // Handle unexpected errors
      await refreshItem();
      return Result.failure(
        e is AppException ? e : UnexpectedException('Failed to update item: $e'),
      );
    }
  }

  /// Deletes photos for the current item
  Future<Result<void>> deleteItemPhotos(List<String> photoPaths) async {
    try {
      await _storageRepository.deleteItemPhotos(photoPaths);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        e is AppException ? e : UnexpectedException('Failed to delete photos: $e'),
      );
    }
  }

  /// Marks the item as listed for sale.
  /// Uses the centralized ItemStatusManager for the actual logic.
  Future<Result<Item>> markAsListed({
    required double listingPrice,
    required String listingPlatform,
    DateTime? listingDate,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _statusManager.markAsListed(
      itemId: arg,
      listingPrice: listingPrice,
      listingPlatform: listingPlatform,
      listingDate: listingDate,
    );
    
    // Update local state if successful
    if (result.isSuccess) {
      state = AsyncValue.data(result.value);
    } else {
      state = AsyncValue.error(
        result.error ?? UnexpectedException('Unknown error'), 
        StackTrace.current
      );
    }
    
    return result;
  }

  /// Marks the item as sold.
  /// Uses the centralized ItemStatusManager for the actual logic.
  Future<Result<Item>> markAsSold({
    required double soldPrice,
    required String sellingPlatform,
    DateTime? soldDate,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _statusManager.markAsSold(
      itemId: arg,
      soldPrice: soldPrice,
      sellingPlatform: sellingPlatform,
      soldDate: soldDate,
    );
    
    // Update local state if successful
    if (result.isSuccess) {
      state = AsyncValue.data(result.value);
    } else {
      state = AsyncValue.error(
        result.error ?? UnexpectedException('Unknown error'), 
        StackTrace.current
      );
    }
    
    return result;
  }

  /// Marks the item as back in stock (either from listed or sold status).
  /// Uses the centralized ItemStatusManager for the actual logic.
  Future<Result<Item>> markAsInStock() async {
    state = const AsyncValue.loading();
    
    final result = await _statusManager.markAsInStock(arg);
    
    // Update local state if successful
    if (result.isSuccess) {
      state = AsyncValue.data(result.value);
    } else {
      state = AsyncValue.error(
        result.error ?? UnexpectedException('Unknown error'), 
        StackTrace.current
      );
    }
    
    return result;
  }
}

/// Provider for the [ItemDetailNotifier].
///
/// Exposes the asynchronous state ([AsyncValue]) of a single item, accessed
/// by its ID.
/// Use `ref.watch(itemDetailProvider(itemId))` to get the state.
final itemDetailNotifierProvider =
    AsyncNotifierProvider.autoDispose.family<ItemDetailNotifier, Item?, String>(
  ItemDetailNotifier.new,
);

/// Provider that directly creates an ItemDetailNotifier via FutureProvider
/// for easier usage with direct provider reference patterns
final itemDetailProvider = FutureProvider.family<Item?, String>((ref, itemId) async {
  return ref.watch(itemDetailNotifierProvider(itemId).future);
});

/// Provides access to the storage repository
/*final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return ref.watch(storageRepositoryProvider);
});*/

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

// Create a mock notifier class that can be returned by itemDetailProviderMock
class MockItemDetailNotifier {
  final String itemId;
  
  MockItemDetailNotifier(this.itemId);
  
  // Status update methods for testing
  Future<void> markAsListed({
    required double listingPrice,
    required String listingPlatform,
    required DateTime listingDate,
  }) async {
    print('Item marked as listed: $itemId');
    print('  Price: \$${listingPrice.toStringAsFixed(2)}');
    print('  Platform: $listingPlatform');
    print('  Date: ${listingDate.toIso8601String()}');
  }
  
  Future<void> markAsSold({
    required double soldPrice,
    required String sellingPlatform,
    required DateTime soldDate,
  }) async {
    print('Item marked as sold: $itemId');
    print('  Price: \$${soldPrice.toStringAsFixed(2)}');
    print('  Platform: $sellingPlatform');
    print('  Date: ${soldDate.toIso8601String()}');
  }
  
  Future<void> markAsInStock() async {
    print('Item marked as in stock: $itemId');
  }
}

// Extension to provide .notifier on the FutureProvider
extension ItemDetailProviderExtension on FutureProvider<SimpleItem?> {
  // Get the mock notifier for testing
  MockItemDetailNotifier get notifier {
    // Extract itemId from family argument - works with pattern "provider-itemId"
    final itemId = this.name?.split('-')[1] ?? 
                  (this.name?.split('(').last.split(')').first ?? 'unknown');
    return MockItemDetailNotifier(itemId);
  }
}

/// Provider for accessing the mock provider with an extension
final itemDetailProviderMockWithNotifier = Provider.family<MockItemDetailNotifier, String>((ref, itemId) {
  return MockItemDetailNotifier(itemId);
});

// ItemDetailProvider with extension for real code access
extension ItemDetailProviderRealExtension on AutoDisposeFamilyAsyncNotifierProvider<ItemDetailNotifier, Item?, String> {
  ItemDetailNotifier provideNotifier(Ref ref, String arg) {
    return ref.read(itemDetailNotifierProvider(arg).notifier);
  }
} 