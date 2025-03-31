import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/repositories/item_photo_repository.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

class SupabaseItemPhotoRepository implements ItemPhotoRepository {
  final SupabaseClient _client;
  final String _userId;

  SupabaseItemPhotoRepository(this._client, this._userId);

  String get _tableName => 'item_photos';

  @override
  Future<List<ItemPhoto>> fetchPhotosForItem(int itemId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', _userId)
          .eq('item_id', itemId)
          .order('created_at', ascending: true); // Example ordering

      return (response as List).map((data) => ItemPhoto.fromJson(data)).toList();
    } on PostgrestException catch (e) {
      print('Error fetching photos for item $itemId: ${e.message}');
      throw DatabaseException('Failed to fetch item photos: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred fetching item photos: $e');
    }
  }

  @override
  Future<ItemPhoto> addPhotoMetadata(ItemPhoto photoMetadata) async {
    try {
      // Prepare data, ensure user_id is set, remove id/created_at
      final photoData = photoMetadata.toJson()
        ..['user_id'] = _userId
        ..remove('id')
        ..remove('created_at');

      final response = await _client
          .from(_tableName)
          .insert(photoData)
          .select()
          .single();

      return ItemPhoto.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error adding photo metadata: ${e.message}');
      if (e.code == '23503') { // foreign_key_violation (item_id doesn't exist)
         throw ValidationException('Invalid item specified for the photo.');
      }
      throw DatabaseException('Failed to add photo metadata: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred adding photo metadata: $e');
    }
  }

  @override
  Future<void> deletePhotoMetadata(int photoId) async {
     try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', photoId)
          .eq('user_id', _userId); // Ensure user owns the photo record

    } on PostgrestException catch (e) {
      print('Error deleting photo metadata $photoId: ${e.message}');
      throw DatabaseException('Failed to delete photo metadata: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred deleting photo metadata: $e');
    }
  }

 @override
  Future<void> deletePhotosForItem(int itemId) async {
     try {
      await _client
          .from(_tableName)
          .delete()
          .eq('item_id', itemId)
          .eq('user_id', _userId); // Ensure user owns the item/photos

    } on PostgrestException catch (e) {
      print('Error deleting photos for item $itemId: ${e.message}');
      throw DatabaseException('Failed to delete photos for item: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred deleting photos for item: $e');
    }
  }
} 