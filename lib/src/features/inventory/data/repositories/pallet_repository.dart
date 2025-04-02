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

  /// Fetches all pallets (potentially with pagination/filtering later).
  Future<Result<List<Pallet>>> getAllPallets(); // Or Future<Either<CustomException, List<Pallet>>>

  /// Updates an existing pallet.
  Future<Result<Pallet>> updatePallet(Pallet pallet); // Or Future<Either<CustomException, Pallet>>

  /// Deletes a pallet by its ID.
  Future<Result<void>> deletePallet(String id); // Or Future<Either<CustomException, void>>

  // Add other specific methods as needed, e.g., searchPallets(String query)
} 