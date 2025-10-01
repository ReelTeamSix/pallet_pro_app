import 'dart:io'; // Needed if using File type
import 'dart:typed_data'; // Needed if using Uint8List type
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:pallet_pro_app/src/features/inventory/data/repositories/storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// TODO: Import custom exceptions (e.g., StorageException wrapper)

class SupabaseStorageRepository implements StorageRepository {
  final SupabaseClient _supabaseClient;
  // Define bucket name - should match your Supabase setup
  final String _bucketName = 'item-photos';

  SupabaseStorageRepository(this._supabaseClient) {
    // No longer trying to create the bucket - it should be pre-created by an admin
    if (kDebugMode) {
      print('Storage repository initialized - using bucket: $_bucketName');
    }
  }

  String _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      // TODO: Replace with AuthException
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  // Helper to construct the storage path according to RLS policy
  // Example: user_id/item_id/file_name.jpg
  String _constructStoragePath(String userId, String itemId, String fileName) {
    // Ensure filename is safe (e.g., remove invalid characters, handle extensions)
    final safeFileName = fileName.replaceAll(RegExp(r'[^\w\.-]+'), '_');
    return '$userId/$itemId/$safeFileName';
  }

  @override
  Future<String> uploadItemPhoto({
    required String itemId,
    required String fileName,
    required XFile file, // Using XFile from image_picker
    Map<String, String>? metadata,
  }) async {
    final userId = _getCurrentUserId();
    final storagePath = _constructStoragePath(userId, itemId, fileName);

    try {
      // Verify the item exists in the database first
      final itemCheck = await _supabaseClient
          .from('items')
          .select('id')
          .eq('id', itemId)
          .eq('user_id', userId)
          .maybeSingle();
          
      if (itemCheck == null) {
        throw Exception('Cannot upload photo: Item $itemId not found or not accessible');
      }

      // Read file bytes
      final fileBytes = await file.readAsBytes();
      final fileExtension = file.name.split('.').last.toLowerCase();
      
      // Properly determine MIME type - ensure jpg is handled as jpeg
      String mimeType;
      if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
        mimeType = 'image/jpeg';  // Always use image/jpeg for jpg files
      } else if (fileExtension == 'png') {
        mimeType = 'image/png';
      } else if (fileExtension == 'gif') {
        mimeType = 'image/gif';
      } else if (fileExtension == 'webp') {
        mimeType = 'image/webp';
      } else {
        // Default to jpeg for unsupported types to avoid errors
        mimeType = 'image/jpeg';
      }
      
      if (kDebugMode) {
        print('Uploading file with extension $fileExtension and MIME type $mimeType');
      }

      // Use uploadBinary for better control over MIME type
      await _supabaseClient.storage.from(_bucketName).uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: FileOptions(
              // Using upsert: false prevents overwriting existing files with same name
              upsert: false,
              // Set appropriate content type for correct display/handling
              contentType: mimeType,
            ),
          );

      if (kDebugMode) {
        print('Successfully uploaded image to path: $storagePath');
      }

      // After successful upload, return the path used.
      // The actual URL might be constructed later or using createSignedUrl.
      return storagePath;

    } on StorageException catch (e) {
      if (e.statusCode == 403) {
        print('Permission denied uploading photo. RLS policy may be blocking access: ${e.message}');
        throw Exception('Permission denied while uploading photo. Please check that the bucket exists and RLS policies are correctly set.');
      } else if (e.message.toLowerCase().contains('bucket not found')) {
        print('Error: Bucket $_bucketName does not exist. Please create it in the Supabase dashboard.');
        throw Exception('Storage error: Bucket not found. This needs to be created by an administrator.');
      }
      print('Error uploading photo $storagePath: ${e.message}');
      throw Exception('Storage error uploading photo: ${e.message}');
    } catch (e) {
      print('Unexpected error uploading photo $storagePath: $e');
      throw Exception('Unexpected error uploading photo: $e');
    }
  }

  @override
  Future<void> deleteItemPhotos(List<String> paths) async {
    // No direct user ID check here, as RLS policies on the bucket/paths should enforce ownership.
    try {
      // Ensure paths are not empty
      if (paths.isEmpty) {
        print("No paths provided for deletion.");
        return;
      }
      await _supabaseClient.storage.from(_bucketName).remove(paths);

    } on StorageException catch (e) {
      // TODO: Map StorageException
      print('Error deleting photos: ${e.message}');
      throw Exception('Storage error deleting photos: ${e.message}');
    } catch (e) {
       // TODO: Map generic exceptions
      print('Unexpected error deleting photos: $e');
      throw Exception('Unexpected error deleting photos: $e');
    }
  }

  @override
  Future<String> createSignedPhotoUrl(String path) async {
    try {
      // First try to get a public URL for the image
      final publicUrl = _supabaseClient.storage.from(_bucketName).getPublicUrl(path);
      
      // If that fails or returns an invalid URL, fall back to signed URL
      if (publicUrl.isEmpty || !Uri.parse(publicUrl).isAbsolute) {
        // Create a signed URL that expires in 1 hour (3600 seconds)
        final signedUrl = await _supabaseClient.storage.from(_bucketName)
            .createSignedUrl(path, 3600);
        return signedUrl;
      }
      
      return publicUrl;
    } on StorageException catch (e) {
      print('Error creating signed URL for path $path: ${e.message}');
      throw Exception('Storage error creating signed URL: ${e.message}');
    } catch (e) {
      print('Unexpected error creating signed URL for path $path: $e');
      throw Exception('Unexpected error creating signed URL: $e');
    }
  }
} 