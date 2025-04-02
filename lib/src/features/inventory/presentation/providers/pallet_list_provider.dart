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
// Removed _mockPallets list

// Temporary simple model class for UI testing
// Removed SimplePallet class definition

// Mock provider that returns fixed data
// Removed duplicate palletListProvider (FutureProvider) definition 