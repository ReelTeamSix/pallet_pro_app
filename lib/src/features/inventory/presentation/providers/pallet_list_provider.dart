import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/result/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/providers/user_settings_repository_provider.dart';

/// Notifier responsible for managing the state of the pallet list.
///
/// It fetches pallets using the [PalletRepository] and handles loading, data,
/// and error states.
class PalletListNotifier extends AsyncNotifier<List<Pallet>> {
  late final PalletRepository _palletRepository;
  late final UserSettingsRepository _userSettingsRepository;
  
  // Current filter states
  PalletStatus? _statusFilter;
  String? _sourceFilter;

  PalletStatus? get statusFilter => _statusFilter;
  String? get sourceFilter => _sourceFilter;

  @override
  Future<List<Pallet>> build() async {
    _palletRepository = ref.watch(palletRepositoryProvider);
    _userSettingsRepository = ref.watch(userSettingsRepositoryProvider);
    // Initial fetch of pallets
    return _fetchPallets();
  }

  Future<List<Pallet>> _fetchPallets() async {
    // Fetch pallets with applied filters
    final result = await _palletRepository.getAllPallets(
      sourceFilter: _sourceFilter,
      statusFilter: _statusFilter,
    );
    
    if (result.isSuccess) {
        return result.value;
    } else {
        // Re-throw the specific exception or a fallback UnexpectedException
        throw result.error ?? UnexpectedException('Unknown error fetching pallets');
    }
  }

  /// Refreshes the pallet list.
  Future<void> refreshPallets() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPallets());
  }

  /// Sets filters and refreshes the pallet list.
  Future<void> setFilters({String? statusFilter, String? sourceFilter}) async {
    // Only refresh if filters actually changed
    bool filtersChanged = false;
    
    if (statusFilter != _statusFilter?.name) {
      _statusFilter = statusFilter != null ? _stringToPalletStatus(statusFilter) : null;
      filtersChanged = true;
    }
    
    if (sourceFilter != _sourceFilter) {
      _sourceFilter = sourceFilter;
      filtersChanged = true;
    }
    
    if (filtersChanged) {
      await refreshPallets();
    }
  }
  
  // Helper method to convert string to PalletStatus
  PalletStatus? _stringToPalletStatus(String status) {
    switch (status.toLowerCase()) {
      case 'processed':
        return PalletStatus.processed;
      case 'archived':
        return PalletStatus.archived;
      case 'in_progress':
      default:
        return PalletStatus.inProgress;
    }
  }

  /// Clears all filters and refreshes the pallet list.
  Future<void> clearFilters() async {
    if (_statusFilter != null || _sourceFilter != null) {
      _statusFilter = null;
      _sourceFilter = null;
      await refreshPallets();
    }
  }

  /// Adds a new pallet to the database.
  /// 
  /// Updates the state accordingly, either with an optimistic update
  /// showing the new pallet immediately, or refreshing the entire list
  /// after successful creation.
  Future<Result<Pallet>> addPallet(Pallet newPallet) async {
    state = const AsyncValue.loading();
    final result = await _palletRepository.createPallet(newPallet);
    
    return result.when(
      success: (createdPallet) async {
        // Refresh the list to include the new pallet
        await refreshPallets();
        return Result.success(createdPallet);
      },
      failure: (exception) {
        state = AsyncError(exception, StackTrace.current);
        return Result.failure(exception);
      },
    );
  }

  /// Updates the status of a pallet.
  /// If the new status is 'processed', optionally triggers cost allocation.
  Future<Result<Pallet>> updatePalletStatus({
    required String palletId, 
    required PalletStatus newStatus,
    bool shouldAllocateCosts = true,
  }) async {
    state = const AsyncValue.loading();
    
    // If we need to allocate costs, get the user's preferred allocation method
    String? allocationMethod;
    if (newStatus == PalletStatus.processed && shouldAllocateCosts) {
      final settingsResult = await _userSettingsRepository.getUserSettings();
      allocationMethod = settingsResult.fold(
        (settings) => settings?.costAllocationMethod?.toString() ?? 'even',
        (error) => 'even' // Default to 'even' if we can't get user settings
      );
    }
    
    final result = await _palletRepository.updatePalletStatus(
      palletId: palletId,
      newStatus: newStatus,
      shouldAllocateCosts: shouldAllocateCosts,
      allocationMethod: allocationMethod,
    );
    
    return result.when(
      success: (updatedPallet) async {
        // Refresh the list to reflect the updated pallet
        await refreshPallets();
        return Result.success(updatedPallet);
      },
      failure: (exception) {
        state = AsyncError(exception, StackTrace.current);
        return Result.failure(exception);
      },
    );
  }
}

/// Provider for the [PalletListNotifier].
///
/// Exposes the asynchronous state ([AsyncValue]) of the pallet list.
final palletListProvider =
    AsyncNotifierProvider<PalletListNotifier, List<Pallet>>(
  PalletListNotifier.new,
);

// TEMPORARY: Mock data for UI testing until model issues are fixed
final _mockPallets = [
  {
    'id': 'p1',
    'name': 'Electronics Pallet #1',
    'description': 'Mixed lot of consumer electronics',
    'purchase_price': 450.00,
    'purchase_date': '2023-10-15T00:00:00.000Z',
    'source': 'ABC Liquidators',
    'status': 'active',
    'created_at': '2023-10-16T10:00:00.000Z',
  },
  {
    'id': 'p2',
    'name': 'Clothing Pallet #1',
    'description': 'Assorted brand name clothing items',
    'purchase_price': 350.00,
    'purchase_date': '2023-11-20T00:00:00.000Z',
    'source': 'Fashion Wholesale',
    'status': 'active',
    'created_at': '2023-11-21T09:30:00.000Z',
  },
  {
    'id': 'p3',
    'name': 'Home Goods Pallet',
    'description': 'Kitchen and bathroom items',
    'purchase_price': 275.50,
    'purchase_date': '2023-12-05T00:00:00.000Z',
    'source': 'Home Liquidation Co',
    'status': 'active',
    'created_at': '2023-12-06T14:00:00.000Z',
  }
];

// Temporary simple model class for UI testing
class SimplePallet {
  final String id;
  final String name;
  final String? description;
  final double? purchasePrice;
  final DateTime? purchaseDate;
  final String? source;
  final String status;
  final DateTime? createdAt;
  final double cost;
  final String? supplier;
  final String? type;
  
  SimplePallet({
    required this.id,
    required this.name,
    this.description,
    this.purchasePrice,
    this.purchaseDate,
    this.source,
    required this.status,
    this.createdAt,
    required this.cost,
    this.supplier,
    this.type,
  });
  
  factory SimplePallet.fromJson(Map<String, dynamic> json) {
    return SimplePallet(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      purchasePrice: json['purchase_price'] as double?,
      purchaseDate: json['purchase_date'] != null 
        ? DateTime.parse(json['purchase_date'] as String)
        : null,
      source: json['source'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String)
        : null,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      supplier: json['supplier'] as String?,
      type: json['type'] as String?,
    );
  }
}

// Mock provider for SimplePallet as an alternative to the main provider
final simplePalletListProvider = FutureProvider<List<SimplePallet>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));
  
  // Return mock data
  return _mockPallets.map((json) => SimplePallet.fromJson(json)).toList();
});

/// Extension to allow easier access to the notifier
extension SimplePalletListProviderExtension on FutureProvider<List<SimplePallet>> {
  AsyncNotifierProvider<PalletListNotifier, List<Pallet>> get notifierProvider {
    return palletListProvider;
  }
} 