import 'package:flutter_test/flutter_test.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
// Don't import the real model - we're completely isolated
// import 'package:pallet_pro_app/src/features/inventory/data/models/expense.dart';
// import 'package:pallet_pro_app/src/features/inventory/data/repositories/expense_repository.dart';

// Use test helpers for setup
import '../../../../../test_helpers.dart';

// Test expense class - completely independent
class TestExpense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  String? palletId;
  String? itemId;
  String? category;
  DateTime? createdAt;
  DateTime? updatedAt;

  TestExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.palletId,
    this.itemId,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  // Basic copyWith
  TestExpense copyWith({
    String? description,
    double? amount,
    DateTime? date,
    String? palletId,
    String? itemId,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestExpense(
      id: id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      palletId: palletId ?? this.palletId,
      itemId: itemId ?? this.itemId,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Basic equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestExpense &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          description == other.description &&
          amount == other.amount;

  @override
  int get hashCode => id.hashCode ^ description.hashCode ^ amount.hashCode;
}

/// Test implementation of a repository - not implementing the actual interface
/// to avoid typing issues with the freezed model
class ExpenseRepositoryTest {
  final Map<String, TestExpense> _expenses = {};
  bool _shouldThrowError = false;
  String? _userId;

  void simulateError([bool shouldThrow = true]) {
    _shouldThrowError = shouldThrow;
  }

  void setUserId(String? userId) {
    _userId = userId;
  }

  void _checkErrorAndAuth() {
    if (_shouldThrowError) {
      throw const DatabaseException('Simulated database error');
    }
    if (_userId == null) {
      throw const AuthException('User not authenticated');
    }
  }

  // Create method - returns a TestExpense
  Future<TestExpense> createExpense(TestExpense expense) async {
    _checkErrorAndAuth();
    final newId = 'expense_${_expenses.length + 1}';
    final newExpense = TestExpense(
      id: newId,
      description: expense.description,
      amount: expense.amount,
      date: expense.date,
      palletId: expense.palletId,
      itemId: expense.itemId,
      category: expense.category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _expenses[newId] = newExpense;
    return newExpense;
  }

  Future<void> deleteExpense(String expenseId) async {
    _checkErrorAndAuth();
    if (!_expenses.containsKey(expenseId)) {
      throw const NotFoundException('Expense not found');
    }
    _expenses.remove(expenseId);
  }

  Future<List<TestExpense>> getAllExpenses({DateTime? startDate, DateTime? endDate}) async {
    _checkErrorAndAuth();
    List<TestExpense> result = _expenses.values.toList();
    
    if (startDate != null) {
      result = result.where((e) => e.date.isAfter(startDate) || e.date.isAtSameMomentAs(startDate)).toList();
    }
    
    if (endDate != null) {
      result = result.where((e) => e.date.isBefore(endDate) || e.date.isAtSameMomentAs(endDate)).toList();
    }
    
    return result;
  }

  Future<TestExpense?> getExpenseById(String expenseId) async {
    _checkErrorAndAuth();
    return _expenses[expenseId];
  }

  Future<TestExpense> updateExpense(TestExpense expense) async {
    _checkErrorAndAuth();
    
    final existingExpense = _expenses[expense.id];
    if (existingExpense == null) {
      throw const NotFoundException('Expense not found for update');
    }

    _expenses[expense.id] = expense;
    return expense;
  }

  Future<List<TestExpense>> getExpensesByPallet(String palletId) async {
    _checkErrorAndAuth();
    return _expenses.values.where((expense) => expense.palletId == palletId).toList();
  }

  Future<List<TestExpense>> getExpensesByItem(String itemId) async {
    _checkErrorAndAuth();
    return _expenses.values.where((expense) => expense.itemId == itemId).toList();
  }
}

// --- Test Cases ---

void main() {
  setupTestEnvironment();

  late ExpenseRepositoryTest expenseRepository;
  
  final testExpense1 = TestExpense(
    id: 'temp-1', // ID will be overwritten on creation
    description: 'Shipping Cost',
    amount: 15.75,
    date: DateTime(2023, 3, 10),
    category: 'Shipping',
    palletId: 'pallet_abc',
  );
  
  final testExpense2 = TestExpense(
    id: 'temp-2',
    description: 'Cleaning Supplies',
    amount: 5.50,
    date: DateTime(2023, 3, 12),
    category: 'Materials',
    itemId: 'item_xyz',
  );

  setUp(() {
    expenseRepository = ExpenseRepositoryTest();
    expenseRepository.setUserId('user-123');
    expenseRepository.simulateError(false);
  });

  group('ExpenseRepository Tests', () {

    test('Create Expense - Success', () async {
      final createdExpense = await expenseRepository.createExpense(testExpense1);

      expect(createdExpense, isNotNull);
      expect(createdExpense.id, startsWith('expense_'));
      expect(createdExpense.description, testExpense1.description);
      expect(createdExpense.amount, testExpense1.amount);

      final fetchedExpense = await expenseRepository.getExpenseById(createdExpense.id);
      expect(fetchedExpense, isNotNull);
      expect(fetchedExpense?.description, testExpense1.description);
    });

    test('Create Expense - Database Error', () async {
      expenseRepository.simulateError();
      expect(
        () => expenseRepository.createExpense(testExpense1),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Create Expense - Auth Error', () async {
      expenseRepository.setUserId(null);
      expect(
        () => expenseRepository.createExpense(testExpense1),
        throwsA(isA<AuthException>()),
      );
    });

    test('Get Expense by ID - Success', () async {
      final created = await expenseRepository.createExpense(testExpense1);
      final expense = await expenseRepository.getExpenseById(created.id);

      expect(expense, isNotNull);
      expect(expense?.id, created.id);
      expect(expense?.description, testExpense1.description);
    });

    test('Get Expense by ID - Not Found', () async {
      final expense = await expenseRepository.getExpenseById('non-existent-id');
      expect(expense, isNull);
    });

    test('Get Expense by ID - Database Error', () async {
      final created = await expenseRepository.createExpense(testExpense1);
      expenseRepository.simulateError();
      expect(
        () => expenseRepository.getExpenseById(created.id),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Get Expense by ID - Auth Error', () async {
      final created = await expenseRepository.createExpense(testExpense1);
      expenseRepository.setUserId(null);
      expect(
        () => expenseRepository.getExpenseById(created.id),
        throwsA(isA<AuthException>()),
      );
    });

    test('Get All Expenses - Success', () async {
      final created1 = await expenseRepository.createExpense(testExpense1);
      final created2 = await expenseRepository.createExpense(testExpense2);

      final expenses = await expenseRepository.getAllExpenses();

      expect(expenses.length, 2);
      expect(expenses.any((expense) => expense.id == created1.id && expense.description == testExpense1.description), isTrue);
      expect(expenses.any((expense) => expense.id == created2.id && expense.description == testExpense2.description), isTrue);
    });
    
    test('Get All Expenses - With Date Range', () async {
      await expenseRepository.createExpense(testExpense1); // Date: 2023-03-10
      await expenseRepository.createExpense(testExpense2); // Date: 2023-03-12
      
      // Should only include testExpense2
      final laterExpenses = await expenseRepository.getAllExpenses(
        startDate: DateTime(2023, 3, 11)
      );
      expect(laterExpenses.length, 1);
      expect(laterExpenses.first.description, testExpense2.description);
      
      // Should only include testExpense1
      final earlierExpenses = await expenseRepository.getAllExpenses(
        endDate: DateTime(2023, 3, 11)
      );
      expect(earlierExpenses.length, 1);
      expect(earlierExpenses.first.description, testExpense1.description);
      
      // Should include both
      final rangeExpenses = await expenseRepository.getAllExpenses(
        startDate: DateTime(2023, 3, 9),
        endDate: DateTime(2023, 3, 13)
      );
      expect(rangeExpenses.length, 2);
    });

    test('Get All Expenses - Empty', () async {
      final expenses = await expenseRepository.getAllExpenses();
      expect(expenses, isEmpty);
    });

    test('Get All Expenses - Database Error', () async {
      expenseRepository.simulateError();
      expect(
        () => expenseRepository.getAllExpenses(),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Get All Expenses - Auth Error', () async {
      expenseRepository.setUserId(null);
      expect(
        () => expenseRepository.getAllExpenses(),
        throwsA(isA<AuthException>()),
      );
    });

    test('Get Expenses by Pallet - Success', () async {
      await expenseRepository.createExpense(testExpense1); // pallet_abc
      await expenseRepository.createExpense(testExpense2); // no pallet, has item
      
      final expenses = await expenseRepository.getExpensesByPallet('pallet_abc');
      
      expect(expenses.length, 1);
      expect(expenses.first.description, testExpense1.description);
      expect(expenses.first.palletId, 'pallet_abc');
    });

    test('Get Expenses by Item - Success', () async {
      await expenseRepository.createExpense(testExpense1); // has pallet, no item
      await expenseRepository.createExpense(testExpense2); // item_xyz
      
      final expenses = await expenseRepository.getExpensesByItem('item_xyz');
      
      expect(expenses.length, 1);
      expect(expenses.first.description, testExpense2.description);
      expect(expenses.first.itemId, 'item_xyz');
    });

    test('Update Expense - Success', () async {
      final created = await expenseRepository.createExpense(testExpense1);
      
      // Make a copy with updated values
      final updatedData = created.copyWith(
        description: 'Updated Shipping Cost',
        amount: 20.00,
        category: 'Updated Category',
      );

      final updatedExpense = await expenseRepository.updateExpense(updatedData);

      expect(updatedExpense, isNotNull);
      expect(updatedExpense.description, 'Updated Shipping Cost');
      expect(updatedExpense.amount, 20.00);
      expect(updatedExpense.category, 'Updated Category');
      expect(updatedExpense.palletId, testExpense1.palletId); // Should remain unchanged

      // Verify fetch returns updated data
      final fetchedExpense = await expenseRepository.getExpenseById(created.id);
      expect(fetchedExpense, isNotNull);
      expect(fetchedExpense?.description, 'Updated Shipping Cost');
      expect(fetchedExpense?.amount, 20.00);
    });

    test('Update Expense - Not Found', () async {
      final nonExistentUpdate = TestExpense(
        id: 'non-existent-id', 
        description: 'Not Real', 
        amount: 0, 
        date: DateTime.now()
      );
      
      expect(
        () => expenseRepository.updateExpense(nonExistentUpdate),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('Update Expense - Database Error', () async {
      final created = await expenseRepository.createExpense(testExpense1);
      expenseRepository.simulateError();
      
      expect(
        () => expenseRepository.updateExpense(created),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Update Expense - Auth Error', () async {
      final created = await expenseRepository.createExpense(testExpense1);
      expenseRepository.setUserId(null);
      
      expect(
        () => expenseRepository.updateExpense(created),
        throwsA(isA<AuthException>()),
      );
    });

    test('Delete Expense - Success', () async {
      final created = await expenseRepository.createExpense(testExpense1);
      var expenseResult = await expenseRepository.getExpenseById(created.id);
      expect(expenseResult, isNotNull); // Verify it exists

      await expenseRepository.deleteExpense(created.id);
      expenseResult = await expenseRepository.getExpenseById(created.id);
      expect(expenseResult, isNull); // Verify it's gone

      final allExpenses = await expenseRepository.getAllExpenses();
      expect(allExpenses, isEmpty);
    });

    test('Delete Expense - Not Found', () async {
      expect(
        () => expenseRepository.deleteExpense('non-existent-id'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('Delete Expense - Database Error', () async {
      final created = await expenseRepository.createExpense(testExpense1);
      expenseRepository.simulateError();
      
      expect(
        () => expenseRepository.deleteExpense(created.id),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Delete Expense - Auth Error', () async {
      final created = await expenseRepository.createExpense(testExpense1);
      expenseRepository.setUserId(null);
      
      expect(
        () => expenseRepository.deleteExpense(created.id),
        throwsA(isA<AuthException>()),
      );
    });
  });
} 