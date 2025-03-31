import '../models/pallet.dart';

/// Abstract interface for managing Pallet data.
///
/// This defines the contract for data operations related to pallets,
/// separating the data access logic from the UI/business logic.
abstract class PalletRepository {
  /// Fetches a stream of all pallets belonging to a specific user.
  Stream<List<Pallet>> watchPallets(String userId);

  /// Fetches a single pallet by its unique ID.
  /// Returns null if the pallet is not found.
  Future<Pallet?> fetchPalletById(String palletId);

  /// Adds a new pallet to the data source.
  Future<void> addPallet(Pallet pallet);

  /// Updates an existing pallet in the data source.
  Future<void> updatePallet(Pallet pallet);

  /// Deletes a pallet from the data source using its ID.
  Future<void> deletePallet(String palletId);
} 