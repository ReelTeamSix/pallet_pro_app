import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/storage_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_photo_repository.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Service for managing item photos including upload, delete, and management operations
class PhotoManagementService {
  final ProviderRef ref;
  
  PhotoManagementService(this.ref);

  /// Upload new photos for an item
  Future<List<ItemPhoto>> uploadNewPhotos({
    required String itemId,
    required List<XFile> newPhotos,
  }) async {
    final List<ItemPhoto> uploadedPhotos = [];
    
    try {
      // Compress images before upload
      final compressedImages = await _compressImages(newPhotos);
      
      // Upload each image
      for (int i = 0; i < compressedImages.length; i++) {
        final image = compressedImages[i];
        final fileName = '${itemId}_${DateTime.now().millisecondsSinceEpoch}_${i + 1}.jpg';
        
        // Upload to storage
        final storagePath = await ref.read(storageRepositoryProvider).uploadItemPhoto(
          itemId: itemId,
          fileName: fileName,
          file: image,
        );
        
        // Save photo metadata to database
        final photo = ItemPhoto(
          id: '', // Will be set by repository
          itemId: itemId,
          imageUrl: storagePath,
          isPrimary: false, // Will be determined by repository
          createdAt: DateTime.now(),
        );
        
        final saveResult = await ref.read(itemPhotoRepositoryProvider).saveItemPhoto(
          itemId: itemId,
          storagePath: storagePath,
          isPrimary: false,
        );
        
        if (saveResult.isSuccess) {
          uploadedPhotos.add(photo);
        }
      }
    } catch (e) {
      print('Error uploading photos: $e');
      rethrow;
    }
    
    return uploadedPhotos;
  }

  /// Delete photos from storage and database
  Future<void> deletePhotos({
    required String itemId,
    required List<ItemPhoto> photosToDelete,
  }) async {
    try {
      for (final photo in photosToDelete) {
        // Delete from storage
        await ref.read(storageRepositoryProvider).deleteItemPhotos([photo.imageUrl]);
        
        // Delete from database
        await ref.read(itemPhotoRepositoryProvider).deleteItemPhoto(photo.id);
      }
    } catch (e) {
      print('Error deleting photos: $e');
      rethrow;
    }
  }

  /// Update photo management (add new, remove existing)
  Future<void> updateItemPhotos({
    required String itemId,
    required List<ItemPhoto> photosToKeep,
    required List<XFile> newPhotos,
    required List<ItemPhoto> photosToRemove,
  }) async {
    try {
      // Delete removed photos
      if (photosToRemove.isNotEmpty) {
        await deletePhotos(itemId: itemId, photosToDelete: photosToRemove);
      }
      
      // Upload new photos
      if (newPhotos.isNotEmpty) {
        await uploadNewPhotos(itemId: itemId, newPhotos: newPhotos);
      }
      
      // Update primary photo if needed
      await _updatePrimaryPhoto(itemId, photosToKeep);
      
    } catch (e) {
      print('Error updating item photos: $e');
      rethrow;
    }
  }

  /// Compress images before upload
  Future<List<XFile>> _compressImages(List<XFile> images) async {
    final List<XFile> compressedImages = [];
    
    for (final image in images) {
      final compressedImage = await _compressImage(image);
      compressedImages.add(compressedImage);
    }
    
    return compressedImages;
  }

  /// Compress a single image
  Future<XFile> _compressImage(XFile file) async {
    // Get temp directory
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    
    // Read file as bytes
    final bytes = await file.readAsBytes();
    
    // Compress image
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 720,
      minWidth: 720,
      quality: 85,
    );
    
    // Write compressed bytes to a new file
    final compressedFile = File(targetPath);
    await compressedFile.writeAsBytes(result);
    
    // Return the compressed file as XFile
    return XFile(compressedFile.path);
  }

  /// Update primary photo logic
  Future<void> _updatePrimaryPhoto(String itemId, List<ItemPhoto> photosToKeep) async {
    // If no photos are kept, no need to update primary
    if (photosToKeep.isEmpty) return;
    
    // Find the first photo that should be primary
    final primaryPhoto = photosToKeep.firstWhere(
      (photo) => photo.isPrimary,
      orElse: () => photosToKeep.first,
    );
    
    // Update primary status in database
    await ref.read(itemPhotoRepositoryProvider).setPrimaryPhoto(
      itemId: itemId,
      photoId: primaryPhoto.id,
    );
  }
}

/// Provider for PhotoManagementService
final photoManagementServiceProvider = Provider<PhotoManagementService>((ref) {
  return PhotoManagementService(ref);
});
