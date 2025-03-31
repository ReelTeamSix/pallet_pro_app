import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/repositories/item_repository.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

class SupabaseItemRepository implements ItemRepository {
  final SupabaseClient _client;
  final String _userId;

  SupabaseItemRepository(this._client, this._userId);

  String get _tableName => 'items';

  @override
  Future<List<Item>> fetchItemsByPallet(int palletId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', _userId)
          .eq('pallet_id', palletId)
          .order('name', ascending: true); // Example ordering

      return (response as List).map((data) => Item.fromJson(data)).toList();
    } on PostgrestException catch (e) {
      print('Error fetching items for pallet $palletId: ${e.message}');
      throw DatabaseException('Failed to fetch items: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred fetching items: $e');
    }
  }

   @override
  Future<Item?> fetchItemById(int itemId) async {
     try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', itemId)
          .eq('user_id', _userId)
          .maybeSingle();

      return response == null ? null : Item.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error fetching item $itemId: ${e.message}');
      throw DatabaseException('Failed to fetch item: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred fetching item: $e');
    }
  }

  @override
  Future<Item> createItem(Item item) async {
     try {
      // Prepare data, ensure user_id is set, remove id/timestamps
      final itemData = item.toJson()
        ..['user_id'] = _userId
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

       // Ensure date fields are formatted correctly for Supabase
      itemData['purchase_date'] = item.purchaseDate?.toIso8601String();
      itemData['expiry_date'] = item.expiryDate?.toIso8601String();

      final response = await _client
          .from(_tableName)
          .insert(itemData)
          .select()
          .single();

      return Item.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error creating item: ${e.message}');
       if (e.code == '23503') { // foreign_key_violation (e.g., pallet_id doesn't exist)
           throw ValidationException('Invalid pallet specified for the item.');
       }
       if (e.code == '23505') { // unique_violation (if any constraint exists, e.g., name+pallet_id)
         throw ValidationException('An item with this identifier might already exist on this pallet.');
       }
      throw DatabaseException('Failed to create item: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred creating item: $e');
    }
  }

  @override
  Future<Item> updateItem(Item item) async {
    try {
      // Prepare data, remove id/user_id/created_at, set updated_at
      final itemData = item.toJson()
        ..remove('id')
        ..remove('user_id')
        ..remove('created_at')
        ..['updated_at'] = DateTime.now().toIso8601String(); // Set update timestamp

      // Ensure date fields are formatted correctly
      itemData['purchase_date'] = item.purchaseDate?.toIso8601String();
      itemData['expiry_date'] = item.expiryDate?.toIso8601String();

      final response = await _client
          .from(_tableName)
          .update(itemData)
          .eq('id', item.id)
          .eq('user_id', _userId) // Ensure user owns the item
          .select()
          .single();

      return Item.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error updating item: ${e.message}');
       if (e.code == '23503') { // foreign_key_violation (e.g., trying to change pallet_id to non-existent one)
           throw ValidationException('Invalid pallet specified for the item update.');
       }
       if (e.code == 'PGRST116' || e.details.contains('0 rows')) { // Resource Not Found
           throw NotFoundException('Item not found or you do not have permission to update it.');
       }
      throw DatabaseException('Failed to update item: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred updating item: $e');
    }
  }

  @override
  Future<void> deleteItem(int itemId) async {
    try {
      // Optional: Consider deleting associated ItemPhotos first if handled here
      // await _client.from('item_photos').delete().eq('item_id', itemId).eq('user_id', _userId);

      await _client
          .from(_tableName)
          .delete()
          .eq('id', itemId)
          .eq('user_id', _userId); // Ensure user owns the item

    } on PostgrestException catch (e) {
      print('Error deleting item: ${e.message}');
      // FK constraints unlikely if deleting item, unless other tables reference items
      throw DatabaseException('Failed to delete item: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred deleting item: $e');
    }
  }
} 