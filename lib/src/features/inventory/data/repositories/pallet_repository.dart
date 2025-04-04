import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
// Import custom exception/result types if defined
// import 'package:pallet_pro_app/src/core/exceptions/custom_exception.dart';
// import 'package:pallet_pro_app/src/core/utils/either.dart';

/// Abstract interface for managing Pallet data.
abstract class PalletRepository {
  /// Creates a new pallet.
  Future<Result<Pallet>> createPallet(Pallet pallet); // Or Future<Either<CustomException, Pallet>>

  /// Fetches a pallet by its ID.
  Future<Result<Pallet?>> getPalletById(String id); // Or Future<Either<CustomException, Pallet?>>

  /// Fetches all pallets, potentially filtered.
  Future<Result<List<Pallet>>> getAllPallets({
    String? sourceFilter,
    PalletStatus? statusFilter,
  }); // Or Future<Either<CustomException, List<Pallet>>>

  /// Updates an existing pallet.
  Future<Result<Pallet>> updatePallet(Pallet pallet); // Or Future<Either<CustomException, Pallet>>

  /// Updates a pallet's status, optionally triggering cost allocation if status is set to 'processed'
  Future<Result<Pallet>> updatePalletStatus({
    required String palletId,
    required PalletStatus newStatus,
    required bool shouldAllocateCosts,
    String? allocationMethod,
  });

  /// Deletes a pallet by its ID.
  Future<Result<void>> deletePallet(String id); // Or Future<Either<CustomException, void>>

  /// Gets distinct values for a specific field from all pallets belonging to the current user.
  /// 
  /// The field parameter should be a valid column name in the pallets table.
  /// Returns a list of unique non-null values for the specified field.
  Future<Result<List<String>>> getDistinctFieldValues(String field);

  // Add other specific methods as needed, e.g., searchPallets(String query)
} 