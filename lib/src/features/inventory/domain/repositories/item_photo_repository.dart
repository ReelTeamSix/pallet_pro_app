import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';

/// Repository interface for item photo metadata operations.
/// Note: This typically handles database records, not file storage operations.
abstract class ItemPhotoRepository {
  /// Fetches all photo metadata records associated with a specific item.
  Future<List<ItemPhoto>> fetchPhotosForItem(int itemId);

  /// Adds a new item photo metadata record to the database.
  /// [photoMetadata] contains the data (item_id, storage_path, etc.).
  /// Assumes the file has already been uploaded to storage.
  Future<ItemPhoto> addPhotoMetadata(ItemPhoto photoMetadata);

  /// Deletes an item photo metadata record by its ID.
  /// Note: This usually does NOT delete the actual file from storage.
  /// File deletion should be handled separately if required.
  Future<void> deletePhotoMetadata(int photoId);

   /// Deletes all item photo metadata records for a specific item.
   /// Note: Also does not delete files from storage.
   Future<void> deletePhotosForItem(int itemId);
} 