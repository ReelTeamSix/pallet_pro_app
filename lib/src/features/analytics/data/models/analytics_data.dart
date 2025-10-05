import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_data.freezed.dart';
part 'analytics_data.g.dart';

/// Aggregated analytics data for dashboard and reports
@freezed
class AnalyticsData with _$AnalyticsData {
  const factory AnalyticsData({
    // Financial Metrics
    required double totalInventoryValue, // Sum of purchase prices (in stock items)
    required double totalPotentialRevenue, // Sum of listing prices
    required double totalActualRevenue, // Sum of selling prices
    required double netProfit, // actualRevenue - total costs
    required double totalCosts, // Sum of all purchase prices + expenses

    // Item Counts by Status
    required int itemsInStock,
    required int itemsListed,
    required int itemsSold,
    required int staleItemsCount,
    required int totalItems,

    // Averages
    required double averageProfitMargin, // Percentage
    required double averageProfitPerItem, // Dollar amount per sold item
    required double averageTimeToSell, // Days (for sold items)

    // Top Performers
    BestItem? bestSellingItem, // Highest revenue
    BestItem? highestProfitItem, // Best profit margin
    BestItem? fastestSellingItem, // Quickest time to sell

    // Pallet Insights
    String? mostProfitablePalletSource,
    @Default(0.0) double mostProfitablePalletROI,
    
    // Sales Channel Performance
    Map<String, ChannelPerformance>? channelPerformance,

    // Fun Facts
    DateTime? bestDay,
    @Default(0.0) double bestDayProfit,
    @Default(0) int totalItemsProcessed,
    @Default(0) int daysTracking,
    @Default(0) int totalPallets,
  }) = _AnalyticsData;

  factory AnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataFromJson(json);

  /// Empty analytics data for initial state
  factory AnalyticsData.empty() => const AnalyticsData(
        totalInventoryValue: 0.0,
        totalPotentialRevenue: 0.0,
        totalActualRevenue: 0.0,
        netProfit: 0.0,
        totalCosts: 0.0,
        itemsInStock: 0,
        itemsListed: 0,
        itemsSold: 0,
        staleItemsCount: 0,
        totalItems: 0,
        averageProfitMargin: 0.0,
        averageProfitPerItem: 0.0,
        averageTimeToSell: 0.0,
      );
}

/// Represents top performing items in various categories
@freezed
class BestItem with _$BestItem {
  const factory BestItem({
    required String id,
    required String name,
    required double value,
    required String metric, // 'revenue', 'profit', 'speed', 'margin'
    String? additionalInfo, // e.g., "Sold in 3 days"
  }) = _BestItem;

  factory BestItem.fromJson(Map<String, dynamic> json) =>
      _$BestItemFromJson(json);
}

/// Time series data point for charts
@freezed
class TimeSeriesData with _$TimeSeriesData {
  const factory TimeSeriesData({
    required DateTime date,
    required double revenue,
    required double cost,
    required double profit,
    @Default(0) int itemsSold,
  }) = _TimeSeriesData;

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesDataFromJson(json);
}

/// Sales channel performance metrics
@freezed
class ChannelPerformance with _$ChannelPerformance {
  const factory ChannelPerformance({
    required String channelName,
    required int itemsSold,
    required double totalRevenue,
    required double averageSellingPrice,
    required double averageTimeToSell, // days
    @Default(0.0) double conversionRate, // listed to sold ratio
  }) = _ChannelPerformance;

  factory ChannelPerformance.fromJson(Map<String, dynamic> json) =>
      _$ChannelPerformanceFromJson(json);
}

/// Pallet source performance for identifying profitable suppliers
@freezed
class PalletSourcePerformance with _$PalletSourcePerformance {
  const factory PalletSourcePerformance({
    required String source, // e.g., "Amazon", "Walmart"
    required int totalPallets,
    required double totalCost,
    required double totalRevenue,
    required double totalProfit,
    required double roi, // Return on investment percentage
    required double averageProfitPerPallet,
  }) = _PalletSourcePerformance;

  factory PalletSourcePerformance.fromJson(Map<String, dynamic> json) =>
      _$PalletSourcePerformanceFromJson(json);
}

