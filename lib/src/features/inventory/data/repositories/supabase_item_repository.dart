import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
// TODO: Import custom exceptions

class SupabaseItemRepository implements ItemRepository {
  final SupabaseClient _supabaseClient;
  final String _tableName = 'items'; // Assuming table name is 'items'

  SupabaseItemRepository(this._supabaseClient);

  String _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      // TODO: Replace with concrete AuthException (e.g., AuthException.sessionExpired())
      throw AuthException.sessionExpired();
    }
    return user.id;
  }

  // Helper to convert ItemStatus enum to DB string based on @JsonValue
  String _statusToDbString(ItemStatus status) {
    // Use a switch statement based on the enum values and their expected @JsonValue
    switch (status) {
      case ItemStatus.forSale: return 'for_sale';
      case ItemStatus.sold: return 'sold';
      case ItemStatus.archived: return 'archived';
      // Add a default case or handle potential future statuses if necessary
    }
  }

  @override
  Future<Result<Item>> createItem(Item item) async {
    try {
      final userId = _getCurrentUserId();
      final itemData = item.toJson();
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

      return Result.success(Item.fromJson(response));
    } on PostgrestException catch (e) {
       // TODO: Map to specific DatabaseException
      return Result.failure(DatabaseException.creationFailed('item', e.message));
    } catch (e) {
      // TODO: Map to specific AppException or UnexpectedException
      return Result.failure(UnexpectedException('Unexpected error creating item', e));
    }
  }

  @override
  Future<Result<Item?>> getItemById(String id) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      final item = response == null ? null : Item.fromJson(response);
      return Result.success(item);
    } on PostgrestException catch (e) {
       // TODO: Map to specific DatabaseException
      return Result.failure(DatabaseException.fetchFailed('item', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching item', e));
    }
  }

  @override
  Future<Result<List<Item>>> getAllItems() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      final items = response.map((json) => Item.fromJson(json)).toList();
      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('all items', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching items', e));
    }
  }

  @override
  Future<Result<List<Item>>> getItemsByPallet(String palletId) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('pallet_id', palletId)
          .order('created_at', ascending: true); 

      final items = response.map((json) => Item.fromJson(json)).toList();
      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('items for pallet $palletId', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching items by pallet', e));
    }
  }

   @override
  Future<Result<List<Item>>> getItemsByStatus(ItemStatus status) async {
    try {
      final statusString = _statusToDbString(status); 
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('status', statusString)
          .order('created_at', ascending: false);

      final items = response.map((json) => Item.fromJson(json)).toList();
      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('items with status $status', e.message));
    } catch (e) {
       return Result.failure(UnexpectedException('Unexpected error fetching items by status', e));
    }
  }

  @override
  Future<Result<List<Item>>> getStaleItems({required Duration staleThreshold}) async {
    try {
      final thresholdDate = DateTime.now().subtract(staleThreshold);

      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('status', _statusToDbString(ItemStatus.forSale)) 
          .lt('acquired_date', thresholdDate.toIso8601String())
          .order('acquired_date', ascending: true);

      final items = response.map((json) => Item.fromJson(json)).toList();
      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('stale items', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching stale items', e));
    }
  }


  @override
  Future<Result<Item>> updateItem(Item item) async {
    try {
       final userId = _getCurrentUserId(); // Perform auth check early
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
          .eq('user_id', userId) // Ensure user ownership for update
          .select()
          .single();

      return Result.success(Item.fromJson(response));
    } on PostgrestException catch (e) {
       return Result.failure(DatabaseException.updateFailed('item ${item.id}', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error updating item', e));
    }
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    try {
      final userId = _getCurrentUserId(); // Perform auth check early
      await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', userId); // Ensure user ownership for delete

      // Note: May need to delete associated photos, tags (join table records), expenses first.
      return const Result.success(null); // Return Success(null) for void results
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.deletionFailed('item $id', e.message));
    } catch (e) {
       return Result.failure(UnexpectedException('Unexpected error deleting item', e));
    }
  }

  // Implementation for calculateItemProfit would likely involve fetching the item,
  // associated expenses, and potentially calling a DB function or doing calculation here.
} 