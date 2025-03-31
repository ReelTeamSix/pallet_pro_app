import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';

/// Repository interface for pallet operations.
abstract class PalletRepository {
  /// Fetches all pallets for the current user.
  Future<List<Pallet>> fetchPallets();

  /// Fetches a single pallet by its ID.
  Future<Pallet?> fetchPalletById(int palletId);

  /// Creates a new pallet.
  /// [pallet] contains the data for the new pallet (excluding id, user_id, created_at).
  Future<Pallet> createPallet(Pallet pallet);

  /// Updates an existing pallet.
  Future<Pallet> updatePallet(Pallet pallet);

  /// Deletes a pallet by its ID.
  /// Note: Consider implications if items are associated with this pallet.
  /// The backend might prevent deletion (FK constraint) or cascade delete.
  Future<void> deletePallet(int palletId);
} 