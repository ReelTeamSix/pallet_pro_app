import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/entities/simple_item.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_list_provider.dart';

/// A StateNotifier for managing a list of SimpleItem objects.
///
/// This provides filtering capabilities and synchronization with the full item data.
class SimpleItemListNotifier extends StateNotifier<List<SimpleItem>> {
  List<SimpleItem> _originalItems = [];
  String? _statusFilter;
  
  SimpleItemListNotifier() : super([]);
  
  /// Initialize with a list of SimpleItem objects.
  void initialize(List<SimpleItem> items) {
    _originalItems = List.from(items);
    _applyFilters();
  }
  
  /// Set filters to apply to the item list.
  void setFilters({String? statusFilter}) {
    _statusFilter = statusFilter;
    _applyFilters();
  }
  
  /// Apply the current filters to _originalItems and update state.
  void _applyFilters() {
    if (_statusFilter == null) {
      state = List.from(_originalItems); // No filters, show all items
    } else {
      // Apply status filter with proper null safety
      state = _originalItems.where((item) => 
        item.status.toLowerCase() == _statusFilter!.toLowerCase()
      ).toList();
    }
  }
  
  /// Clear all filters.
  void clearFilters() {
    _statusFilter = null;
    state = List.from(_originalItems);
  }
  
  /// Add a SimpleItem to the state.
  void addItem(SimpleItem item) {
    _originalItems.add(item);
    _applyFilters(); // Apply any active filters to the updated list
  }
}

/// Provider for the SimpleItemListNotifier.
final simpleItemListNotifierProvider = StateNotifierProvider<SimpleItemListNotifier, List<SimpleItem>>((ref) {
  final notifier = SimpleItemListNotifier();
  
  // Listen to the real data from itemListProvider
  ref.listen<AsyncValue<List<Item>>>(itemListProvider, (_, next) {
    print('itemListProvider update detected'); // Debug logging
    next.whenData((items) {
      print('Converting ${items.length} real items to SimpleItem objects'); // Debug logging
      
      // Convert Item objects to SimpleItem objects
      final simpleItems = items.map((item) => SimpleItem(
        id: item.id,
        name: item.name ?? 'Unnamed Item',
        description: item.description,
        palletId: item.palletId,
        condition: item.condition.name,
        quantity: item.quantity,
        purchasePrice: item.purchasePrice,
        status: item.status.name,
        storageLocation: item.storageLocation,
        salesChannel: item.salesChannel,
        createdAt: item.createdAt,
      )).toList();
      
      // Update the notifier state when real data changes
      notifier.initialize(simpleItems);
    });
  });
  
  // Force initial data fetch
  ref.read(itemListProvider.notifier).refreshItems();
  
  return notifier;
});

/// Future provider for the SimpleItemList.
///
/// This is a convenience provider that wraps the itemListProvider in an AsyncValue for proper
/// loading and error state handling.
final simpleItemListProvider = FutureProvider<List<SimpleItem>>((ref) async {
  // Watch the itemListProvider to get notified of changes
  final itemsAsync = ref.watch(itemListProvider);
  
  // Convert the AsyncValue to a Future that will complete when the data is available
  return itemsAsync.when(
    loading: () => Future.delayed(Duration.zero, () => <SimpleItem>[]),
    error: (error, stack) => Future.error(error, stack),
    data: (items) => Future.value(items.map((item) => SimpleItem(
      id: item.id,
      name: item.name ?? 'Unnamed Item',
      description: item.description,
      palletId: item.palletId,
      condition: item.condition.name,
      quantity: item.quantity,
      purchasePrice: item.purchasePrice,
      status: item.status.name,
      storageLocation: item.storageLocation,
      salesChannel: item.salesChannel,
      createdAt: item.createdAt,
    )).toList()),
  );
});

/// Extension to allow easier access to the notifier.
extension SimpleItemListProviderExtension on Provider<List<SimpleItem>> {
  StateNotifierProvider<SimpleItemListNotifier, List<SimpleItem>> get screenNotifierProvider => simpleItemListNotifierProvider;
} 