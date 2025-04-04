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
  /// Takes the pallet ID and new status.
  /// If status is changed to processed, it will get the user's preferred allocation method
  /// from settings and pass it to the repository.
  Future<Result<Pallet>> updateStatus({
    required String palletId,
    required PalletStatus newStatus,
  }) async {
    // If we're setting to processed, get the user's preferred allocation method
    String? allocationMethod;
    if (newStatus == PalletStatus.processed) {
      final settingsResult = await _userSettingsRepository.getUserSettings();
      allocationMethod = settingsResult.fold(
        (settings) => settings?.costAllocationMethod?.toString() ?? 'even',
        (error) => 'even' // Default to 'even' if we can't get user settings
      );
    }
    
    // Call the repository to update the pallet status
    final result = await _palletRepository.updatePalletStatus(
      palletId: palletId,
      status: newStatus,
      allocationMethod: allocationMethod,
    );
    
    return result;
  }
  
  /// Convenience method to mark a pallet as processed.
  Future<Result<Pallet>> markAsProcessed({
    required String palletId,
  }) {
    return updateStatus(
      palletId: palletId,
      newStatus: PalletStatus.processed,
    );
  }
  
  /// Convenience method to archive a pallet.
  Future<Result<Pallet>> markAsArchived(String palletId) {
    return updateStatus(
      palletId: palletId,
      newStatus: PalletStatus.archived,
    );
  }
  
  /// Convenience method to mark a pallet as in progress (typically for reverting).
  Future<Result<Pallet>> markAsInProgress(String palletId) {
    return updateStatus(
      palletId: palletId,
      newStatus: PalletStatus.inProgress,
    );
  }
} 