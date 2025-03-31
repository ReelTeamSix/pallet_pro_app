import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/expenses/data/models/expense.dart';
import 'package:pallet_pro_app/src/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:pallet_pro_app/src/features/expenses/domain/repositories/expense_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_providers.dart'; // Access common providers

/// Provider for the ExpenseRepository implementation.
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(userIdProvider);
  return SupabaseExpenseRepository(client, userId);
});

/// FutureProvider to fetch the list of expenses for the current user.
/// TODO: Consider making this a family provider if date filtering is needed frequently at the provider level.
final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  try {
    // Fetch all expenses for now. Add parameters if needed later.
    return await repository.fetchExpenses();
  } catch (e) {
    print('Error fetching expenses via provider: $e');
    rethrow;
  }
});

// As with other repositories, create/update/delete operations are typically invoked
// directly from UI event handlers or state notifiers, followed by invalidating
// the `expensesProvider` to refresh the displayed list. 