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
        // Re-throw the specific exception to be handled by AsyncValue.error
        throw result.error ?? AppException('Unknown error fetching pallets');
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
    'supplier': 'Amazon',
    'type': 'Returns',
    'cost': 500.0,
    'purchase_date': '2023-10-15T10:00:00.000Z',
  },
  {
    'id': 'p2',
    'supplier': 'Walmart',
    'type': 'Overstock',
    'cost': 750.0,
    'purchase_date': '2023-11-20T14:30:00.000Z',
  },
  {
    'id': 'p3',
    'supplier': 'Target',
    'type': 'Liquidation',
    'cost': 300.0,
    'purchase_date': '2023-12-05T09:15:00.000Z',
  }
];

// Temporary simple model class for UI testing
class SimplePallet {
  final String id;
  final String? supplier;
  final String? type;
  final double cost;
  final DateTime? purchaseDate;
  
  SimplePallet({
    required this.id,
    this.supplier,
    this.type,
    required this.cost,
    this.purchaseDate,
  });
  
  factory SimplePallet.fromJson(Map<String, dynamic> json) {
    return SimplePallet(
      id: json['id'] as String,
      supplier: json['supplier'] as String?,
      type: json['type'] as String?,
      cost: json['cost'] as double,
      purchaseDate: json['purchase_date'] != null 
        ? DateTime.parse(json['purchase_date'] as String)
        : null,
    );
  }
}

// Mock provider that returns fixed data
final palletListProvider = FutureProvider<List<SimplePallet>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));
  
  // Return mock data
  return _mockPallets.map((json) => SimplePallet.fromJson(json)).toList();
}); 