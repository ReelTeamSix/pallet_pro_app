import 'package:pallet_pro_app/src/features/inventory/data/models/expense.dart';
// Import custom exception/result types if defined

/// Abstract interface for managing Expense data.
abstract class ExpenseRepository {
  /// Creates a new expense record.
  Future<Expense> createExpense(Expense expense);

  /// Fetches an expense by its ID.
  Future<Expense?> getExpenseById(String id);

  /// Fetches all expenses (potentially with date range filtering).
  Future<List<Expense>> getAllExpenses({DateTime? startDate, DateTime? endDate});

  /// Fetches all expenses associated with a specific pallet.
  Future<List<Expense>> getExpensesByPallet(String palletId);

  /// Fetches all expenses associated with a specific item.
  Future<List<Expense>> getExpensesByItem(String itemId);

  /// Updates an existing expense record.
  Future<Expense> updateExpense(Expense expense);

  /// Deletes an expense record by its ID.
  Future<void> deleteExpense(String id);

  // Add other specific methods like filtering by category, calculating total expenses, etc.
} 