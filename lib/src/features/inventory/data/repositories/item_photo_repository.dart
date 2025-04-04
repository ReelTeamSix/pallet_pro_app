import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';

/// Repository interface for managing item photos in the database
abstract class ItemPhotoRepository {
  /// Saves a photo reference to the database
  /// 
  /// Takes the [itemId], [storagePath] where the image is stored,
  /// and optional [description] and [isPrimary] flag.
  /// Returns the created ItemPhoto if successful.
  Future<Result<ItemPhoto>> saveItemPhoto({
    required String itemId,
    required String storagePath,
    String? description,
    bool isPrimary = false,
  });

  /// Gets all photos for an item
  Future<Result<List<ItemPhoto>>> getItemPhotos(String itemId);

  /// Deletes a photo reference from the database
  Future<Result<void>> deleteItemPhoto(String photoId);

  /// Deletes all photos for an item
  Future<Result<void>> deleteAllItemPhotos(String itemId);
} 