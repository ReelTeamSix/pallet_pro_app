import 'dart:io'; // Added import for Platform

import 'package:flutter/foundation.dart'; // Added import for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/status_colors.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/core/utils/responsive_utils.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_list_controller.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_controller.dart';
import 'package:pallet_pro_app/src/global/widgets/item_card.dart';
import 'package:pallet_pro_app/src/global/widgets/pallet_card.dart';

/// Filter options for inventory items.
enum ItemFilter {
  all('All'),
  inStock('In Stock'),
  listed('Listed'),
  sold('Sold');

  const ItemFilter(this.label);
  final String label;
}

/// The inventory screen.
class InventoryScreen extends ConsumerStatefulWidget {
  /// Creates a new [InventoryScreen] instance.
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  ItemFilter _selectedFilter = ItemFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listen for tab changes to update FAB label
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should use drawer layout (same logic as AppShell)
    final bool useDrawerLayout =
        kIsWeb || !Platform.isIOS && !Platform.isAndroid;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search inventory...',
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: (value) {
                  // TODO: Implement search functionality
                  setState(() {});
                },
              )
            : const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.scan),
            tooltip: 'Scan/Add Item',
            onPressed: () {
              context.go('/scan');
            },
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedLabelColor: Theme.of(
            context,
          ).appBarTheme.foregroundColor?.withValues(alpha: 0.7),
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
          tabs: const [
            Tab(text: 'Pallets'),
            Tab(text: 'Items'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter chips row (per UI/UX Guidelines Section 15)
          _buildFilterChips(),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pallets tab
                _buildPalletsTab(),
                // Items tab
                _buildItemsTab(),
              ],
            ),
          ),
        ],
      ),
      // Extended FAB (per UI/UX Guidelines Section 15)
      floatingActionButton: useDrawerLayout
          ? null // Don't show FAB on web/desktop
          : FloatingActionButton.extended(
              onPressed: () {
                // Show dialog to add new pallet or item based on current tab
                final isItemsTab = _tabController.index == 1;
                _showAddDialog(isItemsTab);
              },
              icon: const Icon(Icons.add),
              label: Text(_tabController.index == 1 ? 'Add Item' : 'Add Pallet'),
            ),
    );
  }

  /// Builds the horizontal filter chip bar.
  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacingMd,
        vertical: context.spacingSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ItemFilter.values.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                key: ValueKey('filter_${filter.name}'),
                label: Text(filter.label),
                selected: isSelected,
                onSelected: (selected) {
                  // Haptic feedback on selection (per UI/UX Guidelines)
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                selectedColor: StatusColors.forItemStatus(
                  filter == ItemFilter.inStock
                      ? 'in_stock'
                      : filter == ItemFilter.listed
                          ? 'listed'
                          : filter == ItemFilter.sold
                              ? 'sold'
                              : 'unknown',
                ).withValues(alpha: 0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPalletsTab() {
    final palletListAsync = ref.watch(palletListControllerProvider);

    return palletListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(
        error: error.toString(),
        onRetry: () =>
            ref.read(palletListControllerProvider.notifier).refresh(),
      ),
      data: (pallets) {
        // Apply search filter if searching
        var filteredPallets = pallets;
        if (_isSearching && _searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          filteredPallets = pallets
              .where(
                (p) =>
                    p.name.toLowerCase().contains(query) ||
                    (p.supplier?.toLowerCase().contains(query) ?? false),
              )
              .toList();
        }

        if (filteredPallets.isEmpty) {
          if (_isSearching && _searchController.text.isNotEmpty) {
            return _buildEmptyState(
              icon: Icons.search_off,
              title: 'No Results',
              message: 'No pallets match "${_searchController.text}"',
              buttonText: 'Clear Search',
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _isSearching = false;
                });
              },
            );
          }
          return _buildEmptyState(
            icon: AppIcons.pallet,
            title: 'No Pallets Yet',
            message:
                'Add your first pallet to get started tracking your profit.',
            buttonText: 'Add Pallet',
            onPressed: () => _showAddDialog(false),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(palletListControllerProvider.notifier).refresh(),
          child: ListView.builder(
            padding: EdgeInsets.all(context.spacingMd),
            itemCount: filteredPallets.length,
            itemBuilder: (context, index) {
              final pallet = filteredPallets[index];
              return _buildPalletCard(pallet);
            },
          ),
        );
      },
    );
  }

  Widget _buildPalletCard(Pallet pallet) {
    // TODO: Get actual item count and revenue from items
    // For now, using placeholder values until we implement computed properties
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacingMd),
      child: PalletCard(
        id: pallet.id,
        name: pallet.name,
        supplier: pallet.supplier,
        source: pallet.type, // Using type as source for now
        cost: pallet.cost,
        status: 'in_progress', // TODO: Add status to Pallet model
        onTap: () {
          // TODO: Navigate to pallet detail screen
          context.go('/inventory/pallets/${pallet.id}');
        },
      ),
    );
  }

  Widget _buildItemsTab() {
    final itemListAsync = ref.watch(itemListControllerProvider);

    return itemListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(
        error: error.toString(),
        onRetry: () => ref.read(itemListControllerProvider.notifier).refresh(),
      ),
      data: (items) {
        // Apply status filter first
        var filteredItems = items;
        if (_selectedFilter != ItemFilter.all) {
          filteredItems = items.where((item) {
            switch (_selectedFilter) {
              case ItemFilter.inStock:
                return item.status == ItemStatus.inStock;
              case ItemFilter.listed:
                return item.status == ItemStatus.forSale;
              case ItemFilter.sold:
                return item.status == ItemStatus.sold;
              case ItemFilter.all:
                return true;
            }
          }).toList();
        }

        // Then apply search filter if searching
        if (_isSearching && _searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          filteredItems = filteredItems
              .where(
                (i) =>
                    i.name.toLowerCase().contains(query) ||
                    (i.description?.toLowerCase().contains(query) ?? false),
              )
              .toList();
        }

        if (filteredItems.isEmpty) {
          if (_isSearching && _searchController.text.isNotEmpty) {
            return _buildEmptyState(
              icon: Icons.search_off,
              title: 'No Results',
              message: 'No items match "${_searchController.text}"',
              buttonText: 'Clear Search',
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _isSearching = false;
                });
              },
            );
          }
          if (_selectedFilter != ItemFilter.all) {
            return _buildEmptyState(
              icon: Icons.filter_list_off,
              title: 'No ${_selectedFilter.label} Items',
              message: 'No items match the selected filter.',
              buttonText: 'Clear Filter',
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFilter = ItemFilter.all;
                });
              },
            );
          }
          return _buildEmptyState(
            icon: AppIcons.item,
            title: 'No Items Yet',
            message: 'Add items to your pallets to track individual sales.',
            buttonText: 'Add Item',
            onPressed: () => _showAddDialog(true),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(itemListControllerProvider.notifier).refresh(),
          child: ResponsiveUtils.responsiveWidget(
            context: context,
            mobile: _buildItemListView(filteredItems),
            tablet: _buildItemGridView(filteredItems, crossAxisCount: 2),
            desktop: _buildItemGridView(filteredItems, crossAxisCount: 3),
          ),
        );
      },
    );
  }

  Widget _buildItemListView(List<Item> items) {
    return ListView.builder(
      padding: EdgeInsets.all(context.spacingMd),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index]);
      },
    );
  }

  Widget _buildItemGridView(List<Item> items, {required int crossAxisCount}) {
    return GridView.builder(
      padding: EdgeInsets.all(context.spacingMd),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2.5, // Wider cards for the new design
        crossAxisSpacing: context.spacingMd,
        mainAxisSpacing: context.spacingMd,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index]);
      },
    );
  }

  Widget _buildItemCard(Item item) {
    // Convert ItemStatus enum to string for the card
    final statusString = item.status.name;

    // Determine if item is stale (listed for more than 30 days without selling)
    // TODO: Get stale threshold from user settings
    const staleDays = 30;
    final isStale =
        item.status == ItemStatus.forSale &&
        item.acquiredDate != null &&
        DateTime.now().difference(item.acquiredDate!).inDays > staleDays;

    return Padding(
      padding: EdgeInsets.only(bottom: context.spacingMd),
      child: ItemCard(
        id: item.id,
        name: item.name,
        status: statusString,
        allocatedCost: item.allocatedCost ?? item.purchasePrice ?? 0,
        listingPrice: item.salePrice,
        soldPrice: item.status == ItemStatus.sold ? item.salePrice : null,
        listedDate: item.acquiredDate,
        soldDate: item.soldDate,
        isStale: isStale,
        onTap: () {
          // TODO: Navigate to item detail screen
          context.go('/inventory/items/${item.id}');
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            SizedBox(height: context.spacingMd),
            Text(
              title,
              style: context.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacingSm),
            Text(
              message,
              style: context.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacingLg),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required String error,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: context.spacingMd),
            Text(
              'Connection hiccup',
              style: context.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacingSm),
            Text(
              error,
              style: context.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.spacingLg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tap to retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(bool isItem) {
    // TODO: Navigate to AddEditPalletScreen or AddEditItemScreen
    if (isItem) {
      // For items, we need a pallet to add to
      // Show pallet selection first or navigate to add item screen
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Item'),
          content: const Text(
            'To add an item, please first select a pallet from the Pallets tab.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Navigate to add pallet screen
      context.go('/inventory/pallets/add');
    }
  }
}
