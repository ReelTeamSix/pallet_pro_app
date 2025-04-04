import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:flutter/foundation.dart';

/// Enum for filter types
enum Filter {
  name,
  location,
  status,
}

/// Provider for accessing a list of pallets
final palletListProvider = StateNotifierProvider<PalletListNotifier, AsyncValue<List<Pallet>>>((ref) {
  final repository = ref.watch(palletRepositoryProvider);
  return PalletListNotifier(repository);
});

/// State notifier for managing the list of pallets
class PalletListNotifier extends StateNotifier<AsyncValue<List<Pallet>>> {
  final PalletRepository _palletRepository;
  List<SimplePallet> _allPallets = [];
  Map<Filter, String> _activeFilters = {};

  PalletListNotifier(this._palletRepository) : super(const AsyncValue.loading()) {
    refreshPallets();
  }

  /// Refreshes the list of pallets from the repository
  Future<void> refreshPallets() async {
    state = const AsyncValue.loading();

    try {
      final result = await _palletRepository.getAllPallets();
      
      if (result.isSuccess) {
        final pallets = result.value;
        _allPallets = pallets.map((p) => SimplePallet.fromPallet(p)).toList();
        _applyFilters();
      } else {
        state = AsyncValue.error(
          result.error ?? UnexpectedException('Unknown error fetching pallets'),
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Adds a new pallet to the repository
  Future<Result<Pallet>> addPallet(Pallet pallet) async {
    try {
      final result = await _palletRepository.addPallet(pallet);
      
      if (result.isSuccess) {
        await refreshPallets();
        return Result.success(result.value);
      } else {
        return Result.failure(result.error!);
      }
    } catch (e) {
      return Result.failure(e is AppException ? e : UnexpectedException(e.toString()));
    }
  }

  /// Sets a specific filter value
  void setFilter(Filter filter, String value) {
    if (value.isEmpty) {
      _activeFilters.remove(filter);
    } else {
      _activeFilters[filter] = value;
    }
    _applyFilters();
  }

  /// Sets multiple filters at once
  void setFilters({
    String? nameFilter,
    String? sourceFilter,
    String? statusFilter,
  }) {
    if (nameFilter != null) {
      if (nameFilter.isEmpty) {
        _activeFilters.remove(Filter.name);
      } else {
        _activeFilters[Filter.name] = nameFilter;
      }
    }
    
    if (sourceFilter != null) {
      if (sourceFilter.isEmpty) {
        _activeFilters.remove(Filter.location);
      } else {
        _activeFilters[Filter.location] = sourceFilter;
      }
    }
    
    if (statusFilter != null) {
      if (statusFilter.isEmpty) {
        _activeFilters.remove(Filter.status);
      } else {
        _activeFilters[Filter.status] = statusFilter;
      }
    }
    
    _applyFilters();
  }

  /// Clears all active filters
  void clearFilters() {
    _activeFilters.clear();
    _applyFilters();
  }

  void _applyFilters() {
    List<SimplePallet> filteredPallets = List.from(_allPallets);
    
    _activeFilters.forEach((filter, value) {
      switch (filter) {
        case Filter.name:
          filteredPallets = filteredPallets.where(
            (p) => p.name.toLowerCase().contains(value.toLowerCase())
          ).toList();
          break;
        case Filter.location:
          // Use source as location for filtering
          filteredPallets = filteredPallets.where(
            (p) => p.source.toLowerCase().contains(value.toLowerCase())
          ).toList();
          break;
        case Filter.status:
          filteredPallets = filteredPallets.where(
            (p) => p.status.toLowerCase() == value.toLowerCase()
          ).toList();
          break;
      }
    });
    
    state = AsyncValue.data(filteredPallets.map((p) => p.toPallet()).toList());
  }
}

/// A simplified pallet model for the UI
class SimplePallet {
  final String id;
  final String name;
  final String supplier;
  final String source;
  final String type;
  final double cost;
  final DateTime purchaseDate;
  final DateTime createdAt;
  final String status;

  SimplePallet({
    required this.id,
    required this.name,
    required this.supplier,
    required this.source,
    required this.type,
    required this.cost,
    required this.purchaseDate,
    required this.createdAt,
    required this.status,
  });

  factory SimplePallet.fromJson(Map<String, dynamic> json) {
    return SimplePallet(
      id: json['id'] as String,
      name: json['name'] as String,
      supplier: json['supplier'] as String? ?? '',
      source: json['source'] as String? ?? '',
      type: json['type'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'in_progress',
    );
  }

  factory SimplePallet.fromPallet(Pallet pallet) {
    return SimplePallet(
      id: pallet.id,
      name: pallet.name,
      supplier: pallet.supplier ?? '',
      source: pallet.source ?? '',
      type: pallet.type ?? '',
      cost: pallet.cost,
      purchaseDate: pallet.purchaseDate ?? DateTime.now(),
      createdAt: pallet.createdAt ?? DateTime.now(),
      status: pallet.status.name,
    );
  }

  Pallet toPallet() {
    PalletStatus palletStatus;
    
    switch (status) {
      case 'inProgress':
      case 'in_progress':
        palletStatus = PalletStatus.inProgress;
        break;
      case 'processed':
        palletStatus = PalletStatus.processed;
        break;
      case 'archived':
        palletStatus = PalletStatus.archived;
        break;
      default:
        palletStatus = PalletStatus.inProgress;
    }
    
    return Pallet(
      id: id,
      name: name,
      supplier: supplier,
      source: source,
      type: type,
      cost: cost,
      purchaseDate: purchaseDate,
      createdAt: createdAt,
      status: palletStatus,
    );
  }
}

/// Mock provider for testing
final palletListProviderMock = Provider<List<SimplePallet>>((ref) {
  return _mockPallets.map((palletData) => SimplePallet.fromJson(palletData)).toList();
});

// Mock data source for testing
final List<Map<String, dynamic>> _mockPallets = [
  {
    'id': 'PAL001',
    'name': 'Clothing Pallet',
    'supplier': 'GoodWill Industries',
    'source': 'Donation Center',
    'type': 'Clothing',
    'cost': 200.00,
    'purchaseDate': '2023-09-15',
    'createdAt': '2023-09-15',
    'status': 'in_progress',
  },
  {
    'id': 'PAL002',
    'name': 'Electronics Pallet',
    'supplier': 'Liquidation Co',
    'source': 'Warehouse',
    'type': 'Electronics',
    'cost': 500.00,
    'purchaseDate': '2023-10-01',
    'createdAt': '2023-10-01',
    'status': 'processed',
  },
  {
    'id': 'PAL003',
    'name': 'Home Goods Pallet',
    'supplier': 'Amazon Returns',
    'source': 'Online Returns',
    'type': 'Home Goods',
    'cost': 350.00,
    'purchaseDate': '2023-10-15',
    'createdAt': '2023-10-15',
    'status': 'archived',
  },
];

class MockPalletListNotifier extends StateNotifier<AsyncValue<List<Pallet>>> 
    implements PalletListNotifier {
  
  // Implement required fields from PalletListNotifier
  @override
  final PalletRepository _palletRepository;
  @override
  List<SimplePallet> _allPallets = [];
  @override
  Map<Filter, String> _activeFilters = {};
  
  // Initialize with mock data
  MockPalletListNotifier(this._palletRepository) : super(AsyncValue.data(_mockPalletData));
  
  @override
  Future<void> refreshPallets() async {
    // No-op for mock
    return;
  }
  
  @override
  Future<Result<Pallet>> addPallet(Pallet pallet) async {
    // Add to mock list and return success
    final newPallet = pallet.copyWith(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
    );
    
    _mockPalletData.add(newPallet);
    state = AsyncValue.data(_mockPalletData);
    
    return Result.success(newPallet);
  }
  
  @override
  void setFilter(Filter filter, String value) {
    // No-op for mock
  }
  
  @override
  void setFilters({
    String? nameFilter,
    String? sourceFilter,
    String? statusFilter,
  }) {
    // No-op for mock
  }
  
  @override
  void clearFilters() {
    // No-op for mock
  }
  
  @override
  void _applyFilters() {
    // No-op for mock
  }
  
  // Mock data
  static List<Pallet> _mockPalletData = [
    Pallet(
      id: 'mock-1',
      name: 'Wholesale Liquidation (Mock)',
      supplier: 'Big Box Liquidators',
      source: 'Online Auction',
      type: 'Mixed Electronics',
      cost: 1250.00,
      purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      status: PalletStatus.inProgress,
    ),
    Pallet(
      id: 'mock-2',
      name: 'Amazon Returns (Mock)',
      supplier: 'Returns R Us',
      source: 'Warehouse Sale',
      type: 'Amazon Customer Returns',
      cost: 850.00,
      purchaseDate: DateTime.now().subtract(const Duration(days: 15)),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      status: PalletStatus.processed,
    ),
  ];
} 