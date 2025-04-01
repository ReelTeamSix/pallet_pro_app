import 'package:pallet_pro_app/src/features/inventory/data/models/tag.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/tag_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// TODO: Import custom exceptions

class SupabaseTagRepository implements TagRepository {
  final SupabaseClient _supabaseClient;
  final String _tagsTable = 'tags'; // Assuming table name for tags
  final String _itemTagsTable = 'item_tags'; // Assuming join table name

  SupabaseTagRepository(this._supabaseClient);

  String _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      // TODO: Replace with AuthException
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    // Tags might be global or user-specific depending on design.
    // Assuming user-specific for now, requiring a user_id column in 'tags' table.
    final userId = _getCurrentUserId();
    try {
      final tagData = tag.toJson();
      tagData.remove('id');
      tagData['user_id'] = userId; // Assuming user-specific tags
      tagData['created_at'] ??= DateTime.now().toIso8601String();
      tagData['updated_at'] ??= DateTime.now().toIso8601String();

      // Handle potential duplicate tag names gracefully
      final existingTag = await getTagByName(tag.name);
      if (existingTag != null) {
        // Tag already exists, return the existing one instead of creating duplicate
        return existingTag;
      }

      final response = await _supabaseClient
          .from(_tagsTable)
          .insert(tagData)
          .select()
          .single();

      return Tag.fromJson(response);
    } on PostgrestException catch (e) {
      // Handle unique constraint violation if getTagByName check fails concurrency
      if (e.code == '23505') { // Unique violation
         print('Tag "${tag.name}" likely already exists, attempting to fetch.');
         final existing = await getTagByName(tag.name);
         if (existing != null) return existing;
      }
      // TODO: Map to DatabaseException.creationFailed
      print('Error creating tag: ${e.message}');
      throw Exception('Database error creating tag: ${e.message}');
    } catch (e) {
      // TODO: Map to generic exception
      print('Unexpected error creating tag: $e');
      throw Exception('Unexpected error creating tag: $e');
    }
  }

   @override
  Future<Tag?> getTagById(String id) async {
     final userId = _getCurrentUserId();
    try {
      final response = await _supabaseClient
          .from(_tagsTable)
          .select()
          .eq('id', id)
          .eq('user_id', userId) // Assuming user-specific tags
          .maybeSingle();

      return response == null ? null : Tag.fromJson(response);
    } on PostgrestException catch (e) {
      // TODO: Map error
      print('Error fetching tag $id: ${e.message}');
      throw Exception('Database error fetching tag: ${e.message}');
    } catch (e) {
       // TODO: Map error
      print('Unexpected error fetching tag $id: $e');
      throw Exception('Unexpected error fetching tag: $e');
    }
  }

  @override
  Future<Tag?> getTagByName(String name) async {
    // Assuming tag names should be unique per user
    final userId = _getCurrentUserId();
    try {
      final response = await _supabaseClient
          .from(_tagsTable)
          .select()
          .eq('name', name)
          .eq('user_id', userId) // Case-sensitive match by default
          .maybeSingle();

        // Optional: Could do a case-insensitive search if needed:
        // .ilike('name', name) // Requires index for performance

      return response == null ? null : Tag.fromJson(response);
    } on PostgrestException catch (e) {
      // TODO: Map error
       print('Error fetching tag by name "$name": ${e.message}');
      throw Exception('Database error fetching tag by name: ${e.message}');
    } catch (e) {
      // TODO: Map error
      print('Unexpected error fetching tag by name "$name": $e');
      throw Exception('Unexpected error fetching tag by name: $e');
    }
  }

  @override
  Future<List<Tag>> getAllTags() async {
     final userId = _getCurrentUserId();
    try {
      final response = await _supabaseClient
          .from(_tagsTable)
          .select()
          .eq('user_id', userId) // Assuming user-specific tags
          .order('name', ascending: true);

      return response.map((json) => Tag.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      // TODO: Map error
       print('Error fetching all tags: ${e.message}');
      throw Exception('Database error fetching tags: ${e.message}');
    } catch (e) {
       // TODO: Map error
      print('Unexpected error fetching all tags: $e');
      throw Exception('Unexpected error fetching tags: $e');
    }
  }

  @override
  Future<Tag> updateTag(Tag tag) async {
     final userId = _getCurrentUserId();
    try {
      final tagData = tag.toJson();
      tagData.remove('id');
      tagData.remove('user_id');
      tagData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseClient
          .from(_tagsTable)
          .update(tagData)
          .eq('id', tag.id)
          .eq('user_id', userId) // Ensure user owns the tag
          .select()
          .single();

      return Tag.fromJson(response);
    } on PostgrestException catch (e) {
      // TODO: Map error
      print('Error updating tag ${tag.id}: ${e.message}');
      throw Exception('Database error updating tag: ${e.message}');
    } catch (e) {
       // TODO: Map error
      print('Unexpected error updating tag ${tag.id}: $e');
      throw Exception('Unexpected error updating tag: $e');
    }
  }

  @override
  Future<void> deleteTag(String id) async {
     final userId = _getCurrentUserId();
    try {
      // First, remove associations in the join table
      await _supabaseClient
          .from(_itemTagsTable)
          .delete()
          .eq('tag_id', id);
          // Note: RLS on item_tags should prevent deleting associations for items not owned by the user.

      // Then, delete the tag itself
      await _supabaseClient
          .from(_tagsTable)
          .delete()
          .eq('id', id)
          .eq('user_id', userId); // Ensure user owns the tag
    } on PostgrestException catch (e) {
      // TODO: Map error
      print('Error deleting tag $id: ${e.message}');
      throw Exception('Database error deleting tag: ${e.message}');
    } catch (e) {
      // TODO: Map error
      print('Unexpected error deleting tag $id: $e');
      throw Exception('Unexpected error deleting tag: $e');
    }
  }

  @override
  Future<void> addTagToItem({required String tagId, required String itemId}) async {
    // RLS on item_tags should verify ownership of both item and tag (if tags are user-specific)
    try {
      await _supabaseClient
          .from(_itemTagsTable)
          .insert({
            'item_id': itemId,
            'tag_id': tagId,
            // 'user_id': _getCurrentUserId() // May not be needed if RLS uses item/tag ownership
          });
          // Use upsert or specific error handling (e.g., code '23505') if the relationship might already exist
    } on PostgrestException catch (e) {
      // Handle unique constraint violation if trying to add existing relationship
       if (e.code == '23505') {
         print('Item $itemId already has tag $tagId.');
         return; // Or throw a specific "already exists" exception
       }
       // TODO: Map error
       print('Error adding tag $tagId to item $itemId: ${e.message}');
       throw Exception('Database error adding tag to item: ${e.message}');
    } catch (e) {
      // TODO: Map error
       print('Unexpected error adding tag $tagId to item $itemId: $e');
       throw Exception('Unexpected error adding tag to item: $e');
    }
  }

  @override
  Future<void> removeTagFromItem({required String tagId, required String itemId}) async {
     // RLS on item_tags should verify ownership
    try {
      await _supabaseClient
          .from(_itemTagsTable)
          .delete()
          .eq('item_id', itemId)
          .eq('tag_id', tagId);
    } on PostgrestException catch (e) {
       // TODO: Map error
       print('Error removing tag $tagId from item $itemId: ${e.message}');
       throw Exception('Database error removing tag from item: ${e.message}');
    } catch (e) {
      // TODO: Map error
       print('Unexpected error removing tag $tagId from item $itemId: $e');
       throw Exception('Unexpected error removing tag from item: $e');
    }
  }

  @override
  Future<List<Tag>> getTagsForItem(String itemId) async {
     // RLS should ensure user owns the item 'itemId'
    try {
      // Fetch tag IDs associated with the item from the join table
      final itemTagResponse = await _supabaseClient
          .from(_itemTagsTable)
          .select('tag_id')
          .eq('item_id', itemId);

      if (itemTagResponse.isEmpty) {
        return []; // No tags associated
      }

      // Extract the list of tag IDs
      final tagIds = itemTagResponse.map((row) => row['tag_id'] as String).toList();

      // Fetch the actual Tag objects using the IDs
      final tagsResponse = await _supabaseClient
          .from(_tagsTable)
          .select()
          .in_('id', tagIds); // Fetch all tags whose IDs are in the list

      return tagsResponse.map((json) => Tag.fromJson(json)).toList();

    } on PostgrestException catch (e) {
      // TODO: Map error
      print('Error fetching tags for item $itemId: ${e.message}');
      throw Exception('Database error fetching tags for item: ${e.message}');
    } catch (e) {
      // TODO: Map error
      print('Unexpected error fetching tags for item $itemId: $e');
      throw Exception('Unexpected error fetching tags for item: $e');
    }
  }
} 