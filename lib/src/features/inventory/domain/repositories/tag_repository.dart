import 'package:pallet_pro_app/src/features/inventory/data/models/tag.dart';

/// Repository interface for tag operations.
abstract class TagRepository {
  /// Fetches all tags for the current user.
  Future<List<Tag>> fetchTags();

  /// Creates a new tag.
  /// [name] is the name of the tag to create.
  Future<Tag> createTag(String name);

  /// Updates an existing tag.
  Future<Tag> updateTag(Tag tag);

  /// Deletes a tag by its ID.
  Future<void> deleteTag(int tagId);
} 