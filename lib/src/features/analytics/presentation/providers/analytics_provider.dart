import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/analytics/data/models/analytics_data.dart';
import 'package:pallet_pro_app/src/features/analytics/domain/time_period.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';

/// Provider family for analytics data with time period filtering
final analyticsProvider = FutureProvider.family<AnalyticsData, TimePeriod>(
  (ref, period) async {
    // Get date range from period
    final dateRange = period.toDateRange();
    
    final repository = ref.read(itemRepositoryProvider);
    
    // Fetch all analytics data in parallel for performance
    final results = await Future.wait([
      repository.getFinancialSummary(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
      repository.getBestPerformer(
        metric: 'revenue',
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
      repository.getBestPerformer(
        metric: 'profit',
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
      repository.getBestPerformer(
        metric: 'speed',
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
      repository.getPalletSourcePerformance(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
      repository.getSalesChannelPerformance(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
      repository.getBestDay(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
    ]);
    
    // Extract financial summary
    final financialResult = results[0];
    if (financialResult.isFailure) {
      throw financialResult.error!;
    }
    final financialData = financialResult.value as Map<String, dynamic>;
    
    // Extract best performers
    final bestSellingResult = results[1];
    final highestProfitResult = results[2];
    final fastestSellingResult = results[3];
    
    // Extract pallet source performance
    final sourcePerformanceResult = results[4];
    final sourcePerformance = sourcePerformanceResult.isSuccess
        ? (sourcePerformanceResult.value as List<Map<String, dynamic>>)
        : <Map<String, dynamic>>[];
    
    // Extract sales channel performance
    final channelPerformanceResult = results[5];
    final channelPerformanceMap = channelPerformanceResult.isSuccess
        ? (channelPerformanceResult.value as Map<String, Map<String, dynamic>>)
        : <String, Map<String, dynamic>>{};
    
    // Convert to ChannelPerformance models
    final channelPerformance = channelPerformanceMap.map(
      (key, value) => MapEntry(
        key,
        ChannelPerformance(
          channelName: key,
          itemsSold: value['items_sold'] as int,
          revenue: value['revenue'] as double,
          averageSellingPrice: value['avg_price'] as double,
          averageTimeToSell: value['avg_time_to_sell'] as double,
        ),
      ),
    );
    
    // Extract best day
    final bestDayResult = results[6];
    final bestDayData = bestDayResult.isSuccess
        ? (bestDayResult.value as Map<String, dynamic>?)
        : null;
    
    // Find most profitable source
    String? mostProfitableSource;
    double mostProfitableROI = 0.0;
    if (sourcePerformance.isNotEmpty) {
      final best = sourcePerformance.first;
      mostProfitableSource = best['source'] as String?;
      mostProfitableROI = (best['roi'] as num?)?.toDouble() ?? 0.0;
    }
    
    // Calculate tracking days
    final now = DateTime.now();
    final daysTracking = now.difference(dateRange.start).inDays;
    
    // Build analytics data
    return AnalyticsData(
      // Financial metrics from summary
      totalInventoryValue: (financialData['inventory_value'] as num).toDouble(),
      totalPotentialRevenue: (financialData['potential_revenue'] as num).toDouble(),
      totalActualRevenue: (financialData['actual_revenue'] as num).toDouble(),
      netProfit: (financialData['total_profit'] as num).toDouble(),
      totalCosts: (financialData['total_costs'] as num).toDouble(),
      
      // Item counts
      itemsInStock: financialData['in_stock_count'] as int,
      itemsListed: financialData['listed_count'] as int,
      itemsSold: financialData['sold_count'] as int,
      staleItemsCount: 0, // TODO: Implement stale detection
      totalItems: financialData['total_items'] as int,
      
      // Averages
      averageProfitMargin: (financialData['avg_margin'] as num).toDouble(),
      averageProfitPerItem: (financialData['avg_profit'] as num).toDouble(),
      averageTimeToSell: 0.0, // TODO: Calculate from channel data
      
      // Top performers
      bestSellingItem: bestSellingResult.isSuccess && bestSellingResult.value != null
          ? BestItem(
              id: bestSellingResult.value!.id,
              name: bestSellingResult.value!.name,
              value: bestSellingResult.value!.soldPrice ?? 0.0,
              metric: 'revenue',
              additionalInfo: 'Sold for \$${bestSellingResult.value!.soldPrice?.toStringAsFixed(2)}',
            )
          : null,
      highestProfitItem: highestProfitResult.isSuccess && highestProfitResult.value != null
          ? BestItem(
              id: highestProfitResult.value!.id,
              name: highestProfitResult.value!.name,
              value: (highestProfitResult.value!.soldPrice ?? 0.0) - 
                     (highestProfitResult.value!.purchasePrice ?? 0.0),
              metric: 'profit',
              additionalInfo: 'Profit: \$${((highestProfitResult.value!.soldPrice ?? 0.0) - (highestProfitResult.value!.purchasePrice ?? 0.0)).toStringAsFixed(2)}',
            )
          : null,
      fastestSellingItem: fastestSellingResult.isSuccess && fastestSellingResult.value != null
          ? BestItem(
              id: fastestSellingResult.value!.id,
              name: fastestSellingResult.value!.name,
              value: 0.0, // Speed value not directly used in display
              metric: 'speed',
              additionalInfo: 'Sold quickly',
            )
          : null,
      
      // Pallet insights
      mostProfitablePalletSource: mostProfitableSource,
      mostProfitablePalletROI: mostProfitableROI,
      
      // Sales channel performance
      channelPerformance: channelPerformance,
      
      // Fun facts
      bestDay: bestDayData != null 
          ? DateTime.parse(bestDayData['date'] as String)
          : null,
      bestDayProfit: bestDayData != null
          ? (bestDayData['profit'] as num).toDouble()
          : 0.0,
      totalItemsProcessed: financialData['total_items'] as int,
      daysTracking: daysTracking,
      totalPallets: 0, // TODO: Add pallet count
    );
  },
);

/// Provider for time series chart data
final timeSeriesProvider = FutureProvider.family<List<TimeSeriesData>, ({TimePeriod period, TimeResolution resolution})>(
  (ref, params) async {
    final dateRange = params.period.toDateRange();
  
    final repository = ref.read(itemRepositoryProvider);
    final result = await repository.getTimeSeries(
      resolution: params.resolution.sqlTruncation,
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
    
    if (result.isFailure) {
      throw result.error!;
    }
    
    final data = result.value as List<Map<String, dynamic>>;
    return data.map((item) => TimeSeriesData(
      date: DateTime.parse(item['date'] as String),
      revenue: (item['revenue'] as num).toDouble(),
      cost: (item['cost'] as num).toDouble(),
      profit: (item['profit'] as num).toDouble(),
      itemsSold: item['items_sold'] as int,
    )).toList();
  },
);

/// Provider for pallet source performance
final palletSourcePerformanceProvider = FutureProvider.family<List<PalletSourcePerformance>, TimePeriod>(
  (ref, period) async {
    final dateRange = period.toDateRange();
  
    final repository = ref.read(itemRepositoryProvider);
    final result = await repository.getPalletSourcePerformance(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
    
    if (result.isFailure) {
      throw result.error!;
    }
    
    final data = result.value as List<Map<String, dynamic>>;
    return data.map((item) => PalletSourcePerformance(
      source: item['source'] as String,
      totalPallets: item['total_pallets'] as int,
      totalCost: (item['total_cost'] as num).toDouble(),
      totalRevenue: (item['total_revenue'] as num).toDouble(),
      totalProfit: (item['profit'] as num).toDouble(),
      roi: (item['roi'] as num).toDouble(),
      averageProfitPerPallet: (item['profit'] as num).toDouble() / (item['total_pallets'] as int),
    )).toList();
  },
);

