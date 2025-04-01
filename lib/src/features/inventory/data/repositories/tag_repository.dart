import 'package:pallet_pro_app/src/features/inventory/data/models/tag.dart';
// Import custom exception/result types if defined

/// Abstract interface for managing Tag data and item-tag relationships.
abstract class TagRepository {
  /// Creates a new tag.
  Future<Tag> createTag(Tag tag);

  /// Fetches a tag by its ID.
  Future<Tag?> getTagById(String id);

  /// Fetches a tag by its name (case-insensitive matching might be useful).
  Future<Tag?> getTagByName(String name);

  /// Fetches all tags.
  Future<List<Tag>> getAllTags();

  /// Updates an existing tag (e.g., rename).
  Future<Tag> updateTag(Tag tag);

  /// Deletes a tag. Consider implications for items linked to this tag.
  Future<void> deleteTag(String id);

  /// Associates a tag with an item.
  Future<void> addTagToItem({required String tagId, required String itemId});

  /// Removes a tag association from an item.
  Future<void> removeTagFromItem({required String tagId, required String itemId});

  /// Fetches all tags associated with a specific item.
  Future<List<Tag>> getTagsForItem(String itemId);
} 