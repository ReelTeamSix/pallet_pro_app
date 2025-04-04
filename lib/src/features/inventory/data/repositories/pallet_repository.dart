import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
// Import custom exception/result types if defined
// import 'package:pallet_pro_app/src/core/exceptions/custom_exception.dart';
// import 'package:pallet_pro_app/src/core/utils/either.dart';

/// Interface for pallet repository operations
abstract class PalletRepository {
  /// Get all pallets for the current user
  Future<Result<List<Pallet>>> getAllPallets({Map<String, dynamic>? filters});
  
  /// Get a single pallet by ID
  Future<Result<Pallet>> getPalletById(String id);
  
  /// Add a new pallet
  Future<Result<Pallet>> addPallet(Pallet pallet);
  
  /// Update an existing pallet
  Future<Result<Pallet>> updatePallet(Pallet pallet);
  
  /// Delete a pallet by ID
  Future<Result<void>> deletePallet(String id);

  /// Fetches all pallets, potentially filtered.
  Future<Result<List<Pallet>>> getPallets({
    String? nameFilter,
    String? sourceFilter,
    String? supplierFilter,
    String? typeFilter,
    PalletStatus? statusFilter,
  });

  /// Updates a pallet's status, optionally triggering cost allocation if status is set to 'processed'
  Future<Result<Pallet>> updatePalletStatus({
    required String palletId,
    required PalletStatus status,
    String? allocationMethod,
  });

  /// Gets distinct values for a specific field from all pallets belonging to the current user.
  /// 
  /// The field parameter should be a valid column name in the pallets table.
  /// Returns a list of unique non-null values for the specified field.
  Future<Result<List<String>>> getDistinctFieldValues(String fieldName);

  // Add other specific methods as needed, e.g., searchPallets(String query)
} 