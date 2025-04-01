import 'package:pallet_pro_app/src/features/inventory/data/models/expense.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/expense_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// TODO: Import custom exceptions

class SupabaseExpenseRepository implements ExpenseRepository {
  final SupabaseClient _supabaseClient;
  final String _tableName = 'expenses'; // Matches schema

  SupabaseExpenseRepository(this._supabaseClient);

   String _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      // TODO: Replace with AuthException
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  @override
  Future<Expense> createExpense(Expense expense) async {
     final userId = _getCurrentUserId();
    try {
      final expenseData = expense.toJson();
      expenseData['user_id'] = userId;
      expenseData.remove('id');
      expenseData['created_at'] ??= DateTime.now().toIso8601String();
      expenseData['updated_at'] ??= DateTime.now().toIso8601String();

      // Convert category string if model uses enum and DB uses string (depends on model definition)
      // expenseData['category'] = expense.category?.name; // Example if model uses enum

      final response = await _supabaseClient
          .from(_tableName)
          .insert(expenseData)
          .select()
          .single();

      return Expense.fromJson(response);
    } on PostgrestException catch (e) {
       // TODO: Map error
      print('Error creating expense: ${e.message}');
      throw Exception('Database error creating expense: ${e.message}');
    } catch (e) {
      // TODO: Map error
      print('Unexpected error creating expense: $e');
      throw Exception('Unexpected error creating expense: $e');
    }
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
     final userId = _getCurrentUserId(); // RLS should handle ownership
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          // .eq('user_id', userId) // RLS should handle this
          .maybeSingle();

      return response == null ? null : Expense.fromJson(response);
    } on PostgrestException catch (e) {
       // TODO: Map error
      print('Error fetching expense $id: ${e.message}');
      throw Exception('Database error fetching expense: ${e.message}');
    } catch (e) {
       // TODO: Map error
      print('Unexpected error fetching expense $id: $e');
      throw Exception('Unexpected error fetching expense: $e');
    }
  }

  @override
  Future<List<Expense>> getAllExpenses({DateTime? startDate, DateTime? endDate}) async {
    final userId = _getCurrentUserId(); // RLS should handle ownership
    try {
      // Build query with optional date filtering
      var query = _supabaseClient
          .from(_tableName)
          .select()
          // .eq('user_id', userId) // RLS handles this
          .order('date', ascending: false); // Order by expense date

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }
       if (endDate != null) {
         // Adjust end date to include the whole day if necessary
         final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
         query = query.lte('date', endOfDay.toIso8601String());
       }

      final response = await query;

      return response.map((json) => Expense.fromJson(json)).toList();
    } on PostgrestException catch (e) {
       // TODO: Map error
       print('Error fetching all expenses: ${e.message}');
      throw Exception('Database error fetching expenses: ${e.message}');
    } catch (e) {
       // TODO: Map error
      print('Unexpected error fetching all expenses: $e');
      throw Exception('Unexpected error fetching expenses: $e');
    }
  }

  @override
  Future<List<Expense>> getExpensesByPallet(String palletId) async {
     final userId = _getCurrentUserId(); // RLS should handle ownership
    try {
       final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('pallet_id', palletId)
          // .eq('user_id', userId) // RLS handles this
          .order('date', ascending: false);

       return response.map((json) => Expense.fromJson(json)).toList();
     } on PostgrestException catch (e) {
       // TODO: Map error
       print('Error fetching expenses for pallet $palletId: ${e.message}');
       throw Exception('Database error fetching expenses by pallet: ${e.message}');
     } catch (e) {
       // TODO: Map error
       print('Unexpected error fetching expenses for pallet $palletId: $e');
       throw Exception('Unexpected error fetching expenses by pallet: $e');
     }
  }

  @override
  Future<List<Expense>> getExpensesByItem(String itemId) async {
    // Note: Schema has pallet_id but not item_id on expenses.
    // This method might need adjustment based on how item-specific expenses are linked.
    // Assuming for now they might be linked via pallet_id if item belongs to a pallet.
    // Or, perhaps a separate expense type/table is needed for item-level expenses.
    print("Warning: Fetching expenses by item ID is not directly supported by current schema (expenses link to pallets). Returning empty list.");
    return []; // Placeholder - adjust if schema changes or logic differs

    /* // Example if expenses COULD link directly to items:
    final userId = _getCurrentUserId(); // RLS should handle ownership
    try {
       final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('item_id', itemId) // Assumes 'item_id' column exists
          // .eq('user_id', userId) // RLS handles this
          .order('date', ascending: false);

       return response.map((json) => Expense.fromJson(json)).toList();
     } on PostgrestException catch (e) {
       // TODO: Map error
       print('Error fetching expenses for item $itemId: ${e.message}');
       throw Exception('Database error fetching expenses by item: ${e.message}');
     } catch (e) {
       // TODO: Map error
       print('Unexpected error fetching expenses for item $itemId: $e');
       throw Exception('Unexpected error fetching expenses by item: $e');
     }
    */
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    final userId = _getCurrentUserId(); // RLS should handle ownership
    try {
      final expenseData = expense.toJson();
      expenseData.remove('id');
      expenseData.remove('user_id');
      expenseData['updated_at'] = DateTime.now().toIso8601String();

       // Convert category string if model uses enum
       // expenseData['category'] = expense.category?.name;

      final response = await _supabaseClient
          .from(_tableName)
          .update(expenseData)
          .eq('id', expense.id)
           // .eq('user_id', userId) // RLS handles this
          .select()
          .single();

      return Expense.fromJson(response);
    } on PostgrestException catch (e) {
       // TODO: Map error
       print('Error updating expense ${expense.id}: ${e.message}');
      throw Exception('Database error updating expense: ${e.message}');
    } catch (e) {
       // TODO: Map error
      print('Unexpected error updating expense ${expense.id}: $e');
      throw Exception('Unexpected error updating expense: $e');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
     final userId = _getCurrentUserId(); // RLS should handle ownership
     try {
       await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', id);
          // .eq('user_id', userId); // RLS handles this
     } on PostgrestException catch (e) {
        // TODO: Map error
        print('Error deleting expense $id: ${e.message}');
       throw Exception('Database error deleting expense: ${e.message}');
     } catch (e) {
        // TODO: Map error
       print('Unexpected error deleting expense $id: $e');
       throw Exception('Unexpected error deleting expense: $e');
     }
  }
} 