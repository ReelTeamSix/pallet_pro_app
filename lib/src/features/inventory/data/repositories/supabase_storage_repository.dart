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
  final String _bucketName = 'item_photos';

  SupabaseStorageRepository(this._supabaseClient) {
    // Ensure bucket exists
    _ensureBucketExists();
  }

  // Private method to ensure the bucket exists
  Future<void> _ensureBucketExists() async {
    try {
      // Get list of all buckets
      final List<Bucket> buckets = await _supabaseClient.storage.listBuckets();
      
      // Check if our bucket exists
      final bool bucketExists = buckets.any((bucket) => bucket.name == _bucketName);
      
      if (!bucketExists) {
        if (kDebugMode) {
          print('Creating storage bucket: $_bucketName');
        }
        
        // Create the bucket if it doesn't exist
        // Set public access to true for easier image display
        await _supabaseClient.storage.createBucket(
          _bucketName, 
          const BucketOptions(public: true)
        );
        
        if (kDebugMode) {
          print('Bucket created successfully');
        }
      } else {
        if (kDebugMode) {
          print('Bucket exists: $_bucketName');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring bucket exists: $e');
      }
      // Don't throw, just log - we don't want to prevent app startup
      // The error will be caught later if we try to use the bucket
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
      // Read file bytes
      final fileBytes = await file.readAsBytes();
      final fileExtension = file.name.split('.').last.toLowerCase();
      // Determine MIME type
      final mimeType = 'image/$fileExtension'; // Basic type, might need refinement

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

      // After successful upload, return the path used.
      // The actual URL might be constructed later or using createSignedUrl.
      return storagePath;

    } on StorageException catch (e) {
      // TODO: Map StorageException to a custom exception
      print('Error uploading photo $storagePath: ${e.message}');
      throw Exception('Storage error uploading photo: ${e.message}');
    } catch (e) {
      // TODO: Map generic exceptions
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