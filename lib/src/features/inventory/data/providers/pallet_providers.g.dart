// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pallet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dummyHash() => r'0664ec3f1385d99d939b6b8a98c922c9a6cdebb4';

/// Dummy provider for testing generator
///
/// Copied from [dummy].
@ProviderFor(dummy)
final dummyProvider = AutoDisposeProvider<String>.internal(
  dummy,
  name: r'dummyProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dummyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DummyRef = AutoDisposeProviderRef<String>;
String _$palletRepositoryHash() => r'1810631f2441abbffd4660b9d173dd03c30dc106';

/// Provider for the Supabase implementation of PalletRepository.
///
/// Depends on the global Supabase client provider.
///
/// Copied from [palletRepository].
@ProviderFor(palletRepository)
final palletRepositoryProvider = AutoDisposeProvider<PalletRepository>.internal(
  palletRepository,
  name: r'palletRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$palletRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PalletRepositoryRef = AutoDisposeProviderRef<PalletRepository>;
String _$watchPalletsHash() => r'6ff71f6b52c20f1b94ef41e094766571746f8455';

/// Provider to watch the list of pallets for the current user.
///
/// Depends on the palletRepositoryProvider and the auth state provider.
///
/// Copied from [watchPallets].
@ProviderFor(watchPallets)
final watchPalletsProvider = AutoDisposeStreamProvider<List<Pallet>>.internal(
  watchPallets,
  name: r'watchPalletsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$watchPalletsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchPalletsRef = AutoDisposeStreamProviderRef<List<Pallet>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
