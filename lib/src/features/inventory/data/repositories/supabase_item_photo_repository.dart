import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_photo_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:uuid/uuid.dart';

class SupabaseItemPhotoRepository implements ItemPhotoRepository {
  final SupabaseClient _supabaseClient;
  final StorageRepository _storageRepository;
  final String _tableName = 'item_photos';

  SupabaseItemPhotoRepository(this._supabaseClient, this._storageRepository);

  String _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw AuthException.sessionExpired();
    }
    return user.id;
  }

  @override
  Future<Result<ItemPhoto>> saveItemPhoto({
    required String itemId,
    required String storagePath,
    String? description,
    bool isPrimary = false,
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // Create the photo data
      final photoData = {
        'id': const Uuid().v4(),
        'user_id': userId,
        'item_id': itemId,
        'storage_path': storagePath,
        'is_primary': isPrimary,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      if (description != null) {
        photoData['description'] = description;
      }

      // Insert into database
      final response = await _supabaseClient
          .from(_tableName)
          .insert(photoData)
          .select()
          .single();

      // Get the actual image URL from the storage path
      final imageUrl = await _storageRepository.createSignedPhotoUrl(response['storage_path']);
      
      // Map fields for the ItemPhoto model
      response['image_url'] = imageUrl;
      
      return Result.success(ItemPhoto.fromJson(response));
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.creationFailed('item photo', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error saving item photo', e));
    }
  }

  @override
  Future<Result<List<ItemPhoto>>> getItemPhotos(String itemId) async {
    try {
      final userId = _getCurrentUserId();
      
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('item_id', itemId)
          .eq('user_id', userId);

      if (response.isEmpty) {
        return const Result.success([]);
      }

      // Convert storage paths to actual URLs for each photo
      final photos = <ItemPhoto>[];
      for (final json in response) {
        final storagePath = json['storage_path'];
        try {
          final imageUrl = await _storageRepository.createSignedPhotoUrl(storagePath);
          json['image_url'] = imageUrl;
          photos.add(ItemPhoto.fromJson(json));
        } catch (e) {
          print('Error getting URL for photo ${json['id']}: $e');
          // Skip this photo but continue with others
        }
      }

      return Result.success(photos);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('item photos', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching item photos', e));
    }
  }

  @override
  Future<Result<void>> deleteItemPhoto(String photoId) async {
    try {
      final userId = _getCurrentUserId();
      
      await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', photoId)
          .eq('user_id', userId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.deletionFailed('item photo', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error deleting item photo', e));
    }
  }

  @override
  Future<Result<void>> deleteAllItemPhotos(String itemId) async {
    try {
      final userId = _getCurrentUserId();
      
      await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('item_id', itemId)
          .eq('user_id', userId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.deletionFailed('item photos', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error deleting item photos', e));
    }
  }
} 