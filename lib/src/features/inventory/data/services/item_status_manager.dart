import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';

/// Service class that centralizes all item status transition logic.
/// 
/// This class follows the DRY principle by providing a single implementation
/// of status transition methods that can be used by both ItemListNotifier and
/// ItemDetailNotifier.
class ItemStatusManager {
  final ItemRepository _itemRepository;
  
  ItemStatusManager(this._itemRepository);
  
  /// Marks an item as listed for sale.
  Future<Result<Item>> markAsListed({
    required String itemId,
    required double listingPrice,
    required String listingPlatform,
    DateTime? listingDate,
  }) async {
    // Get the current item
    final getResult = await _itemRepository.getItemById(itemId);
    
    return await getResult.when(
      success: (item) async {
        if (item == null) {
          return Result.failure(
            NotFoundException('Item with ID $itemId not found')
          );
        }
        
        // Update the item with the new status and listing details
        final updatedItem = item.copyWith(
          status: ItemStatus.listed,
          listingPrice: listingPrice,
          listingPlatform: listingPlatform,
          listingDate: listingDate ?? DateTime.now(),
        );
        
        // Save the updated item
        return await _itemRepository.updateItem(updatedItem);
      },
      failure: (exception) {
        return Result.failure(exception);
      },
    );
  }

  /// Marks an item as sold.
  Future<Result<Item>> markAsSold({
    required String itemId,
    required double soldPrice,
    required String sellingPlatform,
    DateTime? soldDate,
  }) async {
    // Get the current item
    final getResult = await _itemRepository.getItemById(itemId);
    
    return await getResult.when(
      success: (item) async {
        if (item == null) {
          return Result.failure(
            NotFoundException('Item with ID $itemId not found')
          );
        }
        
        // Update the item with the new status and selling details
        final updatedItem = item.copyWith(
          status: ItemStatus.sold,
          salePrice: soldPrice,
          soldPrice: soldPrice,
          sellingPlatform: sellingPlatform,
          soldDate: soldDate ?? DateTime.now(),
        );
        
        // Save the updated item
        return await _itemRepository.updateItem(updatedItem);
      },
      failure: (exception) {
        return Result.failure(exception);
      },
    );
  }
  
  /// Marks an item as back in stock (either from listed or sold status).
  Future<Result<Item>> markAsInStock(String itemId) async {
    // Get the current item
    final getResult = await _itemRepository.getItemById(itemId);
    
    return await getResult.when(
      success: (item) async {
        if (item == null) {
          return Result.failure(
            NotFoundException('Item with ID $itemId not found')
          );
        }
        
        // Update the item with new status
        final updatedItem = item.copyWith(
          status: ItemStatus.inStock,
          // Clear listing/selling info if returning to stock
          listingPrice: null,
          listingPlatform: null,
          listingDate: null,
          // Note: We don't clear sale history if it was previously sold
          // as that data may be valuable for reporting
        );
        
        // Save the updated item
        return await _itemRepository.updateItem(updatedItem);
      },
      failure: (exception) {
        return Result.failure(exception);
      },
    );
  }
} 