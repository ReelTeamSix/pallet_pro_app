// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSettings {

/// The user ID.
 String get userId;/// Whether the user has completed onboarding.
 bool get hasCompletedOnboarding;/// Whether to use dark mode.
 bool get useDarkMode;/// Whether to use biometric authentication.
 bool get useBiometricAuth;/// The cost allocation method.
 CostAllocationMethod get costAllocationMethod;/// Whether to show break-even price.
 bool get showBreakEvenPrice;/// The stale threshold in days.
 int get staleThresholdDays;/// The daily sales goal.
 double get dailySalesGoal;/// The weekly sales goal.
 double get weeklySalesGoal;/// The monthly sales goal.
 double get monthlySalesGoal;/// The yearly sales goal.
 double get yearlySalesGoal;/// The created at timestamp.
 DateTime? get createdAt;/// The updated at timestamp.
 DateTime? get updatedAt;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.hasCompletedOnboarding, hasCompletedOnboarding) || other.hasCompletedOnboarding == hasCompletedOnboarding)&&(identical(other.useDarkMode, useDarkMode) || other.useDarkMode == useDarkMode)&&(identical(other.useBiometricAuth, useBiometricAuth) || other.useBiometricAuth == useBiometricAuth)&&(identical(other.costAllocationMethod, costAllocationMethod) || other.costAllocationMethod == costAllocationMethod)&&(identical(other.showBreakEvenPrice, showBreakEvenPrice) || other.showBreakEvenPrice == showBreakEvenPrice)&&(identical(other.staleThresholdDays, staleThresholdDays) || other.staleThresholdDays == staleThresholdDays)&&(identical(other.dailySalesGoal, dailySalesGoal) || other.dailySalesGoal == dailySalesGoal)&&(identical(other.weeklySalesGoal, weeklySalesGoal) || other.weeklySalesGoal == weeklySalesGoal)&&(identical(other.monthlySalesGoal, monthlySalesGoal) || other.monthlySalesGoal == monthlySalesGoal)&&(identical(other.yearlySalesGoal, yearlySalesGoal) || other.yearlySalesGoal == yearlySalesGoal)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,hasCompletedOnboarding,useDarkMode,useBiometricAuth,costAllocationMethod,showBreakEvenPrice,staleThresholdDays,dailySalesGoal,weeklySalesGoal,monthlySalesGoal,yearlySalesGoal,createdAt,updatedAt);

@override
String toString() {
  return 'UserSettings(userId: $userId, hasCompletedOnboarding: $hasCompletedOnboarding, useDarkMode: $useDarkMode, useBiometricAuth: $useBiometricAuth, costAllocationMethod: $costAllocationMethod, showBreakEvenPrice: $showBreakEvenPrice, staleThresholdDays: $staleThresholdDays, dailySalesGoal: $dailySalesGoal, weeklySalesGoal: $weeklySalesGoal, monthlySalesGoal: $monthlySalesGoal, yearlySalesGoal: $yearlySalesGoal, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 String userId, bool hasCompletedOnboarding, bool useDarkMode, bool useBiometricAuth, CostAllocationMethod costAllocationMethod, bool showBreakEvenPrice, int staleThresholdDays, double dailySalesGoal, double weeklySalesGoal, double monthlySalesGoal, double yearlySalesGoal, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? hasCompletedOnboarding = null,Object? useDarkMode = null,Object? useBiometricAuth = null,Object? costAllocationMethod = null,Object? showBreakEvenPrice = null,Object? staleThresholdDays = null,Object? dailySalesGoal = null,Object? weeklySalesGoal = null,Object? monthlySalesGoal = null,Object? yearlySalesGoal = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,hasCompletedOnboarding: null == hasCompletedOnboarding ? _self.hasCompletedOnboarding : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
as bool,useDarkMode: null == useDarkMode ? _self.useDarkMode : useDarkMode // ignore: cast_nullable_to_non_nullable
as bool,useBiometricAuth: null == useBiometricAuth ? _self.useBiometricAuth : useBiometricAuth // ignore: cast_nullable_to_non_nullable
as bool,costAllocationMethod: null == costAllocationMethod ? _self.costAllocationMethod : costAllocationMethod // ignore: cast_nullable_to_non_nullable
as CostAllocationMethod,showBreakEvenPrice: null == showBreakEvenPrice ? _self.showBreakEvenPrice : showBreakEvenPrice // ignore: cast_nullable_to_non_nullable
as bool,staleThresholdDays: null == staleThresholdDays ? _self.staleThresholdDays : staleThresholdDays // ignore: cast_nullable_to_non_nullable
as int,dailySalesGoal: null == dailySalesGoal ? _self.dailySalesGoal : dailySalesGoal // ignore: cast_nullable_to_non_nullable
as double,weeklySalesGoal: null == weeklySalesGoal ? _self.weeklySalesGoal : weeklySalesGoal // ignore: cast_nullable_to_non_nullable
as double,monthlySalesGoal: null == monthlySalesGoal ? _self.monthlySalesGoal : monthlySalesGoal // ignore: cast_nullable_to_non_nullable
as double,yearlySalesGoal: null == yearlySalesGoal ? _self.yearlySalesGoal : yearlySalesGoal // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserSettings implements UserSettings {
  const _UserSettings({required this.userId, this.hasCompletedOnboarding = false, this.useDarkMode = false, this.useBiometricAuth = false, this.costAllocationMethod = CostAllocationMethod.average, this.showBreakEvenPrice = true, this.staleThresholdDays = 90, this.dailySalesGoal = 0, this.weeklySalesGoal = 0, this.monthlySalesGoal = 0, this.yearlySalesGoal = 0, this.createdAt, this.updatedAt});
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

/// The user ID.
@override final  String userId;
/// Whether the user has completed onboarding.
@override@JsonKey() final  bool hasCompletedOnboarding;
/// Whether to use dark mode.
@override@JsonKey() final  bool useDarkMode;
/// Whether to use biometric authentication.
@override@JsonKey() final  bool useBiometricAuth;
/// The cost allocation method.
@override@JsonKey() final  CostAllocationMethod costAllocationMethod;
/// Whether to show break-even price.
@override@JsonKey() final  bool showBreakEvenPrice;
/// The stale threshold in days.
@override@JsonKey() final  int staleThresholdDays;
/// The daily sales goal.
@override@JsonKey() final  double dailySalesGoal;
/// The weekly sales goal.
@override@JsonKey() final  double weeklySalesGoal;
/// The monthly sales goal.
@override@JsonKey() final  double monthlySalesGoal;
/// The yearly sales goal.
@override@JsonKey() final  double yearlySalesGoal;
/// The created at timestamp.
@override final  DateTime? createdAt;
/// The updated at timestamp.
@override final  DateTime? updatedAt;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.hasCompletedOnboarding, hasCompletedOnboarding) || other.hasCompletedOnboarding == hasCompletedOnboarding)&&(identical(other.useDarkMode, useDarkMode) || other.useDarkMode == useDarkMode)&&(identical(other.useBiometricAuth, useBiometricAuth) || other.useBiometricAuth == useBiometricAuth)&&(identical(other.costAllocationMethod, costAllocationMethod) || other.costAllocationMethod == costAllocationMethod)&&(identical(other.showBreakEvenPrice, showBreakEvenPrice) || other.showBreakEvenPrice == showBreakEvenPrice)&&(identical(other.staleThresholdDays, staleThresholdDays) || other.staleThresholdDays == staleThresholdDays)&&(identical(other.dailySalesGoal, dailySalesGoal) || other.dailySalesGoal == dailySalesGoal)&&(identical(other.weeklySalesGoal, weeklySalesGoal) || other.weeklySalesGoal == weeklySalesGoal)&&(identical(other.monthlySalesGoal, monthlySalesGoal) || other.monthlySalesGoal == monthlySalesGoal)&&(identical(other.yearlySalesGoal, yearlySalesGoal) || other.yearlySalesGoal == yearlySalesGoal)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,hasCompletedOnboarding,useDarkMode,useBiometricAuth,costAllocationMethod,showBreakEvenPrice,staleThresholdDays,dailySalesGoal,weeklySalesGoal,monthlySalesGoal,yearlySalesGoal,createdAt,updatedAt);

@override
String toString() {
  return 'UserSettings(userId: $userId, hasCompletedOnboarding: $hasCompletedOnboarding, useDarkMode: $useDarkMode, useBiometricAuth: $useBiometricAuth, costAllocationMethod: $costAllocationMethod, showBreakEvenPrice: $showBreakEvenPrice, staleThresholdDays: $staleThresholdDays, dailySalesGoal: $dailySalesGoal, weeklySalesGoal: $weeklySalesGoal, monthlySalesGoal: $monthlySalesGoal, yearlySalesGoal: $yearlySalesGoal, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 String userId, bool hasCompletedOnboarding, bool useDarkMode, bool useBiometricAuth, CostAllocationMethod costAllocationMethod, bool showBreakEvenPrice, int staleThresholdDays, double dailySalesGoal, double weeklySalesGoal, double monthlySalesGoal, double yearlySalesGoal, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? hasCompletedOnboarding = null,Object? useDarkMode = null,Object? useBiometricAuth = null,Object? costAllocationMethod = null,Object? showBreakEvenPrice = null,Object? staleThresholdDays = null,Object? dailySalesGoal = null,Object? weeklySalesGoal = null,Object? monthlySalesGoal = null,Object? yearlySalesGoal = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserSettings(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,hasCompletedOnboarding: null == hasCompletedOnboarding ? _self.hasCompletedOnboarding : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
as bool,useDarkMode: null == useDarkMode ? _self.useDarkMode : useDarkMode // ignore: cast_nullable_to_non_nullable
as bool,useBiometricAuth: null == useBiometricAuth ? _self.useBiometricAuth : useBiometricAuth // ignore: cast_nullable_to_non_nullable
as bool,costAllocationMethod: null == costAllocationMethod ? _self.costAllocationMethod : costAllocationMethod // ignore: cast_nullable_to_non_nullable
as CostAllocationMethod,showBreakEvenPrice: null == showBreakEvenPrice ? _self.showBreakEvenPrice : showBreakEvenPrice // ignore: cast_nullable_to_non_nullable
as bool,staleThresholdDays: null == staleThresholdDays ? _self.staleThresholdDays : staleThresholdDays // ignore: cast_nullable_to_non_nullable
as int,dailySalesGoal: null == dailySalesGoal ? _self.dailySalesGoal : dailySalesGoal // ignore: cast_nullable_to_non_nullable
as double,weeklySalesGoal: null == weeklySalesGoal ? _self.weeklySalesGoal : weeklySalesGoal // ignore: cast_nullable_to_non_nullable
as double,monthlySalesGoal: null == monthlySalesGoal ? _self.monthlySalesGoal : monthlySalesGoal // ignore: cast_nullable_to_non_nullable
as double,yearlySalesGoal: null == yearlySalesGoal ? _self.yearlySalesGoal : yearlySalesGoal // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
