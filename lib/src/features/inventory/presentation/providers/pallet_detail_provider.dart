import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart';

/// Notifier responsible for managing a single pallet's state
class PalletDetailNotifier extends FamilyAsyncNotifier<Pallet?, String> {
  late final PalletRepository _palletRepository;

  @override
  Future<Pallet?> build(String palletId) async {
    _palletRepository = ref.watch(palletRepositoryProvider);
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
}

/// Provider for accessing a specific pallet by ID
final palletDetailNotifierProvider = AsyncNotifierProviderFamily<PalletDetailNotifier, Pallet?, String>(
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