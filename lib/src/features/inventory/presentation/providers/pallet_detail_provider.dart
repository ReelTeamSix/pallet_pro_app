import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/services/pallet_status_manager.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/providers/user_settings_repository_provider.dart';

/// Notifier responsible for managing a single pallet's state
class PalletDetailNotifier extends FamilyAsyncNotifier<Pallet?, String> {
  late final PalletRepository _palletRepository;
  late final UserSettingsRepository _userSettingsRepository;
  late final PalletStatusManager _statusManager;

  @override
  Future<Pallet?> build(String palletId) async {
    _palletRepository = ref.watch(palletRepositoryProvider);
    _userSettingsRepository = ref.watch(userSettingsRepositoryProvider);
    _statusManager = ref.watch(palletStatusManagerProvider);
    return _fetchPallet(palletId);
  }
  
  Future<Pallet?> _fetchPallet(String palletId) async {
    final result = await _palletRepository.getPalletById(palletId);
    
    if (result.isSuccess) {
      return result.value;
    } else {
      throw result.error ?? UnexpectedException('Unknown error fetching pallet');
    }
  }
  
  Future<void> refreshPallet() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPallet(arg));
  }

  /// Updates the pallet's status and optionally triggers cost allocation
  /// if the status is changed to 'processed'.
  /// Uses the centralized PalletStatusManager for the actual logic.
  Future<Result<Pallet>> updateStatus({
    required PalletStatus newStatus,
    bool shouldAllocateCosts = true,
  }) async {
    // Update state to loading
    state = const AsyncValue.loading();
    
    // Call the status manager to update the status
    final result = await _statusManager.updateStatus(
      palletId: arg,
      newStatus: newStatus,
      shouldAllocateCosts: shouldAllocateCosts,
    );
    
    // Update state based on result
    if (result.isSuccess) {
      state = AsyncValue.data(result.value);
      
      // Also invalidate the pallet list provider since the status has changed
      ref.invalidate(palletListProvider);
      
      return Result.success(result.value);
    } else {
      state = AsyncValue.error(
        result.error ?? UnexpectedException('Unknown error updating pallet status'),
        StackTrace.current
      );
      return Result.failure(result.error!);
    }
  }

  /// Convenience method to mark a pallet as processed, triggering cost allocation
  Future<Result<Pallet>> markAsProcessed({bool shouldAllocateCosts = true}) {
    return _statusManager.markAsProcessed(
      palletId: arg,
      shouldAllocateCosts: shouldAllocateCosts,
    ).then((result) {
      if (result.isSuccess) {
        state = AsyncValue.data(result.value);
        ref.invalidate(palletListProvider);
      } else {
        state = AsyncValue.error(
          result.error ?? UnexpectedException('Unknown error processing pallet'),
          StackTrace.current
        );
      }
      return result;
    });
  }

  /// Convenience method to archive a pallet
  Future<Result<Pallet>> markAsArchived() {
    return _statusManager.markAsArchived(arg).then((result) {
      if (result.isSuccess) {
        state = AsyncValue.data(result.value);
        ref.invalidate(palletListProvider);
      } else {
        state = AsyncValue.error(
          result.error ?? UnexpectedException('Unknown error archiving pallet'),
          StackTrace.current
        );
      }
      return result;
    });
  }

  /// Convenience method to mark a pallet as in progress (typically for reverting)
  Future<Result<Pallet>> markAsInProgress() {
    return _statusManager.markAsInProgress(arg).then((result) {
      if (result.isSuccess) {
        state = AsyncValue.data(result.value);
        ref.invalidate(palletListProvider);
      } else {
        state = AsyncValue.error(
          result.error ?? UnexpectedException('Unknown error setting pallet to in-progress'),
          StackTrace.current
        );
      }
      return result;
    });
  }

  // Mock versions for testing
  /// MOCK: Marks the pallet as processed.
  Future<void> mockMarkAsProcessed() async {
    // In a real implementation, this would update the pallet status
    // and potentially allocate costs
    print('MOCK: Marking pallet as processed: ${arg}');
    
    // Check if current state has a value
    if (state.hasValue && state.value != null) {
      // Simulate successful update
      state = AsyncValue.data(state.value!.copyWith(
        status: PalletStatus.processed
      ));
    }
  }
  
  /// MOCK: Marks the pallet as archived.
  Future<void> mockMarkAsArchived() async {
    // In a real implementation, this would update the pallet status
    print('MOCK: Marking pallet as archived: ${arg}');
    
    // Check if current state has a value
    if (state.hasValue && state.value != null) {
      // Simulate successful update
      state = AsyncValue.data(state.value!.copyWith(
        status: PalletStatus.archived
      ));
    }
  }
}

/// Provider for accessing a specific pallet by ID
final palletDetailNotifierProvider = AsyncNotifierProviderFamily<PalletDetailNotifier, Pallet?, String>(
  () => PalletDetailNotifier()
);

/// Provider that directly creates a PalletDetailNotifier instance (for extension use)
final autoDisposeDetailNotifierProvider = AsyncNotifierProviderFamily<PalletDetailNotifier, Pallet?, String>(
  () => PalletDetailNotifier()
);

/// Simple provider for accessing pallet details by ID
final palletDetailProvider = FutureProvider.family<Pallet?, String>((ref, palletId) async {
  final repository = ref.watch(palletRepositoryProvider);
  final result = await repository.getPalletById(palletId);
  
  if (result.isSuccess) {
    return result.value;
  } else {
    throw result.error ?? UnexpectedException('Failed to fetch pallet');
  }
});

/// Mock provider for accessing pallet details by ID (for testing)
final palletDetailProviderMock = FutureProvider.family<SimplePallet?, String>((ref, palletId) async {
  // Use mock data from palletListProvider 
  final mockPallets = _mockPallets;
  
  // Find the pallet with the matching ID
  final palletData = mockPallets.firstWhere(
    (pallet) => pallet['id'] == palletId,
    orElse: () => throw NotFoundException('Pallet not found'),
  );
  
  return SimplePallet.fromJson(palletData);
});

/// Mock notifier for testing
class MockPalletDetailNotifier {
  final String palletId;
  
  MockPalletDetailNotifier(this.palletId);
  
  Future<void> mockMarkAsProcessed() async {
    print('MOCK: Marking pallet as processed: $palletId');
  }
  
  Future<void> mockMarkAsArchived() async {
    print('MOCK: Marking pallet as archived: $palletId');
  }
  
  Future<void> refreshPallet() async {
    print('MOCK: Refreshing pallet: $palletId');
  }
}

/// Provider for accessing the mock provider with an extension
final palletDetailProviderMockWithNotifier = Provider.family<MockPalletDetailNotifier, String>((ref, palletId) {
  return MockPalletDetailNotifier(palletId);
});

/// Extension to allow easier access to the notifier
extension PalletDetailProviderExtension on FutureProvider<SimplePallet?> {
  // Access to a mock notifier for testing (legacy support)
  PalletDetailNotifier get notifier {
    final palletId = this.name?.split('(').last.split(')').first ?? '';
    return PalletDetailNotifier();
  }
  
  // Get the provider for the real notifier
  AsyncNotifierProviderFamily<PalletDetailNotifier, Pallet?, String> get notifierProvider {
    return palletDetailNotifierProvider;
  }
}

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