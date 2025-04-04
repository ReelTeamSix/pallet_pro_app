import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart'; // Import Pallet for join
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
// TODO: Import custom exceptions

// Special UUID for items without a pallet
const String NO_PALLET_UUID = '00000000-0000-0000-0000-000000000000';

class SupabaseItemRepository implements ItemRepository {
  final SupabaseClient _supabaseClient;
  final String _tableName = 'items';
  final String _palletTableName = 'pallets'; // Need pallet table name for join

  SupabaseItemRepository(this._supabaseClient);

  String _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      // TODO: Replace with concrete AuthException (e.g., AuthException.sessionExpired())
      throw AuthException.sessionExpired();
    }
    return user.id;
  }

  // Helper to convert ItemStatus enum to DB string based on @JsonValue
  String _statusToDbString(ItemStatus status) {
    // Use a switch statement based on the enum values and their expected @JsonValue
    switch (status) {
      case ItemStatus.inStock: return 'in_stock';
      case ItemStatus.forSale: return 'for_sale';
      case ItemStatus.listed: return 'listed';
      case ItemStatus.sold: return 'sold';
    }
  }

  // Helper method to fix JSON field names for Item deserialization
  Map<String, dynamic> _fixItemFieldNames(Map<String, dynamic> json) {
    // Handle the spelling discrepancy between database schema and model
    if (json.containsKey('aquired_date') && !json.containsKey('acquired_date')) {
      final aquiredDate = json.remove('aquired_date');
      if (aquiredDate != null) {
        json['acquired_date'] = aquiredDate;
      }
    }
    
    // Map selling_price (DB) to sale_price (model)
    if (json.containsKey('selling_price') && !json.containsKey('sale_price')) {
      final sellingPrice = json.remove('selling_price');
      if (sellingPrice != null) {
        json['sale_price'] = sellingPrice;
      }
    }
    
    // Add missing fields that are in the model but not in the database
    final fieldsToCheck = [
      'allocated_cost',
      'sku',
      'sold_date',
      'description',
      'storage_location',
      'sales_channel'
    ];
    
    for (final field in fieldsToCheck) {
      if (!json.containsKey(field)) {
        json[field] = null;
      }
    }
    
    return json;
  }

  @override
  Future<Result<Item>> createItem(Item item) async {
    try {
      final userId = _getCurrentUserId();
      final itemData = item.toJson();
      itemData['user_id'] = userId;
      itemData.remove('id');
      itemData['created_at'] ??= DateTime.now().toIso8601String();
      itemData['updated_at'] ??= DateTime.now().toIso8601String();
      
      // Ensure purchase_price is not null to satisfy DB constraint
      if (itemData['purchase_price'] == null) {
        itemData['purchase_price'] = 0.0; // Default value to satisfy DB constraint
      }
      
      // Ensure selling_price is not null to satisfy DB constraint
      // Map from salePrice (model) to selling_price (DB)
      itemData['selling_price'] = itemData['sale_price'] ?? 0.0;
      itemData.remove('sale_price');

      // Fix for database schema spelling issue - rename acquired_date to aquired_date
      if (itemData.containsKey('acquired_date')) {
        final acquiredDate = itemData.remove('acquired_date');
        if (acquiredDate != null) {
          itemData['aquired_date'] = acquiredDate;
        }
      }
      
      // Remove fields that don't exist in the database schema
      final fieldsToRemove = [
        'allocated_cost',
        'sku',
        'sold_date'
      ];
      
      for (final field in fieldsToRemove) {
        itemData.remove(field);
      }

      final response = await _supabaseClient
          .from(_tableName)
          .insert(itemData)
          .select()
          .single();

      return Result.success(Item.fromJson(_fixItemFieldNames(response)));
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.creationFailed('item', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error creating item', e));
    }
  }

  @override
  Future<Result<Item?>> getItemById(String id) async {
    try {
      print('Getting item with ID: $id'); // Debug logging
      final userId = _getCurrentUserId(); // Ensure user access
      print('Current user ID: $userId'); // Debug logging
      
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('user_id', userId) // RLS should handle this, but explicit check is safer
          .maybeSingle();
          
      print('Query response: $response'); // Debug logging
      
      final item = response == null ? null : Item.fromJson(_fixItemFieldNames(response));
      if (item == null) {
        print('Item not found with ID: $id'); // Debug logging
        return Result.failure(NotFoundException('Item not found with ID: $id'));
      }
      return Result.success(item);
    } on PostgrestException catch (e) {
       // TODO: Map to specific DatabaseException
      print('Database error fetching item $id: ${e.message}'); // Debug logging
      return Result.failure(DatabaseException.fetchFailed('item', e.message));
    } catch (e) {
      print('Unexpected error fetching item $id: $e'); // Debug logging
      return Result.failure(UnexpectedException('Unexpected error fetching item', e));
    }
  }

  @override
  Future<Result<List<Item>>> getAllItems({
    ItemStatus? statusFilter,
    String? storageLocationFilter,
    String? salesChannelFilter,
    String? palletSourceFilter,
  }) async {
    try {
      final userId = _getCurrentUserId();
      // Select items and joined pallet source
      var query = _supabaseClient
          .from(_tableName)
          .select('*, $_palletTableName(source)') // Select all item fields and pallet source
          .eq('user_id', userId); // Filter by user ID

      // Apply filters
      if (statusFilter != null) {
        query = query.eq('status', _statusToDbString(statusFilter));
      }
      if (storageLocationFilter != null && storageLocationFilter.isNotEmpty) {
        query = query.ilike('storage_location', '%$storageLocationFilter%');
      }
      if (salesChannelFilter != null && salesChannelFilter.isNotEmpty) {
        query = query.ilike('sales_channel', '%$salesChannelFilter%');
      }
      if (palletSourceFilter != null && palletSourceFilter.isNotEmpty) {
        // Filter on the joined pallet table's source column
        query = query.ilike('$_palletTableName.source', '%$palletSourceFilter%');
      }

      final response = await query.order('created_at', ascending: false);

      // The response includes nested pallet data. We need to parse Item correctly.
      final items = response.map((json) => Item.fromJson(_fixItemFieldNames(json))).toList();
      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('all items with filters', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching filtered items', e));
    }
  }

  @override
  Future<Result<List<Item>>> getItemsByPallet(String palletId) async {
    try {
      final userId = _getCurrentUserId();
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('pallet_id', palletId)
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final items = response.map((json) => Item.fromJson(_fixItemFieldNames(json))).toList();
      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('items for pallet $palletId', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching items by pallet', e));
    }
  }

   @override
   @Deprecated('Use getAllItems with statusFilter instead')
  Future<Result<List<Item>>> getItemsByStatus(ItemStatus status) async {
    // Delegate to the new method for backward compatibility if needed,
    // or simply call it directly in the calling code.
    return getAllItems(statusFilter: status);
  }

  @override
  Future<Result<List<Item>>> getStaleItems({required Duration staleThreshold}) async {
    try {
      final userId = _getCurrentUserId();
      final thresholdDate = DateTime.now().subtract(staleThreshold);

      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('status', _statusToDbString(ItemStatus.forSale))
          .lt('aquired_date', thresholdDate.toIso8601String())
          .order('aquired_date', ascending: true);

      final items = response.map((json) => Item.fromJson(_fixItemFieldNames(json))).toList();
      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('stale items', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching stale items', e));
    }
  }


  @override
  Future<Result<Item>> updateItem(Item item) async {
    try {
       final userId = _getCurrentUserId();
       final itemData = item.toJson();
       itemData.remove('user_id');
       itemData.remove('id');
       itemData['updated_at'] = DateTime.now().toIso8601String();
       
       // Ensure purchase_price is not null to satisfy DB constraint
       if (itemData['purchase_price'] == null) {
         itemData['purchase_price'] = 0.0; // Default value to satisfy DB constraint
       }
       
       // Ensure selling_price is not null to satisfy DB constraint
       // Map from salePrice (model) to selling_price (DB)
       itemData['selling_price'] = itemData['sale_price'] ?? 0.0;
       itemData.remove('sale_price');

       // Fix for database schema spelling issue - rename acquired_date to aquired_date
       if (itemData.containsKey('acquired_date')) {
         final acquiredDate = itemData.remove('acquired_date');
         if (acquiredDate != null) {
           itemData['aquired_date'] = acquiredDate;
         }
       }
       
       // Remove fields that don't exist in the database schema
       final fieldsToRemove = [
         'allocated_cost',
         'sku',
         'sold_date'
       ];
       
       for (final field in fieldsToRemove) {
         itemData.remove(field);
       }

       final response = await _supabaseClient
          .from(_tableName)
          .update(itemData)
          .eq('id', item.id)
          .eq('user_id', userId)
          .select()
          .single();

      return Result.success(Item.fromJson(_fixItemFieldNames(response)));
    } on PostgrestException catch (e) {
       return Result.failure(DatabaseException.updateFailed('item ${item.id}', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error updating item', e));
    }
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    try {
      final userId = _getCurrentUserId();
      await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      // TODO: Cascade delete related data (photos, tags, expenses) if not handled by DB constraints/triggers
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.deletionFailed('item $id', e.message));
    } catch (e) {
       return Result.failure(UnexpectedException('Unexpected error deleting item', e));
    }
  }

  @override
  Future<Result<List<Item>>> getItemsWithoutPallet() async {
    try {
      final userId = _getCurrentUserId();
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('pallet_id', NO_PALLET_UUID)
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final items = response.map((json) => Item.fromJson(_fixItemFieldNames(json))).toList();
      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('items without pallet', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching items without pallet', e));
    }
  }

  /// Updates purchase prices for all items in a pallet based on the allocation method
  @override
  Future<Result<void>> batchUpdateItemPurchasePrices({
    required String palletId, 
    required double palletCost, 
    required String allocationMethod // 'even', 'proportional', or 'manual'
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // First, get all items for this pallet
      final itemsResult = await getItemsByPallet(palletId);
      if (itemsResult.isFailure) {
        return Result.failure(itemsResult.error!);
      }
      
      final items = itemsResult.value!;
      if (items.isEmpty) {
        return const Result.success(null); // No items to update
      }
      
      // Calculate purchase prices based on allocation method
      final updates = <Map<String, dynamic>>[];
      
      switch (allocationMethod) {
        case 'even':
          // Distribute cost evenly across all items
          final costPerItem = palletCost / items.length;
          for (final item in items) {
            updates.add({
              'id': item.id,
              'purchase_price': costPerItem,
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
          break;
          
        case 'proportional':
          // Allocate cost based on selling price (or listing price)
          // First calculate the total value of all items
          double totalValue = 0;
          for (final item in items) {
            // Use listing_price if available, otherwise sale_price, or default to 1.0
            final itemValue = item.listingPrice ?? item.salePrice ?? 1.0;
            totalValue += itemValue;
          }
          
          // Now allocate cost proportionally
          for (final item in items) {
            final itemValue = item.listingPrice ?? item.salePrice ?? 1.0;
            final proportion = itemValue / totalValue;
            final allocatedCost = palletCost * proportion;
            
            updates.add({
              'id': item.id,
              'purchase_price': allocatedCost,
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
          break;
          
        case 'manual':
          // For manual allocation, we don't automatically update prices
          // This would be handled through the UI
          return const Result.success(null);
          
        default:
          // Default to even distribution if allocation method is not recognized
          final costPerItem = palletCost / items.length;
          for (final item in items) {
            updates.add({
              'id': item.id,
              'purchase_price': costPerItem,
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
      }
      
      // Perform batch update if there are items to update
      if (updates.isNotEmpty) {
        await _supabaseClient
            .from(_tableName)
            .upsert(updates)
            .eq('user_id', userId);
      }
      
      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.updateFailed('batch item purchase prices', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error updating batch item purchase prices', e));
    }
  }

  // Implementation for calculateItemProfit would likely involve fetching the item,
  // associated expenses, and potentially calling a DB function or doing calculation here.
} 