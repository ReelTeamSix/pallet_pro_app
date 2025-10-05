// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalyticsData {

// Financial Metrics
 double get totalInventoryValue;// Sum of purchase prices (in stock items)
 double get totalPotentialRevenue;// Sum of listing prices
 double get totalActualRevenue;// Sum of selling prices
 double get netProfit;// actualRevenue - total costs
 double get totalCosts;// Sum of all purchase prices + expenses
// Item Counts by Status
 int get itemsInStock; int get itemsListed; int get itemsSold; int get staleItemsCount; int get totalItems;// Averages
 double get averageProfitMargin;// Percentage
 double get averageProfitPerItem;// Dollar amount per sold item
 double get averageTimeToSell;// Days (for sold items)
// Top Performers
 BestItem? get bestSellingItem;// Highest revenue
 BestItem? get highestProfitItem;// Best profit margin
 BestItem? get fastestSellingItem;// Quickest time to sell
// Pallet Insights
 String? get mostProfitablePalletSource; double get mostProfitablePalletROI;// Sales Channel Performance
 Map<String, ChannelPerformance>? get channelPerformance;// Fun Facts
 DateTime? get bestDay; double get bestDayProfit; int get totalItemsProcessed; int get daysTracking; int get totalPallets;
/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsDataCopyWith<AnalyticsData> get copyWith => _$AnalyticsDataCopyWithImpl<AnalyticsData>(this as AnalyticsData, _$identity);

  /// Serializes this AnalyticsData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsData&&(identical(other.totalInventoryValue, totalInventoryValue) || other.totalInventoryValue == totalInventoryValue)&&(identical(other.totalPotentialRevenue, totalPotentialRevenue) || other.totalPotentialRevenue == totalPotentialRevenue)&&(identical(other.totalActualRevenue, totalActualRevenue) || other.totalActualRevenue == totalActualRevenue)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.totalCosts, totalCosts) || other.totalCosts == totalCosts)&&(identical(other.itemsInStock, itemsInStock) || other.itemsInStock == itemsInStock)&&(identical(other.itemsListed, itemsListed) || other.itemsListed == itemsListed)&&(identical(other.itemsSold, itemsSold) || other.itemsSold == itemsSold)&&(identical(other.staleItemsCount, staleItemsCount) || other.staleItemsCount == staleItemsCount)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.averageProfitMargin, averageProfitMargin) || other.averageProfitMargin == averageProfitMargin)&&(identical(other.averageProfitPerItem, averageProfitPerItem) || other.averageProfitPerItem == averageProfitPerItem)&&(identical(other.averageTimeToSell, averageTimeToSell) || other.averageTimeToSell == averageTimeToSell)&&(identical(other.bestSellingItem, bestSellingItem) || other.bestSellingItem == bestSellingItem)&&(identical(other.highestProfitItem, highestProfitItem) || other.highestProfitItem == highestProfitItem)&&(identical(other.fastestSellingItem, fastestSellingItem) || other.fastestSellingItem == fastestSellingItem)&&(identical(other.mostProfitablePalletSource, mostProfitablePalletSource) || other.mostProfitablePalletSource == mostProfitablePalletSource)&&(identical(other.mostProfitablePalletROI, mostProfitablePalletROI) || other.mostProfitablePalletROI == mostProfitablePalletROI)&&const DeepCollectionEquality().equals(other.channelPerformance, channelPerformance)&&(identical(other.bestDay, bestDay) || other.bestDay == bestDay)&&(identical(other.bestDayProfit, bestDayProfit) || other.bestDayProfit == bestDayProfit)&&(identical(other.totalItemsProcessed, totalItemsProcessed) || other.totalItemsProcessed == totalItemsProcessed)&&(identical(other.daysTracking, daysTracking) || other.daysTracking == daysTracking)&&(identical(other.totalPallets, totalPallets) || other.totalPallets == totalPallets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,totalInventoryValue,totalPotentialRevenue,totalActualRevenue,netProfit,totalCosts,itemsInStock,itemsListed,itemsSold,staleItemsCount,totalItems,averageProfitMargin,averageProfitPerItem,averageTimeToSell,bestSellingItem,highestProfitItem,fastestSellingItem,mostProfitablePalletSource,mostProfitablePalletROI,const DeepCollectionEquality().hash(channelPerformance),bestDay,bestDayProfit,totalItemsProcessed,daysTracking,totalPallets]);

@override
String toString() {
  return 'AnalyticsData(totalInventoryValue: $totalInventoryValue, totalPotentialRevenue: $totalPotentialRevenue, totalActualRevenue: $totalActualRevenue, netProfit: $netProfit, totalCosts: $totalCosts, itemsInStock: $itemsInStock, itemsListed: $itemsListed, itemsSold: $itemsSold, staleItemsCount: $staleItemsCount, totalItems: $totalItems, averageProfitMargin: $averageProfitMargin, averageProfitPerItem: $averageProfitPerItem, averageTimeToSell: $averageTimeToSell, bestSellingItem: $bestSellingItem, highestProfitItem: $highestProfitItem, fastestSellingItem: $fastestSellingItem, mostProfitablePalletSource: $mostProfitablePalletSource, mostProfitablePalletROI: $mostProfitablePalletROI, channelPerformance: $channelPerformance, bestDay: $bestDay, bestDayProfit: $bestDayProfit, totalItemsProcessed: $totalItemsProcessed, daysTracking: $daysTracking, totalPallets: $totalPallets)';
}


}

/// @nodoc
abstract mixin class $AnalyticsDataCopyWith<$Res>  {
  factory $AnalyticsDataCopyWith(AnalyticsData value, $Res Function(AnalyticsData) _then) = _$AnalyticsDataCopyWithImpl;
@useResult
$Res call({
 double totalInventoryValue, double totalPotentialRevenue, double totalActualRevenue, double netProfit, double totalCosts, int itemsInStock, int itemsListed, int itemsSold, int staleItemsCount, int totalItems, double averageProfitMargin, double averageProfitPerItem, double averageTimeToSell, BestItem? bestSellingItem, BestItem? highestProfitItem, BestItem? fastestSellingItem, String? mostProfitablePalletSource, double mostProfitablePalletROI, Map<String, ChannelPerformance>? channelPerformance, DateTime? bestDay, double bestDayProfit, int totalItemsProcessed, int daysTracking, int totalPallets
});


$BestItemCopyWith<$Res>? get bestSellingItem;$BestItemCopyWith<$Res>? get highestProfitItem;$BestItemCopyWith<$Res>? get fastestSellingItem;

}
/// @nodoc
class _$AnalyticsDataCopyWithImpl<$Res>
    implements $AnalyticsDataCopyWith<$Res> {
  _$AnalyticsDataCopyWithImpl(this._self, this._then);

  final AnalyticsData _self;
  final $Res Function(AnalyticsData) _then;

/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalInventoryValue = null,Object? totalPotentialRevenue = null,Object? totalActualRevenue = null,Object? netProfit = null,Object? totalCosts = null,Object? itemsInStock = null,Object? itemsListed = null,Object? itemsSold = null,Object? staleItemsCount = null,Object? totalItems = null,Object? averageProfitMargin = null,Object? averageProfitPerItem = null,Object? averageTimeToSell = null,Object? bestSellingItem = freezed,Object? highestProfitItem = freezed,Object? fastestSellingItem = freezed,Object? mostProfitablePalletSource = freezed,Object? mostProfitablePalletROI = null,Object? channelPerformance = freezed,Object? bestDay = freezed,Object? bestDayProfit = null,Object? totalItemsProcessed = null,Object? daysTracking = null,Object? totalPallets = null,}) {
  return _then(_self.copyWith(
totalInventoryValue: null == totalInventoryValue ? _self.totalInventoryValue : totalInventoryValue // ignore: cast_nullable_to_non_nullable
as double,totalPotentialRevenue: null == totalPotentialRevenue ? _self.totalPotentialRevenue : totalPotentialRevenue // ignore: cast_nullable_to_non_nullable
as double,totalActualRevenue: null == totalActualRevenue ? _self.totalActualRevenue : totalActualRevenue // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,totalCosts: null == totalCosts ? _self.totalCosts : totalCosts // ignore: cast_nullable_to_non_nullable
as double,itemsInStock: null == itemsInStock ? _self.itemsInStock : itemsInStock // ignore: cast_nullable_to_non_nullable
as int,itemsListed: null == itemsListed ? _self.itemsListed : itemsListed // ignore: cast_nullable_to_non_nullable
as int,itemsSold: null == itemsSold ? _self.itemsSold : itemsSold // ignore: cast_nullable_to_non_nullable
as int,staleItemsCount: null == staleItemsCount ? _self.staleItemsCount : staleItemsCount // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,averageProfitMargin: null == averageProfitMargin ? _self.averageProfitMargin : averageProfitMargin // ignore: cast_nullable_to_non_nullable
as double,averageProfitPerItem: null == averageProfitPerItem ? _self.averageProfitPerItem : averageProfitPerItem // ignore: cast_nullable_to_non_nullable
as double,averageTimeToSell: null == averageTimeToSell ? _self.averageTimeToSell : averageTimeToSell // ignore: cast_nullable_to_non_nullable
as double,bestSellingItem: freezed == bestSellingItem ? _self.bestSellingItem : bestSellingItem // ignore: cast_nullable_to_non_nullable
as BestItem?,highestProfitItem: freezed == highestProfitItem ? _self.highestProfitItem : highestProfitItem // ignore: cast_nullable_to_non_nullable
as BestItem?,fastestSellingItem: freezed == fastestSellingItem ? _self.fastestSellingItem : fastestSellingItem // ignore: cast_nullable_to_non_nullable
as BestItem?,mostProfitablePalletSource: freezed == mostProfitablePalletSource ? _self.mostProfitablePalletSource : mostProfitablePalletSource // ignore: cast_nullable_to_non_nullable
as String?,mostProfitablePalletROI: null == mostProfitablePalletROI ? _self.mostProfitablePalletROI : mostProfitablePalletROI // ignore: cast_nullable_to_non_nullable
as double,channelPerformance: freezed == channelPerformance ? _self.channelPerformance : channelPerformance // ignore: cast_nullable_to_non_nullable
as Map<String, ChannelPerformance>?,bestDay: freezed == bestDay ? _self.bestDay : bestDay // ignore: cast_nullable_to_non_nullable
as DateTime?,bestDayProfit: null == bestDayProfit ? _self.bestDayProfit : bestDayProfit // ignore: cast_nullable_to_non_nullable
as double,totalItemsProcessed: null == totalItemsProcessed ? _self.totalItemsProcessed : totalItemsProcessed // ignore: cast_nullable_to_non_nullable
as int,daysTracking: null == daysTracking ? _self.daysTracking : daysTracking // ignore: cast_nullable_to_non_nullable
as int,totalPallets: null == totalPallets ? _self.totalPallets : totalPallets // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BestItemCopyWith<$Res>? get bestSellingItem {
    if (_self.bestSellingItem == null) {
    return null;
  }

  return $BestItemCopyWith<$Res>(_self.bestSellingItem!, (value) {
    return _then(_self.copyWith(bestSellingItem: value));
  });
}/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BestItemCopyWith<$Res>? get highestProfitItem {
    if (_self.highestProfitItem == null) {
    return null;
  }

  return $BestItemCopyWith<$Res>(_self.highestProfitItem!, (value) {
    return _then(_self.copyWith(highestProfitItem: value));
  });
}/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BestItemCopyWith<$Res>? get fastestSellingItem {
    if (_self.fastestSellingItem == null) {
    return null;
  }

  return $BestItemCopyWith<$Res>(_self.fastestSellingItem!, (value) {
    return _then(_self.copyWith(fastestSellingItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsData].
extension AnalyticsDataPatterns on AnalyticsData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsData value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsData value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalInventoryValue,  double totalPotentialRevenue,  double totalActualRevenue,  double netProfit,  double totalCosts,  int itemsInStock,  int itemsListed,  int itemsSold,  int staleItemsCount,  int totalItems,  double averageProfitMargin,  double averageProfitPerItem,  double averageTimeToSell,  BestItem? bestSellingItem,  BestItem? highestProfitItem,  BestItem? fastestSellingItem,  String? mostProfitablePalletSource,  double mostProfitablePalletROI,  Map<String, ChannelPerformance>? channelPerformance,  DateTime? bestDay,  double bestDayProfit,  int totalItemsProcessed,  int daysTracking,  int totalPallets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsData() when $default != null:
return $default(_that.totalInventoryValue,_that.totalPotentialRevenue,_that.totalActualRevenue,_that.netProfit,_that.totalCosts,_that.itemsInStock,_that.itemsListed,_that.itemsSold,_that.staleItemsCount,_that.totalItems,_that.averageProfitMargin,_that.averageProfitPerItem,_that.averageTimeToSell,_that.bestSellingItem,_that.highestProfitItem,_that.fastestSellingItem,_that.mostProfitablePalletSource,_that.mostProfitablePalletROI,_that.channelPerformance,_that.bestDay,_that.bestDayProfit,_that.totalItemsProcessed,_that.daysTracking,_that.totalPallets);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalInventoryValue,  double totalPotentialRevenue,  double totalActualRevenue,  double netProfit,  double totalCosts,  int itemsInStock,  int itemsListed,  int itemsSold,  int staleItemsCount,  int totalItems,  double averageProfitMargin,  double averageProfitPerItem,  double averageTimeToSell,  BestItem? bestSellingItem,  BestItem? highestProfitItem,  BestItem? fastestSellingItem,  String? mostProfitablePalletSource,  double mostProfitablePalletROI,  Map<String, ChannelPerformance>? channelPerformance,  DateTime? bestDay,  double bestDayProfit,  int totalItemsProcessed,  int daysTracking,  int totalPallets)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsData():
return $default(_that.totalInventoryValue,_that.totalPotentialRevenue,_that.totalActualRevenue,_that.netProfit,_that.totalCosts,_that.itemsInStock,_that.itemsListed,_that.itemsSold,_that.staleItemsCount,_that.totalItems,_that.averageProfitMargin,_that.averageProfitPerItem,_that.averageTimeToSell,_that.bestSellingItem,_that.highestProfitItem,_that.fastestSellingItem,_that.mostProfitablePalletSource,_that.mostProfitablePalletROI,_that.channelPerformance,_that.bestDay,_that.bestDayProfit,_that.totalItemsProcessed,_that.daysTracking,_that.totalPallets);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalInventoryValue,  double totalPotentialRevenue,  double totalActualRevenue,  double netProfit,  double totalCosts,  int itemsInStock,  int itemsListed,  int itemsSold,  int staleItemsCount,  int totalItems,  double averageProfitMargin,  double averageProfitPerItem,  double averageTimeToSell,  BestItem? bestSellingItem,  BestItem? highestProfitItem,  BestItem? fastestSellingItem,  String? mostProfitablePalletSource,  double mostProfitablePalletROI,  Map<String, ChannelPerformance>? channelPerformance,  DateTime? bestDay,  double bestDayProfit,  int totalItemsProcessed,  int daysTracking,  int totalPallets)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsData() when $default != null:
return $default(_that.totalInventoryValue,_that.totalPotentialRevenue,_that.totalActualRevenue,_that.netProfit,_that.totalCosts,_that.itemsInStock,_that.itemsListed,_that.itemsSold,_that.staleItemsCount,_that.totalItems,_that.averageProfitMargin,_that.averageProfitPerItem,_that.averageTimeToSell,_that.bestSellingItem,_that.highestProfitItem,_that.fastestSellingItem,_that.mostProfitablePalletSource,_that.mostProfitablePalletROI,_that.channelPerformance,_that.bestDay,_that.bestDayProfit,_that.totalItemsProcessed,_that.daysTracking,_that.totalPallets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsData implements AnalyticsData {
  const _AnalyticsData({required this.totalInventoryValue, required this.totalPotentialRevenue, required this.totalActualRevenue, required this.netProfit, required this.totalCosts, required this.itemsInStock, required this.itemsListed, required this.itemsSold, required this.staleItemsCount, required this.totalItems, required this.averageProfitMargin, required this.averageProfitPerItem, required this.averageTimeToSell, this.bestSellingItem, this.highestProfitItem, this.fastestSellingItem, this.mostProfitablePalletSource, this.mostProfitablePalletROI = 0.0, final  Map<String, ChannelPerformance>? channelPerformance, this.bestDay, this.bestDayProfit = 0.0, this.totalItemsProcessed = 0, this.daysTracking = 0, this.totalPallets = 0}): _channelPerformance = channelPerformance;
  factory _AnalyticsData.fromJson(Map<String, dynamic> json) => _$AnalyticsDataFromJson(json);

// Financial Metrics
@override final  double totalInventoryValue;
// Sum of purchase prices (in stock items)
@override final  double totalPotentialRevenue;
// Sum of listing prices
@override final  double totalActualRevenue;
// Sum of selling prices
@override final  double netProfit;
// actualRevenue - total costs
@override final  double totalCosts;
// Sum of all purchase prices + expenses
// Item Counts by Status
@override final  int itemsInStock;
@override final  int itemsListed;
@override final  int itemsSold;
@override final  int staleItemsCount;
@override final  int totalItems;
// Averages
@override final  double averageProfitMargin;
// Percentage
@override final  double averageProfitPerItem;
// Dollar amount per sold item
@override final  double averageTimeToSell;
// Days (for sold items)
// Top Performers
@override final  BestItem? bestSellingItem;
// Highest revenue
@override final  BestItem? highestProfitItem;
// Best profit margin
@override final  BestItem? fastestSellingItem;
// Quickest time to sell
// Pallet Insights
@override final  String? mostProfitablePalletSource;
@override@JsonKey() final  double mostProfitablePalletROI;
// Sales Channel Performance
 final  Map<String, ChannelPerformance>? _channelPerformance;
// Sales Channel Performance
@override Map<String, ChannelPerformance>? get channelPerformance {
  final value = _channelPerformance;
  if (value == null) return null;
  if (_channelPerformance is EqualUnmodifiableMapView) return _channelPerformance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Fun Facts
@override final  DateTime? bestDay;
@override@JsonKey() final  double bestDayProfit;
@override@JsonKey() final  int totalItemsProcessed;
@override@JsonKey() final  int daysTracking;
@override@JsonKey() final  int totalPallets;

/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsDataCopyWith<_AnalyticsData> get copyWith => __$AnalyticsDataCopyWithImpl<_AnalyticsData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsData&&(identical(other.totalInventoryValue, totalInventoryValue) || other.totalInventoryValue == totalInventoryValue)&&(identical(other.totalPotentialRevenue, totalPotentialRevenue) || other.totalPotentialRevenue == totalPotentialRevenue)&&(identical(other.totalActualRevenue, totalActualRevenue) || other.totalActualRevenue == totalActualRevenue)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.totalCosts, totalCosts) || other.totalCosts == totalCosts)&&(identical(other.itemsInStock, itemsInStock) || other.itemsInStock == itemsInStock)&&(identical(other.itemsListed, itemsListed) || other.itemsListed == itemsListed)&&(identical(other.itemsSold, itemsSold) || other.itemsSold == itemsSold)&&(identical(other.staleItemsCount, staleItemsCount) || other.staleItemsCount == staleItemsCount)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.averageProfitMargin, averageProfitMargin) || other.averageProfitMargin == averageProfitMargin)&&(identical(other.averageProfitPerItem, averageProfitPerItem) || other.averageProfitPerItem == averageProfitPerItem)&&(identical(other.averageTimeToSell, averageTimeToSell) || other.averageTimeToSell == averageTimeToSell)&&(identical(other.bestSellingItem, bestSellingItem) || other.bestSellingItem == bestSellingItem)&&(identical(other.highestProfitItem, highestProfitItem) || other.highestProfitItem == highestProfitItem)&&(identical(other.fastestSellingItem, fastestSellingItem) || other.fastestSellingItem == fastestSellingItem)&&(identical(other.mostProfitablePalletSource, mostProfitablePalletSource) || other.mostProfitablePalletSource == mostProfitablePalletSource)&&(identical(other.mostProfitablePalletROI, mostProfitablePalletROI) || other.mostProfitablePalletROI == mostProfitablePalletROI)&&const DeepCollectionEquality().equals(other._channelPerformance, _channelPerformance)&&(identical(other.bestDay, bestDay) || other.bestDay == bestDay)&&(identical(other.bestDayProfit, bestDayProfit) || other.bestDayProfit == bestDayProfit)&&(identical(other.totalItemsProcessed, totalItemsProcessed) || other.totalItemsProcessed == totalItemsProcessed)&&(identical(other.daysTracking, daysTracking) || other.daysTracking == daysTracking)&&(identical(other.totalPallets, totalPallets) || other.totalPallets == totalPallets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,totalInventoryValue,totalPotentialRevenue,totalActualRevenue,netProfit,totalCosts,itemsInStock,itemsListed,itemsSold,staleItemsCount,totalItems,averageProfitMargin,averageProfitPerItem,averageTimeToSell,bestSellingItem,highestProfitItem,fastestSellingItem,mostProfitablePalletSource,mostProfitablePalletROI,const DeepCollectionEquality().hash(_channelPerformance),bestDay,bestDayProfit,totalItemsProcessed,daysTracking,totalPallets]);

@override
String toString() {
  return 'AnalyticsData(totalInventoryValue: $totalInventoryValue, totalPotentialRevenue: $totalPotentialRevenue, totalActualRevenue: $totalActualRevenue, netProfit: $netProfit, totalCosts: $totalCosts, itemsInStock: $itemsInStock, itemsListed: $itemsListed, itemsSold: $itemsSold, staleItemsCount: $staleItemsCount, totalItems: $totalItems, averageProfitMargin: $averageProfitMargin, averageProfitPerItem: $averageProfitPerItem, averageTimeToSell: $averageTimeToSell, bestSellingItem: $bestSellingItem, highestProfitItem: $highestProfitItem, fastestSellingItem: $fastestSellingItem, mostProfitablePalletSource: $mostProfitablePalletSource, mostProfitablePalletROI: $mostProfitablePalletROI, channelPerformance: $channelPerformance, bestDay: $bestDay, bestDayProfit: $bestDayProfit, totalItemsProcessed: $totalItemsProcessed, daysTracking: $daysTracking, totalPallets: $totalPallets)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsDataCopyWith<$Res> implements $AnalyticsDataCopyWith<$Res> {
  factory _$AnalyticsDataCopyWith(_AnalyticsData value, $Res Function(_AnalyticsData) _then) = __$AnalyticsDataCopyWithImpl;
@override @useResult
$Res call({
 double totalInventoryValue, double totalPotentialRevenue, double totalActualRevenue, double netProfit, double totalCosts, int itemsInStock, int itemsListed, int itemsSold, int staleItemsCount, int totalItems, double averageProfitMargin, double averageProfitPerItem, double averageTimeToSell, BestItem? bestSellingItem, BestItem? highestProfitItem, BestItem? fastestSellingItem, String? mostProfitablePalletSource, double mostProfitablePalletROI, Map<String, ChannelPerformance>? channelPerformance, DateTime? bestDay, double bestDayProfit, int totalItemsProcessed, int daysTracking, int totalPallets
});


@override $BestItemCopyWith<$Res>? get bestSellingItem;@override $BestItemCopyWith<$Res>? get highestProfitItem;@override $BestItemCopyWith<$Res>? get fastestSellingItem;

}
/// @nodoc
class __$AnalyticsDataCopyWithImpl<$Res>
    implements _$AnalyticsDataCopyWith<$Res> {
  __$AnalyticsDataCopyWithImpl(this._self, this._then);

  final _AnalyticsData _self;
  final $Res Function(_AnalyticsData) _then;

/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalInventoryValue = null,Object? totalPotentialRevenue = null,Object? totalActualRevenue = null,Object? netProfit = null,Object? totalCosts = null,Object? itemsInStock = null,Object? itemsListed = null,Object? itemsSold = null,Object? staleItemsCount = null,Object? totalItems = null,Object? averageProfitMargin = null,Object? averageProfitPerItem = null,Object? averageTimeToSell = null,Object? bestSellingItem = freezed,Object? highestProfitItem = freezed,Object? fastestSellingItem = freezed,Object? mostProfitablePalletSource = freezed,Object? mostProfitablePalletROI = null,Object? channelPerformance = freezed,Object? bestDay = freezed,Object? bestDayProfit = null,Object? totalItemsProcessed = null,Object? daysTracking = null,Object? totalPallets = null,}) {
  return _then(_AnalyticsData(
totalInventoryValue: null == totalInventoryValue ? _self.totalInventoryValue : totalInventoryValue // ignore: cast_nullable_to_non_nullable
as double,totalPotentialRevenue: null == totalPotentialRevenue ? _self.totalPotentialRevenue : totalPotentialRevenue // ignore: cast_nullable_to_non_nullable
as double,totalActualRevenue: null == totalActualRevenue ? _self.totalActualRevenue : totalActualRevenue // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,totalCosts: null == totalCosts ? _self.totalCosts : totalCosts // ignore: cast_nullable_to_non_nullable
as double,itemsInStock: null == itemsInStock ? _self.itemsInStock : itemsInStock // ignore: cast_nullable_to_non_nullable
as int,itemsListed: null == itemsListed ? _self.itemsListed : itemsListed // ignore: cast_nullable_to_non_nullable
as int,itemsSold: null == itemsSold ? _self.itemsSold : itemsSold // ignore: cast_nullable_to_non_nullable
as int,staleItemsCount: null == staleItemsCount ? _self.staleItemsCount : staleItemsCount // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,averageProfitMargin: null == averageProfitMargin ? _self.averageProfitMargin : averageProfitMargin // ignore: cast_nullable_to_non_nullable
as double,averageProfitPerItem: null == averageProfitPerItem ? _self.averageProfitPerItem : averageProfitPerItem // ignore: cast_nullable_to_non_nullable
as double,averageTimeToSell: null == averageTimeToSell ? _self.averageTimeToSell : averageTimeToSell // ignore: cast_nullable_to_non_nullable
as double,bestSellingItem: freezed == bestSellingItem ? _self.bestSellingItem : bestSellingItem // ignore: cast_nullable_to_non_nullable
as BestItem?,highestProfitItem: freezed == highestProfitItem ? _self.highestProfitItem : highestProfitItem // ignore: cast_nullable_to_non_nullable
as BestItem?,fastestSellingItem: freezed == fastestSellingItem ? _self.fastestSellingItem : fastestSellingItem // ignore: cast_nullable_to_non_nullable
as BestItem?,mostProfitablePalletSource: freezed == mostProfitablePalletSource ? _self.mostProfitablePalletSource : mostProfitablePalletSource // ignore: cast_nullable_to_non_nullable
as String?,mostProfitablePalletROI: null == mostProfitablePalletROI ? _self.mostProfitablePalletROI : mostProfitablePalletROI // ignore: cast_nullable_to_non_nullable
as double,channelPerformance: freezed == channelPerformance ? _self._channelPerformance : channelPerformance // ignore: cast_nullable_to_non_nullable
as Map<String, ChannelPerformance>?,bestDay: freezed == bestDay ? _self.bestDay : bestDay // ignore: cast_nullable_to_non_nullable
as DateTime?,bestDayProfit: null == bestDayProfit ? _self.bestDayProfit : bestDayProfit // ignore: cast_nullable_to_non_nullable
as double,totalItemsProcessed: null == totalItemsProcessed ? _self.totalItemsProcessed : totalItemsProcessed // ignore: cast_nullable_to_non_nullable
as int,daysTracking: null == daysTracking ? _self.daysTracking : daysTracking // ignore: cast_nullable_to_non_nullable
as int,totalPallets: null == totalPallets ? _self.totalPallets : totalPallets // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BestItemCopyWith<$Res>? get bestSellingItem {
    if (_self.bestSellingItem == null) {
    return null;
  }

  return $BestItemCopyWith<$Res>(_self.bestSellingItem!, (value) {
    return _then(_self.copyWith(bestSellingItem: value));
  });
}/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BestItemCopyWith<$Res>? get highestProfitItem {
    if (_self.highestProfitItem == null) {
    return null;
  }

  return $BestItemCopyWith<$Res>(_self.highestProfitItem!, (value) {
    return _then(_self.copyWith(highestProfitItem: value));
  });
}/// Create a copy of AnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BestItemCopyWith<$Res>? get fastestSellingItem {
    if (_self.fastestSellingItem == null) {
    return null;
  }

  return $BestItemCopyWith<$Res>(_self.fastestSellingItem!, (value) {
    return _then(_self.copyWith(fastestSellingItem: value));
  });
}
}


/// @nodoc
mixin _$BestItem {

 String get id; String get name; double get value; String get metric;// 'revenue', 'profit', 'speed', 'margin'
 String? get additionalInfo;
/// Create a copy of BestItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BestItemCopyWith<BestItem> get copyWith => _$BestItemCopyWithImpl<BestItem>(this as BestItem, _$identity);

  /// Serializes this BestItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BestItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value)&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.additionalInfo, additionalInfo) || other.additionalInfo == additionalInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,value,metric,additionalInfo);

@override
String toString() {
  return 'BestItem(id: $id, name: $name, value: $value, metric: $metric, additionalInfo: $additionalInfo)';
}


}

/// @nodoc
abstract mixin class $BestItemCopyWith<$Res>  {
  factory $BestItemCopyWith(BestItem value, $Res Function(BestItem) _then) = _$BestItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, double value, String metric, String? additionalInfo
});




}
/// @nodoc
class _$BestItemCopyWithImpl<$Res>
    implements $BestItemCopyWith<$Res> {
  _$BestItemCopyWithImpl(this._self, this._then);

  final BestItem _self;
  final $Res Function(BestItem) _then;

/// Create a copy of BestItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? value = null,Object? metric = null,Object? additionalInfo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as String,additionalInfo: freezed == additionalInfo ? _self.additionalInfo : additionalInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BestItem].
extension BestItemPatterns on BestItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BestItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BestItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BestItem value)  $default,){
final _that = this;
switch (_that) {
case _BestItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BestItem value)?  $default,){
final _that = this;
switch (_that) {
case _BestItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double value,  String metric,  String? additionalInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BestItem() when $default != null:
return $default(_that.id,_that.name,_that.value,_that.metric,_that.additionalInfo);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double value,  String metric,  String? additionalInfo)  $default,) {final _that = this;
switch (_that) {
case _BestItem():
return $default(_that.id,_that.name,_that.value,_that.metric,_that.additionalInfo);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double value,  String metric,  String? additionalInfo)?  $default,) {final _that = this;
switch (_that) {
case _BestItem() when $default != null:
return $default(_that.id,_that.name,_that.value,_that.metric,_that.additionalInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BestItem implements BestItem {
  const _BestItem({required this.id, required this.name, required this.value, required this.metric, this.additionalInfo});
  factory _BestItem.fromJson(Map<String, dynamic> json) => _$BestItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  double value;
@override final  String metric;
// 'revenue', 'profit', 'speed', 'margin'
@override final  String? additionalInfo;

/// Create a copy of BestItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BestItemCopyWith<_BestItem> get copyWith => __$BestItemCopyWithImpl<_BestItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BestItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BestItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value)&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.additionalInfo, additionalInfo) || other.additionalInfo == additionalInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,value,metric,additionalInfo);

@override
String toString() {
  return 'BestItem(id: $id, name: $name, value: $value, metric: $metric, additionalInfo: $additionalInfo)';
}


}

/// @nodoc
abstract mixin class _$BestItemCopyWith<$Res> implements $BestItemCopyWith<$Res> {
  factory _$BestItemCopyWith(_BestItem value, $Res Function(_BestItem) _then) = __$BestItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double value, String metric, String? additionalInfo
});




}
/// @nodoc
class __$BestItemCopyWithImpl<$Res>
    implements _$BestItemCopyWith<$Res> {
  __$BestItemCopyWithImpl(this._self, this._then);

  final _BestItem _self;
  final $Res Function(_BestItem) _then;

/// Create a copy of BestItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? value = null,Object? metric = null,Object? additionalInfo = freezed,}) {
  return _then(_BestItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as String,additionalInfo: freezed == additionalInfo ? _self.additionalInfo : additionalInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TimeSeriesData {

 DateTime get date; double get revenue; double get cost; double get profit; int get itemsSold;
/// Create a copy of TimeSeriesData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeSeriesDataCopyWith<TimeSeriesData> get copyWith => _$TimeSeriesDataCopyWithImpl<TimeSeriesData>(this as TimeSeriesData, _$identity);

  /// Serializes this TimeSeriesData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeSeriesData&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.itemsSold, itemsSold) || other.itemsSold == itemsSold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,cost,profit,itemsSold);

@override
String toString() {
  return 'TimeSeriesData(date: $date, revenue: $revenue, cost: $cost, profit: $profit, itemsSold: $itemsSold)';
}


}

/// @nodoc
abstract mixin class $TimeSeriesDataCopyWith<$Res>  {
  factory $TimeSeriesDataCopyWith(TimeSeriesData value, $Res Function(TimeSeriesData) _then) = _$TimeSeriesDataCopyWithImpl;
@useResult
$Res call({
 DateTime date, double revenue, double cost, double profit, int itemsSold
});




}
/// @nodoc
class _$TimeSeriesDataCopyWithImpl<$Res>
    implements $TimeSeriesDataCopyWith<$Res> {
  _$TimeSeriesDataCopyWithImpl(this._self, this._then);

  final TimeSeriesData _self;
  final $Res Function(TimeSeriesData) _then;

/// Create a copy of TimeSeriesData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? revenue = null,Object? cost = null,Object? profit = null,Object? itemsSold = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as double,itemsSold: null == itemsSold ? _self.itemsSold : itemsSold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeSeriesData].
extension TimeSeriesDataPatterns on TimeSeriesData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeSeriesData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeSeriesData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeSeriesData value)  $default,){
final _that = this;
switch (_that) {
case _TimeSeriesData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeSeriesData value)?  $default,){
final _that = this;
switch (_that) {
case _TimeSeriesData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double revenue,  double cost,  double profit,  int itemsSold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeSeriesData() when $default != null:
return $default(_that.date,_that.revenue,_that.cost,_that.profit,_that.itemsSold);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double revenue,  double cost,  double profit,  int itemsSold)  $default,) {final _that = this;
switch (_that) {
case _TimeSeriesData():
return $default(_that.date,_that.revenue,_that.cost,_that.profit,_that.itemsSold);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double revenue,  double cost,  double profit,  int itemsSold)?  $default,) {final _that = this;
switch (_that) {
case _TimeSeriesData() when $default != null:
return $default(_that.date,_that.revenue,_that.cost,_that.profit,_that.itemsSold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimeSeriesData implements TimeSeriesData {
  const _TimeSeriesData({required this.date, required this.revenue, required this.cost, required this.profit, this.itemsSold = 0});
  factory _TimeSeriesData.fromJson(Map<String, dynamic> json) => _$TimeSeriesDataFromJson(json);

@override final  DateTime date;
@override final  double revenue;
@override final  double cost;
@override final  double profit;
@override@JsonKey() final  int itemsSold;

/// Create a copy of TimeSeriesData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeSeriesDataCopyWith<_TimeSeriesData> get copyWith => __$TimeSeriesDataCopyWithImpl<_TimeSeriesData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeSeriesDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeSeriesData&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.itemsSold, itemsSold) || other.itemsSold == itemsSold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,cost,profit,itemsSold);

@override
String toString() {
  return 'TimeSeriesData(date: $date, revenue: $revenue, cost: $cost, profit: $profit, itemsSold: $itemsSold)';
}


}

/// @nodoc
abstract mixin class _$TimeSeriesDataCopyWith<$Res> implements $TimeSeriesDataCopyWith<$Res> {
  factory _$TimeSeriesDataCopyWith(_TimeSeriesData value, $Res Function(_TimeSeriesData) _then) = __$TimeSeriesDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double revenue, double cost, double profit, int itemsSold
});




}
/// @nodoc
class __$TimeSeriesDataCopyWithImpl<$Res>
    implements _$TimeSeriesDataCopyWith<$Res> {
  __$TimeSeriesDataCopyWithImpl(this._self, this._then);

  final _TimeSeriesData _self;
  final $Res Function(_TimeSeriesData) _then;

/// Create a copy of TimeSeriesData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? revenue = null,Object? cost = null,Object? profit = null,Object? itemsSold = null,}) {
  return _then(_TimeSeriesData(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as double,itemsSold: null == itemsSold ? _self.itemsSold : itemsSold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChannelPerformance {

 String get channelName; int get itemsSold; double get totalRevenue; double get averageSellingPrice; double get averageTimeToSell;// days
 double get conversionRate;
/// Create a copy of ChannelPerformance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelPerformanceCopyWith<ChannelPerformance> get copyWith => _$ChannelPerformanceCopyWithImpl<ChannelPerformance>(this as ChannelPerformance, _$identity);

  /// Serializes this ChannelPerformance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelPerformance&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.itemsSold, itemsSold) || other.itemsSold == itemsSold)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.averageSellingPrice, averageSellingPrice) || other.averageSellingPrice == averageSellingPrice)&&(identical(other.averageTimeToSell, averageTimeToSell) || other.averageTimeToSell == averageTimeToSell)&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelName,itemsSold,totalRevenue,averageSellingPrice,averageTimeToSell,conversionRate);

@override
String toString() {
  return 'ChannelPerformance(channelName: $channelName, itemsSold: $itemsSold, totalRevenue: $totalRevenue, averageSellingPrice: $averageSellingPrice, averageTimeToSell: $averageTimeToSell, conversionRate: $conversionRate)';
}


}

/// @nodoc
abstract mixin class $ChannelPerformanceCopyWith<$Res>  {
  factory $ChannelPerformanceCopyWith(ChannelPerformance value, $Res Function(ChannelPerformance) _then) = _$ChannelPerformanceCopyWithImpl;
@useResult
$Res call({
 String channelName, int itemsSold, double totalRevenue, double averageSellingPrice, double averageTimeToSell, double conversionRate
});




}
/// @nodoc
class _$ChannelPerformanceCopyWithImpl<$Res>
    implements $ChannelPerformanceCopyWith<$Res> {
  _$ChannelPerformanceCopyWithImpl(this._self, this._then);

  final ChannelPerformance _self;
  final $Res Function(ChannelPerformance) _then;

/// Create a copy of ChannelPerformance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelName = null,Object? itemsSold = null,Object? totalRevenue = null,Object? averageSellingPrice = null,Object? averageTimeToSell = null,Object? conversionRate = null,}) {
  return _then(_self.copyWith(
channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,itemsSold: null == itemsSold ? _self.itemsSold : itemsSold // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,averageSellingPrice: null == averageSellingPrice ? _self.averageSellingPrice : averageSellingPrice // ignore: cast_nullable_to_non_nullable
as double,averageTimeToSell: null == averageTimeToSell ? _self.averageTimeToSell : averageTimeToSell // ignore: cast_nullable_to_non_nullable
as double,conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelPerformance].
extension ChannelPerformancePatterns on ChannelPerformance {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelPerformance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelPerformance() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelPerformance value)  $default,){
final _that = this;
switch (_that) {
case _ChannelPerformance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelPerformance value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelPerformance() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelName,  int itemsSold,  double totalRevenue,  double averageSellingPrice,  double averageTimeToSell,  double conversionRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelPerformance() when $default != null:
return $default(_that.channelName,_that.itemsSold,_that.totalRevenue,_that.averageSellingPrice,_that.averageTimeToSell,_that.conversionRate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelName,  int itemsSold,  double totalRevenue,  double averageSellingPrice,  double averageTimeToSell,  double conversionRate)  $default,) {final _that = this;
switch (_that) {
case _ChannelPerformance():
return $default(_that.channelName,_that.itemsSold,_that.totalRevenue,_that.averageSellingPrice,_that.averageTimeToSell,_that.conversionRate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelName,  int itemsSold,  double totalRevenue,  double averageSellingPrice,  double averageTimeToSell,  double conversionRate)?  $default,) {final _that = this;
switch (_that) {
case _ChannelPerformance() when $default != null:
return $default(_that.channelName,_that.itemsSold,_that.totalRevenue,_that.averageSellingPrice,_that.averageTimeToSell,_that.conversionRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChannelPerformance implements ChannelPerformance {
  const _ChannelPerformance({required this.channelName, required this.itemsSold, required this.totalRevenue, required this.averageSellingPrice, required this.averageTimeToSell, this.conversionRate = 0.0});
  factory _ChannelPerformance.fromJson(Map<String, dynamic> json) => _$ChannelPerformanceFromJson(json);

@override final  String channelName;
@override final  int itemsSold;
@override final  double totalRevenue;
@override final  double averageSellingPrice;
@override final  double averageTimeToSell;
// days
@override@JsonKey() final  double conversionRate;

/// Create a copy of ChannelPerformance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelPerformanceCopyWith<_ChannelPerformance> get copyWith => __$ChannelPerformanceCopyWithImpl<_ChannelPerformance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelPerformanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelPerformance&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.itemsSold, itemsSold) || other.itemsSold == itemsSold)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.averageSellingPrice, averageSellingPrice) || other.averageSellingPrice == averageSellingPrice)&&(identical(other.averageTimeToSell, averageTimeToSell) || other.averageTimeToSell == averageTimeToSell)&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelName,itemsSold,totalRevenue,averageSellingPrice,averageTimeToSell,conversionRate);

@override
String toString() {
  return 'ChannelPerformance(channelName: $channelName, itemsSold: $itemsSold, totalRevenue: $totalRevenue, averageSellingPrice: $averageSellingPrice, averageTimeToSell: $averageTimeToSell, conversionRate: $conversionRate)';
}


}

/// @nodoc
abstract mixin class _$ChannelPerformanceCopyWith<$Res> implements $ChannelPerformanceCopyWith<$Res> {
  factory _$ChannelPerformanceCopyWith(_ChannelPerformance value, $Res Function(_ChannelPerformance) _then) = __$ChannelPerformanceCopyWithImpl;
@override @useResult
$Res call({
 String channelName, int itemsSold, double totalRevenue, double averageSellingPrice, double averageTimeToSell, double conversionRate
});




}
/// @nodoc
class __$ChannelPerformanceCopyWithImpl<$Res>
    implements _$ChannelPerformanceCopyWith<$Res> {
  __$ChannelPerformanceCopyWithImpl(this._self, this._then);

  final _ChannelPerformance _self;
  final $Res Function(_ChannelPerformance) _then;

/// Create a copy of ChannelPerformance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelName = null,Object? itemsSold = null,Object? totalRevenue = null,Object? averageSellingPrice = null,Object? averageTimeToSell = null,Object? conversionRate = null,}) {
  return _then(_ChannelPerformance(
channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,itemsSold: null == itemsSold ? _self.itemsSold : itemsSold // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,averageSellingPrice: null == averageSellingPrice ? _self.averageSellingPrice : averageSellingPrice // ignore: cast_nullable_to_non_nullable
as double,averageTimeToSell: null == averageTimeToSell ? _self.averageTimeToSell : averageTimeToSell // ignore: cast_nullable_to_non_nullable
as double,conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PalletSourcePerformance {

 String get source;// e.g., "Amazon", "Walmart"
 int get totalPallets; double get totalCost; double get totalRevenue; double get totalProfit; double get roi;// Return on investment percentage
 double get averageProfitPerPallet;
/// Create a copy of PalletSourcePerformance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PalletSourcePerformanceCopyWith<PalletSourcePerformance> get copyWith => _$PalletSourcePerformanceCopyWithImpl<PalletSourcePerformance>(this as PalletSourcePerformance, _$identity);

  /// Serializes this PalletSourcePerformance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PalletSourcePerformance&&(identical(other.source, source) || other.source == source)&&(identical(other.totalPallets, totalPallets) || other.totalPallets == totalPallets)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalProfit, totalProfit) || other.totalProfit == totalProfit)&&(identical(other.roi, roi) || other.roi == roi)&&(identical(other.averageProfitPerPallet, averageProfitPerPallet) || other.averageProfitPerPallet == averageProfitPerPallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,totalPallets,totalCost,totalRevenue,totalProfit,roi,averageProfitPerPallet);

@override
String toString() {
  return 'PalletSourcePerformance(source: $source, totalPallets: $totalPallets, totalCost: $totalCost, totalRevenue: $totalRevenue, totalProfit: $totalProfit, roi: $roi, averageProfitPerPallet: $averageProfitPerPallet)';
}


}

/// @nodoc
abstract mixin class $PalletSourcePerformanceCopyWith<$Res>  {
  factory $PalletSourcePerformanceCopyWith(PalletSourcePerformance value, $Res Function(PalletSourcePerformance) _then) = _$PalletSourcePerformanceCopyWithImpl;
@useResult
$Res call({
 String source, int totalPallets, double totalCost, double totalRevenue, double totalProfit, double roi, double averageProfitPerPallet
});




}
/// @nodoc
class _$PalletSourcePerformanceCopyWithImpl<$Res>
    implements $PalletSourcePerformanceCopyWith<$Res> {
  _$PalletSourcePerformanceCopyWithImpl(this._self, this._then);

  final PalletSourcePerformance _self;
  final $Res Function(PalletSourcePerformance) _then;

/// Create a copy of PalletSourcePerformance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? totalPallets = null,Object? totalCost = null,Object? totalRevenue = null,Object? totalProfit = null,Object? roi = null,Object? averageProfitPerPallet = null,}) {
  return _then(_self.copyWith(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,totalPallets: null == totalPallets ? _self.totalPallets : totalPallets // ignore: cast_nullable_to_non_nullable
as int,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalProfit: null == totalProfit ? _self.totalProfit : totalProfit // ignore: cast_nullable_to_non_nullable
as double,roi: null == roi ? _self.roi : roi // ignore: cast_nullable_to_non_nullable
as double,averageProfitPerPallet: null == averageProfitPerPallet ? _self.averageProfitPerPallet : averageProfitPerPallet // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PalletSourcePerformance].
extension PalletSourcePerformancePatterns on PalletSourcePerformance {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PalletSourcePerformance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PalletSourcePerformance() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PalletSourcePerformance value)  $default,){
final _that = this;
switch (_that) {
case _PalletSourcePerformance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PalletSourcePerformance value)?  $default,){
final _that = this;
switch (_that) {
case _PalletSourcePerformance() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String source,  int totalPallets,  double totalCost,  double totalRevenue,  double totalProfit,  double roi,  double averageProfitPerPallet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PalletSourcePerformance() when $default != null:
return $default(_that.source,_that.totalPallets,_that.totalCost,_that.totalRevenue,_that.totalProfit,_that.roi,_that.averageProfitPerPallet);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String source,  int totalPallets,  double totalCost,  double totalRevenue,  double totalProfit,  double roi,  double averageProfitPerPallet)  $default,) {final _that = this;
switch (_that) {
case _PalletSourcePerformance():
return $default(_that.source,_that.totalPallets,_that.totalCost,_that.totalRevenue,_that.totalProfit,_that.roi,_that.averageProfitPerPallet);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String source,  int totalPallets,  double totalCost,  double totalRevenue,  double totalProfit,  double roi,  double averageProfitPerPallet)?  $default,) {final _that = this;
switch (_that) {
case _PalletSourcePerformance() when $default != null:
return $default(_that.source,_that.totalPallets,_that.totalCost,_that.totalRevenue,_that.totalProfit,_that.roi,_that.averageProfitPerPallet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PalletSourcePerformance implements PalletSourcePerformance {
  const _PalletSourcePerformance({required this.source, required this.totalPallets, required this.totalCost, required this.totalRevenue, required this.totalProfit, required this.roi, required this.averageProfitPerPallet});
  factory _PalletSourcePerformance.fromJson(Map<String, dynamic> json) => _$PalletSourcePerformanceFromJson(json);

@override final  String source;
// e.g., "Amazon", "Walmart"
@override final  int totalPallets;
@override final  double totalCost;
@override final  double totalRevenue;
@override final  double totalProfit;
@override final  double roi;
// Return on investment percentage
@override final  double averageProfitPerPallet;

/// Create a copy of PalletSourcePerformance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PalletSourcePerformanceCopyWith<_PalletSourcePerformance> get copyWith => __$PalletSourcePerformanceCopyWithImpl<_PalletSourcePerformance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PalletSourcePerformanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PalletSourcePerformance&&(identical(other.source, source) || other.source == source)&&(identical(other.totalPallets, totalPallets) || other.totalPallets == totalPallets)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalProfit, totalProfit) || other.totalProfit == totalProfit)&&(identical(other.roi, roi) || other.roi == roi)&&(identical(other.averageProfitPerPallet, averageProfitPerPallet) || other.averageProfitPerPallet == averageProfitPerPallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,totalPallets,totalCost,totalRevenue,totalProfit,roi,averageProfitPerPallet);

@override
String toString() {
  return 'PalletSourcePerformance(source: $source, totalPallets: $totalPallets, totalCost: $totalCost, totalRevenue: $totalRevenue, totalProfit: $totalProfit, roi: $roi, averageProfitPerPallet: $averageProfitPerPallet)';
}


}

/// @nodoc
abstract mixin class _$PalletSourcePerformanceCopyWith<$Res> implements $PalletSourcePerformanceCopyWith<$Res> {
  factory _$PalletSourcePerformanceCopyWith(_PalletSourcePerformance value, $Res Function(_PalletSourcePerformance) _then) = __$PalletSourcePerformanceCopyWithImpl;
@override @useResult
$Res call({
 String source, int totalPallets, double totalCost, double totalRevenue, double totalProfit, double roi, double averageProfitPerPallet
});




}
/// @nodoc
class __$PalletSourcePerformanceCopyWithImpl<$Res>
    implements _$PalletSourcePerformanceCopyWith<$Res> {
  __$PalletSourcePerformanceCopyWithImpl(this._self, this._then);

  final _PalletSourcePerformance _self;
  final $Res Function(_PalletSourcePerformance) _then;

/// Create a copy of PalletSourcePerformance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? totalPallets = null,Object? totalCost = null,Object? totalRevenue = null,Object? totalProfit = null,Object? roi = null,Object? averageProfitPerPallet = null,}) {
  return _then(_PalletSourcePerformance(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,totalPallets: null == totalPallets ? _self.totalPallets : totalPallets // ignore: cast_nullable_to_non_nullable
as int,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalProfit: null == totalProfit ? _self.totalProfit : totalProfit // ignore: cast_nullable_to_non_nullable
as double,roi: null == roi ? _self.roi : roi // ignore: cast_nullable_to_non_nullable
as double,averageProfitPerPallet: null == averageProfitPerPallet ? _self.averageProfitPerPallet : averageProfitPerPallet // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
