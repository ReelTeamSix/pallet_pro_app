// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyticsData _$AnalyticsDataFromJson(
  Map<String, dynamic> json,
) => _AnalyticsData(
  totalInventoryValue: (json['totalInventoryValue'] as num).toDouble(),
  totalPotentialRevenue: (json['totalPotentialRevenue'] as num).toDouble(),
  totalActualRevenue: (json['totalActualRevenue'] as num).toDouble(),
  netProfit: (json['netProfit'] as num).toDouble(),
  totalCosts: (json['totalCosts'] as num).toDouble(),
  itemsInStock: (json['itemsInStock'] as num).toInt(),
  itemsListed: (json['itemsListed'] as num).toInt(),
  itemsSold: (json['itemsSold'] as num).toInt(),
  staleItemsCount: (json['staleItemsCount'] as num).toInt(),
  totalItems: (json['totalItems'] as num).toInt(),
  averageProfitMargin: (json['averageProfitMargin'] as num).toDouble(),
  averageProfitPerItem: (json['averageProfitPerItem'] as num).toDouble(),
  averageTimeToSell: (json['averageTimeToSell'] as num).toDouble(),
  bestSellingItem:
      json['bestSellingItem'] == null
          ? null
          : BestItem.fromJson(json['bestSellingItem'] as Map<String, dynamic>),
  highestProfitItem:
      json['highestProfitItem'] == null
          ? null
          : BestItem.fromJson(
            json['highestProfitItem'] as Map<String, dynamic>,
          ),
  fastestSellingItem:
      json['fastestSellingItem'] == null
          ? null
          : BestItem.fromJson(
            json['fastestSellingItem'] as Map<String, dynamic>,
          ),
  mostProfitablePalletSource: json['mostProfitablePalletSource'] as String?,
  mostProfitablePalletROI:
      (json['mostProfitablePalletROI'] as num?)?.toDouble() ?? 0.0,
  channelPerformance: (json['channelPerformance'] as Map<String, dynamic>?)
      ?.map(
        (k, e) =>
            MapEntry(k, ChannelPerformance.fromJson(e as Map<String, dynamic>)),
      ),
  bestDay:
      json['bestDay'] == null
          ? null
          : DateTime.parse(json['bestDay'] as String),
  bestDayProfit: (json['bestDayProfit'] as num?)?.toDouble() ?? 0.0,
  totalItemsProcessed: (json['totalItemsProcessed'] as num?)?.toInt() ?? 0,
  daysTracking: (json['daysTracking'] as num?)?.toInt() ?? 0,
  totalPallets: (json['totalPallets'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AnalyticsDataToJson(_AnalyticsData instance) =>
    <String, dynamic>{
      'totalInventoryValue': instance.totalInventoryValue,
      'totalPotentialRevenue': instance.totalPotentialRevenue,
      'totalActualRevenue': instance.totalActualRevenue,
      'netProfit': instance.netProfit,
      'totalCosts': instance.totalCosts,
      'itemsInStock': instance.itemsInStock,
      'itemsListed': instance.itemsListed,
      'itemsSold': instance.itemsSold,
      'staleItemsCount': instance.staleItemsCount,
      'totalItems': instance.totalItems,
      'averageProfitMargin': instance.averageProfitMargin,
      'averageProfitPerItem': instance.averageProfitPerItem,
      'averageTimeToSell': instance.averageTimeToSell,
      'bestSellingItem': instance.bestSellingItem,
      'highestProfitItem': instance.highestProfitItem,
      'fastestSellingItem': instance.fastestSellingItem,
      'mostProfitablePalletSource': instance.mostProfitablePalletSource,
      'mostProfitablePalletROI': instance.mostProfitablePalletROI,
      'channelPerformance': instance.channelPerformance,
      'bestDay': instance.bestDay?.toIso8601String(),
      'bestDayProfit': instance.bestDayProfit,
      'totalItemsProcessed': instance.totalItemsProcessed,
      'daysTracking': instance.daysTracking,
      'totalPallets': instance.totalPallets,
    };

_BestItem _$BestItemFromJson(Map<String, dynamic> json) => _BestItem(
  id: json['id'] as String,
  name: json['name'] as String,
  value: (json['value'] as num).toDouble(),
  metric: json['metric'] as String,
  additionalInfo: json['additionalInfo'] as String?,
);

Map<String, dynamic> _$BestItemToJson(_BestItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'value': instance.value,
  'metric': instance.metric,
  'additionalInfo': instance.additionalInfo,
};

_TimeSeriesData _$TimeSeriesDataFromJson(Map<String, dynamic> json) =>
    _TimeSeriesData(
      date: DateTime.parse(json['date'] as String),
      revenue: (json['revenue'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      itemsSold: (json['itemsSold'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TimeSeriesDataToJson(_TimeSeriesData instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'revenue': instance.revenue,
      'cost': instance.cost,
      'profit': instance.profit,
      'itemsSold': instance.itemsSold,
    };

_ChannelPerformance _$ChannelPerformanceFromJson(Map<String, dynamic> json) =>
    _ChannelPerformance(
      channelName: json['channelName'] as String,
      itemsSold: (json['itemsSold'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averageSellingPrice: (json['averageSellingPrice'] as num).toDouble(),
      averageTimeToSell: (json['averageTimeToSell'] as num).toDouble(),
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$ChannelPerformanceToJson(_ChannelPerformance instance) =>
    <String, dynamic>{
      'channelName': instance.channelName,
      'itemsSold': instance.itemsSold,
      'totalRevenue': instance.totalRevenue,
      'averageSellingPrice': instance.averageSellingPrice,
      'averageTimeToSell': instance.averageTimeToSell,
      'conversionRate': instance.conversionRate,
    };

_PalletSourcePerformance _$PalletSourcePerformanceFromJson(
  Map<String, dynamic> json,
) => _PalletSourcePerformance(
  source: json['source'] as String,
  totalPallets: (json['totalPallets'] as num).toInt(),
  totalCost: (json['totalCost'] as num).toDouble(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  totalProfit: (json['totalProfit'] as num).toDouble(),
  roi: (json['roi'] as num).toDouble(),
  averageProfitPerPallet: (json['averageProfitPerPallet'] as num).toDouble(),
);

Map<String, dynamic> _$PalletSourcePerformanceToJson(
  _PalletSourcePerformance instance,
) => <String, dynamic>{
  'source': instance.source,
  'totalPallets': instance.totalPallets,
  'totalCost': instance.totalCost,
  'totalRevenue': instance.totalRevenue,
  'totalProfit': instance.totalProfit,
  'roi': instance.roi,
  'averageProfitPerPallet': instance.averageProfitPerPallet,
};
