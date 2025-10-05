import 'package:intl/intl.dart';
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

      // Find items that are NOT sold and have been sitting for too long
      // This includes: in_stock, listed, and for_sale
      // Uses created_at since acquired_date was removed from schema
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .neq('status', _statusToDbString(ItemStatus.sold)) // Exclude sold items
          .lt('created_at', thresholdDate.toIso8601String())
          .order('created_at', ascending: true);

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
  
  // ============================================================================
  // ANALYTICS METHODS - Stub Implementations
  // ============================================================================
  
  @override
  Future<Result<Map<String, dynamic>>> getFinancialSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // Build optimized single-query aggregation
      // This gets all financial metrics in one database call
      var query = _supabaseClient
          .from(_tableName)
          .select()
          .eq('user_id', userId);
      
      // Apply date filters if provided
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      
      final response = await query;
      final items = response as List<dynamic>;
      
      // Aggregate data client-side (more flexible than RPC for free tier)
      double inventoryValue = 0.0;
      double potentialRevenue = 0.0;
      double actualRevenue = 0.0;
      double totalCosts = 0.0;
      int inStockCount = 0;
      int listedCount = 0;
      int soldCount = 0;
      double totalProfit = 0.0;
      
      for (final item in items) {
        final status = item['status'] as String?;
        final purchasePrice = (item['purchase_price'] as num?)?.toDouble() ?? 0.0;
        final listingPrice = (item['listing_price'] as num?)?.toDouble() ?? 0.0;
        final soldPrice = (item['sold_price'] as num?)?.toDouble() ?? 0.0;
        
        // Count by status
        switch (status) {
          case 'in_stock':
            inStockCount++;
            inventoryValue += purchasePrice;
            totalCosts += purchasePrice;
            break;
          case 'listed':
            listedCount++;
            potentialRevenue += listingPrice;
            totalCosts += purchasePrice;
            break;
          case 'sold':
            soldCount++;
            actualRevenue += soldPrice;
            totalCosts += purchasePrice;
            totalProfit += (soldPrice - purchasePrice);
            break;
        }
      }
      
      // Calculate averages
      final avgProfit = soldCount > 0 ? totalProfit / soldCount : 0.0;
      final avgMargin = actualRevenue > 0 
          ? (totalProfit / actualRevenue) * 100 
          : 0.0;
      
      return Result.success({
        'inventory_value': inventoryValue,
        'potential_revenue': potentialRevenue,
        'actual_revenue': actualRevenue,
        'total_profit': totalProfit,
        'total_costs': totalCosts,
        'in_stock_count': inStockCount,
        'listed_count': listedCount,
        'sold_count': soldCount,
        'avg_profit': avgProfit,
        'avg_margin': avgMargin,
        'total_items': items.length,
      });
    } on AuthException catch (e) {
      return Result.failure(e);
    } on PostgrestException catch (e) {
      return Result.failure(
        DatabaseException.fetchFailed('financial summary', e.message),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedException('Error fetching financial summary', e),
      );
    }
  }
  
  @override
  Future<Result<List<Map<String, dynamic>>>> getTimeSeries({
    required String resolution,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // Fetch sold items only for time series
      var query = _supabaseClient
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('status', 'sold')
          .not('sold_date', 'is', null);
      
      if (startDate != null) {
        query = query.gte('sold_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('sold_date', endDate.toIso8601String());
      }
      
      final items = await query.order('sold_date', ascending: true) as List<dynamic>;
      
      // Group by date resolution client-side
      final Map<String, Map<String, dynamic>> grouped = {};
      
      for (final item in items) {
        final soldDateStr = item['sold_date'] as String?;
        if (soldDateStr == null) continue;
        
        final soldDate = DateTime.parse(soldDateStr);
        final purchasePrice = (item['purchase_price'] as num?)?.toDouble() ?? 0.0;
        final soldPrice = (item['sold_price'] as num?)?.toDouble() ?? 0.0;
        final profit = soldPrice - purchasePrice;
        
        // Determine date key based on resolution
        String dateKey;
        switch (resolution) {
          case 'day':
            dateKey = '${soldDate.year}-${soldDate.month.toString().padLeft(2, '0')}-${soldDate.day.toString().padLeft(2, '0')}';
            break;
          case 'week':
            // ISO week start (Monday)
            final weekStart = soldDate.subtract(Duration(days: soldDate.weekday - 1));
            dateKey = '${weekStart.year}-W${_getWeekNumber(weekStart)}';
            break;
          case 'month':
            dateKey = '${soldDate.year}-${soldDate.month.toString().padLeft(2, '0')}';
            break;
          case 'year':
            dateKey = '${soldDate.year}';
            break;
          default:
            dateKey = '${soldDate.year}-${soldDate.month.toString().padLeft(2, '0')}-${soldDate.day.toString().padLeft(2, '0')}';
        }
        
        // Aggregate data for this date
        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = {
            'date': dateKey,
            'revenue': 0.0,
            'cost': 0.0,
            'profit': 0.0,
            'items_sold': 0,
          };
        }
        
        grouped[dateKey]!['revenue'] = (grouped[dateKey]!['revenue'] as double) + soldPrice;
        grouped[dateKey]!['cost'] = (grouped[dateKey]!['cost'] as double) + purchasePrice;
        grouped[dateKey]!['profit'] = (grouped[dateKey]!['profit'] as double) + profit;
        grouped[dateKey]!['items_sold'] = (grouped[dateKey]!['items_sold'] as int) + 1;
      }
      
      // Convert to sorted list
      final result = grouped.values.toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
      
      return Result.success(result);
    } on AuthException catch (e) {
      return Result.failure(e);
    } on PostgrestException catch (e) {
      return Result.failure(
        DatabaseException.fetchFailed('time series', e.message),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedException('Error fetching time series', e),
      );
    }
  }
  
  // Helper to get ISO week number
  int _getWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
  
  @override
  Future<Result<List<Map<String, dynamic>>>> getPalletSourcePerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // Fetch pallets with their source
      var palletQuery = _supabaseClient
          .from(_palletTableName)
          .select()
          .eq('user_id', userId)
          .not('source', 'is', null);
      
      if (startDate != null) {
        palletQuery = palletQuery.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        palletQuery = palletQuery.lte('created_at', endDate.toIso8601String());
      }
      
      final palletsResponse = await palletQuery;
      final pallets = palletsResponse as List<dynamic>;
      
      // Fetch sold items for these pallets
      final palletIds = pallets.map((p) => p['id'] as String).toList();
      if (palletIds.isEmpty) {
        return const Result.success([]);
      }
      
      final itemsResponse = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .inFilter('pallet_id', palletIds);
      
      final items = itemsResponse as List<dynamic>;
      
      // Group by source
      final Map<String, Map<String, dynamic>> bySource = {};
      
      for (final pallet in pallets) {
        final source = pallet['source'] as String?;
        if (source == null || source.isEmpty) continue;
        
        if (!bySource.containsKey(source)) {
          bySource[source] = {
            'source': source,
            'total_pallets': 0,
            'total_cost': 0.0,
            'total_revenue': 0.0,
            'profit': 0.0,
            'roi': 0.0,
          };
        }
        
        bySource[source]!['total_pallets'] = (bySource[source]!['total_pallets'] as int) + 1;
        bySource[source]!['total_cost'] = (bySource[source]!['total_cost'] as double) + 
            ((pallet['purchase_cost'] as num?)?.toDouble() ?? 0.0);
      }
      
      // Add item revenue
      for (final item in items) {
        final palletId = item['pallet_id'] as String?;
        if (palletId == null) continue;
        
        final pallet = pallets.firstWhere(
          (p) => p['id'] == palletId,
          orElse: () => <String, dynamic>{},
        );
        final source = pallet['source'] as String?;
        if (source == null || !bySource.containsKey(source)) continue;
        
        final soldPrice = (item['sold_price'] as num?)?.toDouble() ?? 0.0;
        if (soldPrice > 0) {
          bySource[source]!['total_revenue'] = (bySource[source]!['total_revenue'] as double) + soldPrice;
        }
      }
      
      // Calculate profit and ROI
      for (final entry in bySource.values) {
        final cost = entry['total_cost'] as double;
        final revenue = entry['total_revenue'] as double;
        entry['profit'] = revenue - cost;
        entry['roi'] = cost > 0 ? ((revenue - cost) / cost) * 100 : 0.0;
      }
      
      // Sort by ROI descending
      final result = bySource.values.toList()
        ..sort((a, b) => (b['roi'] as double).compareTo(a['roi'] as double));
      
      return Result.success(result);
    } on AuthException catch (e) {
      return Result.failure(e);
    } on PostgrestException catch (e) {
      return Result.failure(
        DatabaseException.fetchFailed('pallet source performance', e.message),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedException('Error fetching pallet source performance', e),
      );
    }
  }
  
  @override
  Future<Result<Map<String, Map<String, dynamic>>>> getSalesChannelPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // Fetch sold items with sales channel
      var query = _supabaseClient
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('status', 'sold')
          .not('sales_channel', 'is', null);
      
      if (startDate != null) {
        query = query.gte('sold_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('sold_date', endDate.toIso8601String());
      }
      
      final response = await query;
      final items = response as List<dynamic>;
      
      // Group by channel
      final Map<String, Map<String, dynamic>> byChannel = {};
      
      for (final item in items) {
        final channel = item['sales_channel'] as String? ?? 'Unknown';
        final soldPrice = (item['sold_price'] as num?)?.toDouble() ?? 0.0;
        final soldDateStr = item['sold_date'] as String?;
        final createdDateStr = item['created_at'] as String?;
        
        if (!byChannel.containsKey(channel)) {
          byChannel[channel] = {
            'items_sold': 0,
            'revenue': 0.0,
            'avg_price': 0.0,
            'avg_time_to_sell': 0.0,
            'total_days': 0.0,
          };
        }
        
        byChannel[channel]!['items_sold'] = (byChannel[channel]!['items_sold'] as int) + 1;
        byChannel[channel]!['revenue'] = (byChannel[channel]!['revenue'] as double) + soldPrice;
        
        // Calculate time to sell
        if (soldDateStr != null && createdDateStr != null) {
          final soldDate = DateTime.parse(soldDateStr);
          final createdDate = DateTime.parse(createdDateStr);
          final daysToSell = soldDate.difference(createdDate).inDays.toDouble();
          byChannel[channel]!['total_days'] = (byChannel[channel]!['total_days'] as double) + daysToSell;
        }
      }
      
      // Calculate averages
      for (final entry in byChannel.values) {
        final itemCount = entry['items_sold'] as int;
        if (itemCount > 0) {
          entry['avg_price'] = (entry['revenue'] as double) / itemCount;
          entry['avg_time_to_sell'] = (entry['total_days'] as double) / itemCount;
        }
        entry.remove('total_days'); // Remove helper field
      }
      
      return Result.success(byChannel);
    } on AuthException catch (e) {
      return Result.failure(e);
    } on PostgrestException catch (e) {
      return Result.failure(
        DatabaseException.fetchFailed('sales channel performance', e.message),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedException('Error fetching sales channel performance', e),
      );
    }
  }
  
  @override
  Future<Result<Item?>> getBestPerformer({
    required String metric,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // Fetch sold items
      var query = _supabaseClient
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('status', 'sold');
      
      if (startDate != null) {
        query = query.gte('sold_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('sold_date', endDate.toIso8601String());
      }
      
      final response = await query;
      final items = response as List<dynamic>;
      
      if (items.isEmpty) {
        return const Result.success(null);
      }
      
      // Find best item based on metric
      Map<String, dynamic>? bestItem;
      double bestValue = double.negativeInfinity;
      
      for (final item in items) {
        final soldPrice = (item['sold_price'] as num?)?.toDouble() ?? 0.0;
        final purchasePrice = (item['purchase_price'] as num?)?.toDouble() ?? 0.0;
        final profit = soldPrice - purchasePrice;
        final margin = soldPrice > 0 ? (profit / soldPrice) * 100 : 0.0;
        
        double value;
        switch (metric) {
          case 'revenue':
            value = soldPrice;
            break;
          case 'profit':
            value = profit;
            break;
          case 'margin':
            value = margin;
            break;
          case 'speed':
            // Calculate days to sell (lower is better, so negate)
            final soldDateStr = item['sold_date'] as String?;
            final createdDateStr = item['created_at'] as String?;
            if (soldDateStr != null && createdDateStr != null) {
              final soldDate = DateTime.parse(soldDateStr);
              final createdDate = DateTime.parse(createdDateStr);
              final daysToSell = soldDate.difference(createdDate).inDays.toDouble();
              value = -daysToSell; // Negate so fastest = highest value
            } else {
              continue;
            }
            break;
          default:
            return Result.failure(
              ValidationException('Invalid metric: $metric. Use revenue, profit, margin, or speed'),
            );
        }
        
        if (value > bestValue) {
          bestValue = value;
          bestItem = item as Map<String, dynamic>;
        }
      }
      
      if (bestItem == null) {
        return const Result.success(null);
      }
      
      // Convert to Item model
      final fixedItem = _fixItemFieldNames(bestItem!);
      final itemModel = Item.fromJson(fixedItem);
      
      return Result.success(itemModel);
    } on AuthException catch (e) {
      return Result.failure(e);
    } on PostgrestException catch (e) {
      return Result.failure(
        DatabaseException.fetchFailed('best performer', e.message),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedException('Error fetching best performer', e),
      );
    }
  }
  
  @override
  Future<Result<Map<String, dynamic>?>> getBestDay({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // Fetch sold items
      var query = _supabaseClient
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('status', 'sold')
          .not('sold_date', 'is', null);
      
      if (startDate != null) {
        query = query.gte('sold_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('sold_date', endDate.toIso8601String());
      }
      
      final response = await query;
      final items = response as List<dynamic>;
      
      if (items.isEmpty) {
        return const Result.success(null);
      }
      
      // Group by day
      final Map<String, Map<String, dynamic>> byDay = {};
      
      for (final item in items) {
        final soldDateStr = item['sold_date'] as String?;
        if (soldDateStr == null) continue;
        
        final soldDate = DateTime.parse(soldDateStr);
        final dateKey = '${soldDate.year}-${soldDate.month.toString().padLeft(2, '0')}-${soldDate.day.toString().padLeft(2, '0')}';
        
        final soldPrice = (item['sold_price'] as num?)?.toDouble() ?? 0.0;
        final purchasePrice = (item['purchase_price'] as num?)?.toDouble() ?? 0.0;
        final profit = soldPrice - purchasePrice;
        
        if (!byDay.containsKey(dateKey)) {
          byDay[dateKey] = {
            'date': dateKey,
            'profit': 0.0,
            'items_sold': 0,
            'revenue': 0.0,
          };
        }
        
        byDay[dateKey]!['profit'] = (byDay[dateKey]!['profit'] as double) + profit;
        byDay[dateKey]!['revenue'] = (byDay[dateKey]!['revenue'] as double) + soldPrice;
        byDay[dateKey]!['items_sold'] = (byDay[dateKey]!['items_sold'] as int) + 1;
      }
      
      // Find best day by profit
      Map<String, dynamic>? bestDay;
      double bestProfit = double.negativeInfinity;
      
      for (final day in byDay.values) {
        final profit = day['profit'] as double;
        if (profit > bestProfit) {
          bestProfit = profit;
          bestDay = day;
        }
      }
      
      return Result.success(bestDay);
    } on AuthException catch (e) {
      return Result.failure(e);
    } on PostgrestException catch (e) {
      return Result.failure(
        DatabaseException.fetchFailed('best day', e.message),
      );
    } catch (e) {
      return Result.failure(
        UnexpectedException('Error fetching best day', e),
      );
    }
  }
} 