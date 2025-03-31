import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/tag.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/repositories/tag_repository.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

class SupabaseTagRepository implements TagRepository {
  final SupabaseClient _client;
  final String _userId;

  SupabaseTagRepository(this._client, this._userId);

  String get _tableName => 'tags';

  @override
  Future<List<Tag>> fetchTags() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', _userId);
          // Optionally add ordering: .order('name', ascending: true);

      return (response as List).map((data) => Tag.fromJson(data)).toList();
    } on PostgrestException catch (e) {
      print('Error fetching tags: ${e.message}');
      throw DatabaseException('Failed to fetch tags: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred fetching tags: $e');
    }
  }

  @override
  Future<Tag> createTag(String name) async {
    try {
      final newTagData = {
        'user_id': _userId,
        'name': name,
        // created_at is handled by the database default
      };
      final response = await _client
          .from(_tableName)
          .insert(newTagData)
          .select()
          .single();

      return Tag.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error creating tag: ${e.message}');
      // Handle potential unique constraint violation (e.g., duplicate tag name?)
      if (e.code == '23505') { // unique_violation
        throw ValidationException('A tag with this name already exists.');
      }
      throw DatabaseException('Failed to create tag: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred creating tag: $e');
    }
  }

  @override
  Future<Tag> updateTag(Tag tag) async {
    try {
      final Map<String, dynamic> updates = {
         'name': tag.name,
         // user_id should not change
      };

      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', tag.id)
          .eq('user_id', _userId) // Ensure user owns the tag
          .select()
          .single();

      return Tag.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error updating tag: ${e.message}');
       if (e.code == '23505') { // unique_violation
        throw ValidationException('A tag with this name already exists.');
      }
      if (e.code == 'PGRST116' || e.details.contains('0 rows')) { // Resource Not Found or no rows updated
           throw NotFoundException('Tag not found or you do not have permission to update it.');
      }
      throw DatabaseException('Failed to update tag: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred updating tag: $e');
    }
  }

  @override
  Future<void> deleteTag(int tagId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', tagId)
          .eq('user_id', _userId); // Ensure user owns the tag

    } on PostgrestException catch (e) {
      print('Error deleting tag: ${e.message}');
      // Consider FK constraint errors if tags are linked elsewhere
      throw DatabaseException('Failed to delete tag: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred deleting tag: $e');
    }
  }
} 