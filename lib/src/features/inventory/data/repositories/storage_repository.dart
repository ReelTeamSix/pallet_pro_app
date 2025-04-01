import 'dart:typed_data'; // For raw image data if needed
import 'package:image_picker/image_picker.dart'; // Or flutter File type if using dart:io

// Import custom exception/result types if defined

/// Abstract interface for managing file storage operations, primarily for item photos.
abstract class StorageRepository {

  /// Uploads an item photo.
  ///
  /// Takes the [itemId], a unique [fileName], and the image [file] (e.g., XFile from image_picker).
  /// Returns the public URL or storage path of the uploaded file.
  /// Implementation should handle constructing the correct storage path (e.g., incorporating user ID).
  Future<String> uploadItemPhoto({
    required String itemId,
    required String fileName,
    required XFile file, // Or File, or Uint8List depending on input source
    Map<String, String>? metadata, // Optional metadata
  });

  /// Deletes one or more item photos from storage.
  ///
  /// Takes a list of storage [paths] to delete.
  /// Implementation should ensure paths are correctly formatted for the storage provider.
  Future<void> deleteItemPhotos(List<String> paths);

  /// Generates a signed URL for accessing a private item photo.
  ///
  /// Takes the storage [path] of the photo.
  /// Returns a temporary, secure URL.
  /// Manages URL expiry time according to implementation details.
  Future<String> createSignedPhotoUrl(String path);

  // Potentially add methods for listing photos in a 'folder' (by itemId)
  // Future<List<String>> listItemPhotoPaths(String itemId);
} 