import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
// Import custom exception/result types if defined

/// Abstract interface for managing Item data.
abstract class ItemRepository {
  /// Creates a new item.
  Future<Result<Item>> createItem(Item item);

  /// Fetches an item by its ID.
  Future<Result<Item?>> getItemById(String id);

  /// Fetches all items, potentially filtered.
  Future<Result<List<Item>>> getAllItems({
    ItemStatus? statusFilter,
    String? storageLocationFilter,
    String? salesChannelFilter,
    String? palletSourceFilter, // Filter by source field in the related pallet
  });

  /// Fetches all items belonging to a specific pallet.
  Future<Result<List<Item>>> getItemsByPallet(String palletId);

  /// Fetches items that are not associated with any pallet.
  Future<Result<List<Item>>> getItemsWithoutPallet();

  /// Fetches items based on their status.
  /// Deprecated: Use getAllItems with statusFilter instead.
  @Deprecated('Use getAllItems with statusFilter instead')
  Future<Result<List<Item>>> getItemsByStatus(ItemStatus status);

  /// Fetches items that are considered 'stale' based on criteria (e.g., acquired date).
  Future<Result<List<Item>>> getStaleItems({required Duration staleThreshold});

  /// Updates an existing item.
  Future<Result<Item>> updateItem(Item item);

  /// Deletes an item by its ID.
  Future<Result<void>> deleteItem(String id);

  /// Updates purchase prices for all items in a pallet based on the allocation method
  Future<Result<void>> batchUpdateItemPurchasePrices({
    required String palletId, 
    required double palletCost, 
    required String allocationMethod // 'even', 'proportional', or 'manual'
  });

  // Add other specific methods like search, batch updates, etc.
  // Future<double> calculateItemProfit(String itemId); // Example for business logic
  
  // ============================================================================
  // ANALYTICS METHODS
  // ============================================================================
  
  /// Gets aggregated financial summary for analytics dashboard
  /// Returns metrics like total inventory value, revenue, profit, etc.
  /// 
  /// [startDate] and [endDate] filter by created_at timestamp
  /// Returns Map with keys: inventory_value, potential_revenue, actual_revenue, 
  /// total_profit, in_stock_count, listed_count, sold_count, avg_profit, avg_margin
  Future<Result<Map<String, dynamic>>> getFinancialSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Gets time series data for charts (revenue, cost, profit over time)
  /// 
  /// [resolution] determines grouping: 'day', 'week', 'month', 'year'
  /// Returns list of maps with keys: date, revenue, cost, profit, items_sold
  Future<Result<List<Map<String, dynamic>>>> getTimeSeries({
    required String resolution, // 'day', 'week', 'month', 'year'
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Gets performance metrics by pallet source (Amazon, Walmart, etc.)
  /// 
  /// Returns list of maps with keys: source, total_pallets, total_cost, 
  /// total_revenue, profit, roi
  Future<Result<List<Map<String, dynamic>>>> getPalletSourcePerformance({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Gets performance metrics by sales channel (Marketplace, Facebook Group, etc.)
  /// 
  /// Returns map keyed by channel name with values: items_sold, revenue, 
  /// avg_price, avg_time_to_sell
  Future<Result<Map<String, Map<String, dynamic>>>> getSalesChannelPerformance({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Gets the best performing item for a given metric
  /// 
  /// [metric] can be: 'revenue', 'profit', 'speed', 'margin'
  /// Returns single item or null if no sold items exist
  Future<Result<Item?>> getBestPerformer({
    required String metric,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Gets the best day for sales
  /// 
  /// Returns map with keys: date, profit, items_sold, revenue
  Future<Result<Map<String, dynamic>?>> getBestDay({
    DateTime? startDate,
    DateTime? endDate,
  });
} 