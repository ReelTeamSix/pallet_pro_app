import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// TODO: Import custom exceptions

class SupabaseItemRepository implements ItemRepository {
  final SupabaseClient _supabaseClient;
  final String _tableName = 'items'; // Assuming table name is 'items'

  SupabaseItemRepository(this._supabaseClient);

  String _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      // TODO: Replace with AuthException
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  // Helper to convert ItemStatus enum to DB string based on @JsonValue
  String _statusToDbString(ItemStatus status) {
    // This relies on the enum definition having @JsonValue annotations
    // A more robust way might involve a switch or map if annotations aren't used
    try {
      return status.toJson(); // Uses the generated toJson for enum serialization
    } catch (_) {
      // Fallback if toJson isn't generated or fails
      switch (status) {
        case ItemStatus.forSale: return 'for_sale';
        case ItemStatus.sold: return 'sold';
        case ItemStatus.archived: return 'archived';
      }
    }
  }

  @override
  Future<Item> createItem(Item item) async {
    final userId = _getCurrentUserId();
    try {
      final itemData = item.toJson();
      // Ensure user_id is set for RLS
      itemData['user_id'] = userId;
      itemData.remove('id');
      itemData['created_at'] ??= DateTime.now().toIso8601String();
      itemData['updated_at'] ??= DateTime.now().toIso8601String();

      // Ensure enum fields are correctly serialized if needed (toJson should handle this)
      // itemData['status'] = _statusToDbString(item.status); // Handled by toJson
      // itemData['condition'] = item.condition.name; // Assuming DB stores condition name string

      final response = await _supabaseClient
          .from(_tableName)
          .insert(itemData)
          .select()
          .single();

      return Item.fromJson(response);
    } on PostgrestException catch (e) {
      // TODO: Map to DatabaseException.creationFailed
      print('Error creating item: ${e.message}');
      throw Exception('Database error creating item: ${e.message}');
    } catch (e) {
      // TODO: Map to generic exception
      print('Unexpected error creating item: $e');
      throw Exception('Unexpected error creating item: $e');
    }
  }

  @override
  Future<Item?> getItemById(String id) async {
     final userId = _getCurrentUserId(); // Auth check might not be needed if RLS is sufficient
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          // .eq('user_id', userId) // RLS should handle this, potentially remove
          .maybeSingle();

      return response == null ? null : Item.fromJson(response);
    } on PostgrestException catch (e) {
      // TODO: Map to DatabaseException.fetchFailed
      print('Error fetching item $id: ${e.message}');
      throw Exception('Database error fetching item: ${e.message}');
    } catch (e) {
      // TODO: Map to generic exception
      print('Unexpected error fetching item $id: $e');
      throw Exception('Unexpected error fetching item: $e');
    }
  }

  @override
  Future<List<Item>> getAllItems() async {
     final userId = _getCurrentUserId(); // Auth check might not be needed if RLS is sufficient
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          // .eq('user_id', userId) // RLS should handle this
          .order('created_at', ascending: false);

      return response.map((json) => Item.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      // TODO: Map to DatabaseException.fetchFailed
      print('Error fetching all items: ${e.message}');
      throw Exception('Database error fetching items: ${e.message}');
    } catch (e) {
      // TODO: Map to generic exception
      print('Unexpected error fetching all items: $e');
      throw Exception('Unexpected error fetching items: $e');
    }
  }

  @override
  Future<List<Item>> getItemsByPallet(String palletId) async {
     final userId = _getCurrentUserId(); // Auth check might not be needed if RLS is sufficient
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('pallet_id', palletId)
          // .eq('user_id', userId) // RLS should handle this
          .order('created_at', ascending: true); // Or order as needed

      return response.map((json) => Item.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      // TODO: Map to DatabaseException.fetchFailed
      print('Error fetching items for pallet $palletId: ${e.message}');
      throw Exception('Database error fetching items by pallet: ${e.message}');
    } catch (e) {
      // TODO: Map to generic exception
      print('Unexpected error fetching items for pallet $palletId: $e');
      throw Exception('Unexpected error fetching items by pallet: $e');
    }
  }

   @override
  Future<List<Item>> getItemsByStatus(ItemStatus status) async {
    final userId = _getCurrentUserId(); // Auth check might not be needed if RLS is sufficient
    try {
      final statusString = _statusToDbString(status); // Convert enum to DB string
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('status', statusString)
          // .eq('user_id', userId) // RLS should handle this
          .order('created_at', ascending: false);

      return response.map((json) => Item.fromJson(json)).toList();
    } on PostgrestException catch (e) {
       // TODO: Map to DatabaseException.fetchFailed
      print('Error fetching items by status $status: ${e.message}');
      throw Exception('Database error fetching items by status: ${e.message}');
    } catch (e) {
      // TODO: Map to generic exception
      print('Unexpected error fetching items by status $status: $e');
      throw Exception('Unexpected error fetching items by status: $e');
    }
  }

  @override
  Future<List<Item>> getStaleItems({required Duration staleThreshold}) async {
     final userId = _getCurrentUserId(); // Auth check might not be needed if RLS is sufficient
     try {
        // Calculate the threshold date
       final thresholdDate = DateTime.now().subtract(staleThreshold);

       final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('status', _statusToDbString(ItemStatus.forSale)) // Only consider items 'for_sale'
          // Assumes 'acquired_date' or 'created_at' is used for staleness
          .lt('acquired_date', thresholdDate.toIso8601String())
          // .eq('user_id', userId) // RLS should handle this
          .order('acquired_date', ascending: true);

        return response.map((json) => Item.fromJson(json)).toList();
     } on PostgrestException catch (e) {
       // TODO: Map to DatabaseException.fetchFailed
       print('Error fetching stale items: ${e.message}');
       throw Exception('Database error fetching stale items: ${e.message}');
     } catch (e) {
       // TODO: Map to generic exception
       print('Unexpected error fetching stale items: $e');
       throw Exception('Unexpected error fetching stale items: $e');
     }
  }


  @override
  Future<Item> updateItem(Item item) async {
    final userId = _getCurrentUserId(); // Auth check might not be needed if RLS is sufficient
    try {
      final itemData = item.toJson();
      itemData.remove('user_id');
      itemData.remove('id');
      itemData['updated_at'] = DateTime.now().toIso8601String();

      // Ensure enum fields are correctly serialized if needed (toJson should handle this)
      // itemData['status'] = _statusToDbString(item.status); // Handled by toJson
      // itemData['condition'] = item.condition.name; // Assuming DB stores condition name string

      final response = await _supabaseClient
          .from(_tableName)
          .update(itemData)
          .eq('id', item.id)
          // .eq('user_id', userId) // RLS should handle this
          .select()
          .single();

      return Item.fromJson(response);
    } on PostgrestException catch (e) {
      // TODO: Map to DatabaseException.updateFailed
      print('Error updating item ${item.id}: ${e.message}');
      throw Exception('Database error updating item: ${e.message}');
    } catch (e) {
       // TODO: Map to generic exception
      print('Unexpected error updating item ${item.id}: $e');
      throw Exception('Unexpected error updating item: $e');
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    final userId = _getCurrentUserId(); // Auth check might not be needed if RLS is sufficient
    try {
      await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', id);
          // .eq('user_id', userId); // RLS should handle this

      // Note: May need to delete associated photos, tags (join table records), expenses first.
    } on PostgrestException catch (e) {
      // TODO: Map to DatabaseException.deleteFailed
      print('Error deleting item $id: ${e.message}');
      throw Exception('Database error deleting item: ${e.message}');
    } catch (e) {
      // TODO: Map to generic exception
      print('Unexpected error deleting item $id: $e');
      throw Exception('Unexpected error deleting item: $e');
    }
  }

  // Implementation for calculateItemProfit would likely involve fetching the item,
  // associated expenses, and potentially calling a DB function or doing calculation here.
} 