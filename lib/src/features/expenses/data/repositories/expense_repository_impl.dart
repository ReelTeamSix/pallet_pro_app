import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pallet_pro_app/src/features/expenses/data/models/expense.dart';
import 'package:pallet_pro_app/src/features/expenses/domain/repositories/expense_repository.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

class SupabaseExpenseRepository implements ExpenseRepository {
  final SupabaseClient _client;
  final String _userId;

  SupabaseExpenseRepository(this._client, this._userId);

  String get _tableName => 'expenses';

  @override
  Future<List<Expense>> fetchExpenses({DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = _client
          .from(_tableName)
          .select()
          .eq('user_id', _userId);

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }
      if (endDate != null) {
        // Adjust end date to include the entire day if necessary
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query.lte('date', endOfDay.toIso8601String());
      }

      query = query.order('date', ascending: false); // Order by date descending

      final response = await query;

      return (response as List).map((data) => Expense.fromJson(data)).toList();
    } on PostgrestException catch (e) {
      print('Error fetching expenses: ${e.message}');
      throw DatabaseException('Failed to fetch expenses: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred fetching expenses: $e');
    }
  }

  @override
  Future<Expense> createExpense(Expense expense) async {
    try {
      // Prepare data, ensure user_id is set, remove id/created_at
      final expenseData = expense.toJson()
        ..['user_id'] = _userId
        ..remove('id')
        ..remove('created_at');

      // Ensure date is formatted correctly
      expenseData['date'] = expense.date.toIso8601String();

      final response = await _client
          .from(_tableName)
          .insert(expenseData)
          .select()
          .single();

      return Expense.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error creating expense: ${e.message}');
      // Add specific error handling if needed (e.g., constraints)
      throw DatabaseException('Failed to create expense: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred creating expense: $e');
    }
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    try {
      // Prepare data, remove id/user_id/created_at
      final expenseData = expense.toJson()
        ..remove('id')
        ..remove('user_id')
        ..remove('created_at');

      // Ensure date is formatted correctly
      expenseData['date'] = expense.date.toIso8601String();

      final response = await _client
          .from(_tableName)
          .update(expenseData)
          .eq('id', expense.id)
          .eq('user_id', _userId) // Ensure user owns the expense
          .select()
          .single();

      return Expense.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error updating expense: ${e.message}');
      if (e.code == 'PGRST116' || e.details.contains('0 rows')) { // Resource Not Found
         throw NotFoundException('Expense not found or you do not have permission to update it.');
      }
      throw DatabaseException('Failed to update expense: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred updating expense: $e');
    }
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
     try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', expenseId)
          .eq('user_id', _userId); // Ensure user owns the expense

    } on PostgrestException catch (e) {
      print('Error deleting expense $expenseId: ${e.message}');
      throw DatabaseException('Failed to delete expense: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred deleting expense: $e');
    }
  }
} 