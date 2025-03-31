import 'package:pallet_pro_app/src/features/expenses/data/models/expense.dart';

/// Repository interface for expense operations.
abstract class ExpenseRepository {
  /// Fetches expenses for the current user, optionally within a date range.
  Future<List<Expense>> fetchExpenses({DateTime? startDate, DateTime? endDate});

  /// Creates a new expense.
  /// [expense] contains the data for the new expense (excluding id, user_id, created_at).
  Future<Expense> createExpense(Expense expense);

  /// Updates an existing expense.
  Future<Expense> updateExpense(Expense expense);

  /// Deletes an expense by its ID.
  Future<void> deleteExpense(int expenseId);

  // TODO: Consider adding methods for fetching by category, etc.
} 