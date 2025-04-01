import 'package:flutter_test/flutter_test.dart';

// Test-only model class
class TestItem {
  final String id;
  final String name;
  final double value;

  TestItem({
    required this.id,
    required this.name,
    required this.value,
  });

  TestItem copyWith({
    String? id,
    String? name,
    double? value,
  }) {
    return TestItem(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }
}

// Test-only repository interface
abstract class TestRepository {
  Future<TestItem> createItem(TestItem item);
  Future<TestItem?> getItemById(String id);
  Future<List<TestItem>> getAllItems();
  Future<TestItem> updateItem(TestItem item);
  Future<void> deleteItem(String id);
}

// In-memory repository implementation for testing
class InMemoryTestRepository implements TestRepository {
  final Map<String, TestItem> _items = {};
  bool _throwsOnNextOperation = false;
  bool _isAuthenticated = true;

  void setAuthenticated(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
  }

  void setThrowsOnNextOperation(bool shouldThrow) {
    _throwsOnNextOperation = shouldThrow;
  }

  @override
  Future<TestItem> createItem(TestItem item) async {
    if (!_isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    if (_throwsOnNextOperation) {
      _throwsOnNextOperation = false;
      throw Exception('Database error creating item: Simulated error');
    }
    
    _items[item.id] = item;
    return item;
  }

  @override
  Future<TestItem?> getItemById(String id) async {
    if (!_isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    if (_throwsOnNextOperation) {
      _throwsOnNextOperation = false;
      throw Exception('Database error fetching item: Simulated error');
    }
    
    return _items[id];
  }

  @override
  Future<List<TestItem>> getAllItems() async {
    if (!_isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    if (_throwsOnNextOperation) {
      _throwsOnNextOperation = false;
      throw Exception('Database error fetching items: Simulated error');
    }
    
    return _items.values.toList();
  }

  @override
  Future<TestItem> updateItem(TestItem item) async {
    if (!_isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    if (_throwsOnNextOperation) {
      _throwsOnNextOperation = false;
      throw Exception('Database error updating item: Simulated error');
    }
    
    if (!_items.containsKey(item.id)) {
      throw Exception('Item not found');
    }
    
    _items[item.id] = item;
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    if (!_isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    if (_throwsOnNextOperation) {
      _throwsOnNextOperation = false;
      throw Exception('Database error deleting item: Simulated error');
    }
    
    _items.remove(id);
  }
}

void main() {
  late InMemoryTestRepository repository;
  
  // Sample test data
  final testItem = TestItem(
    id: 'test-id',
    name: 'Test Item',
    value: 100.0,
  );

  final updatedItem = TestItem(
    id: 'test-id',
    name: 'Updated Item',
    value: 150.0,
  );

  setUp(() {
    repository = InMemoryTestRepository();
    repository.setAuthenticated(true);
  });

  group('Repository Pattern Tests', () {
    group('createItem', () {
      test('creates an item successfully', () async {
        // Call the method
        final result = await repository.createItem(testItem);

        // Verify result
        expect(result.id, equals(testItem.id));
        expect(result.name, equals(testItem.name));
        expect(result.value, equals(testItem.value));
      });

      test('throws Exception when database error occurs', () async {
        // Set up to throw error
        repository.setThrowsOnNextOperation(true);

        // Assert that it throws the expected type
        expect(
          () => repository.createItem(testItem),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Database error creating item'),
          )),
        );
      });
    });

    group('getItemById', () {
      test('returns item when found', () async {
        // Setup existing item
        await repository.createItem(testItem);
        
        // Call the method
        final result = await repository.getItemById('test-id');

        // Verify result
        expect(result, isNotNull);
        expect(result!.id, equals(testItem.id));
      });

      test('returns null when item not found', () async {
        // Call the method for non-existent id
        final result = await repository.getItemById('non-existent-id');

        // Verify result
        expect(result, isNull);
      });

      test('throws Exception when database error occurs', () async {
        // Set up to throw error
        repository.setThrowsOnNextOperation(true);

        // Assert that it throws the expected type
        expect(
          () => repository.getItemById('test-id'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Database error fetching item'),
          )),
        );
      });
    });

    group('getAllItems', () {
      test('returns list of items', () async {
        // Setup existing items
        await repository.createItem(testItem);
        await repository.createItem(testItem.copyWith(id: 'test-id-2', name: 'Second Item'));

        // Call the method
        final result = await repository.getAllItems();

        // Verify result
        expect(result.length, equals(2));
        expect(result.any((p) => p.id == 'test-id'), isTrue);
        expect(result.any((p) => p.id == 'test-id-2'), isTrue);
      });

      test('returns empty list when no items found', () async {
        // Call the method with no items created
        final result = await repository.getAllItems();

        // Verify result
        expect(result, isEmpty);
      });

      test('throws Exception when database error occurs', () async {
        // Set up to throw error
        repository.setThrowsOnNextOperation(true);

        // Assert that it throws the expected type
        expect(
          () => repository.getAllItems(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Database error fetching items'),
          )),
        );
      });
    });

    group('updateItem', () {
      test('updates item successfully', () async {
        // Setup existing item
        await repository.createItem(testItem);
        
        // Call the method with updated item
        final result = await repository.updateItem(updatedItem);

        // Verify result
        expect(result.id, equals(updatedItem.id));
        expect(result.name, equals(updatedItem.name));
        expect(result.value, equals(updatedItem.value));
      });

      test('throws Exception when item not found', () async {
        // Try to update non-existent item
        expect(
          () => repository.updateItem(updatedItem),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Item not found'),
          )),
        );
      });

      test('throws Exception when database error occurs', () async {
        // Setup existing item
        await repository.createItem(testItem);
        
        // Set up to throw error
        repository.setThrowsOnNextOperation(true);

        // Assert that it throws the expected type
        expect(
          () => repository.updateItem(updatedItem),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Database error updating item'),
          )),
        );
      });
    });

    group('deleteItem', () {
      test('deletes item successfully', () async {
        // Setup existing item
        await repository.createItem(testItem);
        
        // Call the method
        await repository.deleteItem('test-id');
        
        // Verify item is deleted
        final result = await repository.getItemById('test-id');
        expect(result, isNull);
      });

      test('throws Exception when database error occurs', () async {
        // Set up to throw error
        repository.setThrowsOnNextOperation(true);

        // Assert that it throws the expected type
        expect(
          () => repository.deleteItem('test-id'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Database error deleting item'),
          )),
        );
      });
    });

    test('throws Exception when user is not authenticated', () async {
      // Set unauthenticated state
      repository.setAuthenticated(false);

      // Assert that it throws the expected type for any method
      expect(
        () => repository.getAllItems(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User not authenticated'),
        )),
      );
    });
  });
} 