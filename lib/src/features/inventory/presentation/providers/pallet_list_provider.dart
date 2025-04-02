import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';

/// Notifier responsible for managing the state of the pallet list.
///
/// It fetches pallets using the [PalletRepository] and handles loading, data,
/// and error states.
class PalletListNotifier extends AsyncNotifier<List<Pallet>> {
  late final PalletRepository _palletRepository;

  @override
  Future<List<Pallet>> build() async {
    _palletRepository = ref.watch(palletRepositoryProvider);
    // Initial fetch of pallets
    return _fetchPallets();
  }

  Future<List<Pallet>> _fetchPallets() async {
    // Corrected repository method name
    final result = await _palletRepository.getAllPallets();
    
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

  // --- Methods for adding, updating, deleting pallets will be added later ---

  // Example: Add Pallet (To be implemented in Part 5.3)
  // Future<void> addPallet(Pallet newPallet) async {
  //   state = const AsyncValue.loading(); // Optional: Show loading state during add
  //   final result = await _palletRepository.addPallet(newPallet);
  //   await result.when(
  //     success: (createdPalletId) async {
  //       // Refresh the list to include the new pallet
  //       await refreshPallets();
  //       // Or optimistically update the state:
  //       // state = AsyncData([...state.value!, createdPallet]); // Need full pallet data
  //     },
  //     failure: (exception) {
  //       state = AsyncError(exception, StackTrace.current);
  //     },
  //   );
  // }
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