import 'package:pallet_pro_app/src/core/exceptions/database_exception.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_repository.dart';

/// Service class that centralizes all pallet status transition logic.
/// 
/// This class follows the DRY principle by providing a single implementation
/// of status transition methods that can be used by PalletListNotifier and
/// PalletDetailNotifier.
class PalletStatusManager {
  final PalletRepository _palletRepository;
  final UserSettingsRepository _userSettingsRepository;
  
  PalletStatusManager(this._palletRepository, this._userSettingsRepository);
  
  /// Updates the status of a pallet.
  ///
  /// Takes the pallet ID, new status, and whether to allocate costs to items.
  /// If allocating costs, it will get the user's preferred allocation method
  /// from settings.
  Future<Result<Pallet>> updateStatus({
    required String palletId,
    required PalletStatus newStatus,
    required bool shouldAllocateCosts,
  }) async {
    // If we need to allocate costs, get the user's preferred allocation method
    String? allocationMethod;
    if (newStatus == PalletStatus.processed && shouldAllocateCosts) {
      final settingsResult = await _userSettingsRepository.getUserSettings();
      allocationMethod = settingsResult.fold(
        (settings) => settings?.costAllocationMethod?.toString() ?? 'even',
        (error) => 'even' // Default to 'even' if we can't get user settings
      );
    }
    
    // Call the repository to update the pallet status
    final result = await _palletRepository.updatePalletStatus(
      palletId: palletId,
      newStatus: newStatus,
      shouldAllocateCosts: shouldAllocateCosts,
      allocationMethod: allocationMethod,
    );
    
    return result;
  }
  
  /// Convenience method to mark a pallet as processed.
  ///
  /// Defaults to allocating costs to items when processing.
  Future<Result<Pallet>> markAsProcessed({
    required String palletId,
    bool shouldAllocateCosts = true,
  }) {
    return updateStatus(
      palletId: palletId,
      newStatus: PalletStatus.processed,
      shouldAllocateCosts: shouldAllocateCosts,
    );
  }
  
  /// Convenience method to archive a pallet.
  Future<Result<Pallet>> markAsArchived(String palletId) {
    return updateStatus(
      palletId: palletId,
      newStatus: PalletStatus.archived,
      shouldAllocateCosts: false, // No need to allocate costs when archiving
    );
  }
  
  /// Convenience method to mark a pallet as in progress (typically for reverting).
  Future<Result<Pallet>> markAsInProgress(String palletId) {
    return updateStatus(
      palletId: palletId,
      newStatus: PalletStatus.inProgress,
      shouldAllocateCosts: false, // No need to allocate costs when setting as in-progress
    );
  }
} 