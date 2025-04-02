import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart'; // Placeholder, add shimmer dependency if not present
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:pallet_pro_app/src/routing/app_router.dart'; // Import route names
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/core/utils/responsive_utils.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';

import '../providers/item_list_provider.dart';
import '../providers/pallet_list_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/add_edit_pallet_screen.dart';
// TODO: Import Pallet and Item models if needed for display

// Placeholder ShimmerLoader - Replace with your actual implementation or package
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6, // Placeholder count
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48.0,
                height: 48.0,
                color: Colors.white,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Container(
                      width: 40.0,
                      height: 8.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Force rebuild when tab changes to update the FAB
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Coming in Phase 5.7:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• Filter by pallet source'),
            const Text('• Filter by storage location'),
            const Text('• Filter by sales channel'),
            const Text('• Filter by date added'),
            const Text('• Filter by price range'),
            const SizedBox(height: 16),
            const Text('These filters will allow you to quickly identify items across different categories.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should use drawer layout (same logic as AppShell)
    final bool useDrawerLayout = kIsWeb || !Platform.isIOS && !Platform.isAndroid;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? StyledTextField(
                controller: _searchController,
                hintText: 'Search inventory...',
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.scan),
            tooltip: 'Scan/Add Item',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scanning feature coming in Phase 5.7'))
              );
            },
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.inventory_2),
              text: 'Pallets',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'Items',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PalletsTab(searchQuery: _searchQuery),
          _ItemsTab(searchQuery: _searchQuery),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            // Navigate to Add Pallet screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddEditPalletScreen(),
              ),
            ).then((result) {
              if (result == true) {
                // Refresh the pallet list on successful add
                ref.read(palletListProvider.notifier).refreshPallets();
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pallet added successfully!'))
                );
              }
            });
          } else {
            // Item tab selected - show message for Phase 5.4
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add Item feature coming in Phase 5.4'))
            );
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Add Pallet' : 'Add Item'),
      ),
    );
  }
}

class _PalletsTab extends ConsumerWidget {
  final String searchQuery;

  const _PalletsTab({
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the real palletListProvider instead of the mock one
    final palletsAsync = ref.watch(palletListProvider);
    
    return palletsAsync.when(
      loading: () => const ShimmerLoader(),
      error: (error, stackTrace) => Center(
        child: Text('Error loading pallets: $error'),
      ),
      data: (pallets) {
        // Filter pallets based on search query
        final filteredPallets = searchQuery.isEmpty
            ? pallets
            : pallets.where((pallet) =>
                pallet.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (pallet.supplier?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                (pallet.source?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
              ).toList();
              
        return RefreshIndicator(
          onRefresh: () async {
            // Use the notifier's refresh method
            ref.read(palletListProvider.notifier).refreshPallets();
          },
          child: filteredPallets.isEmpty
            ? searchQuery.isNotEmpty
              ? Center(child: Text('No pallets match "$searchQuery"'))
              : _buildEmptyPalletsView(context)
            : ResponsiveUtils.responsiveWidget(
                context: context,
                mobile: _buildPalletsList(context, filteredPallets),
                tablet: _buildPalletsGrid(context, filteredPallets, 2),
                desktop: _buildPalletsGrid(context, filteredPallets, 3),
              ),
        );
      },
    );
  }
  
  Widget _buildEmptyPalletsView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.inventory, size: 72, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'No Pallets Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first pallet to get started tracking your inventory',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add First Pallet'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditPalletScreen(),
                ),
              ).then((result) {
                if (result == true) {
                  // Refresh the pallet list on successful add
                  final ref = ProviderScope.containerOf(context);
                  ref.read(palletListProvider.notifier).refreshPallets();
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pallet added successfully!'))
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPalletsList(BuildContext context, List<Pallet> pallets) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: pallets.length,
      itemBuilder: (context, index) {
        final pallet = pallets[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(pallet.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${pallet.supplier ?? "Unknown Supplier"}'),
                if (pallet.source != null && pallet.source!.isNotEmpty)
                  Text('Source: ${pallet.source}', 
                       style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
              ],
            ),
            trailing: Text('\$${pallet.cost.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              context.goNamed(
                RouterNotifier.palletDetail,
                pathParameters: {'pid': pallet.id}
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildPalletsGrid(BuildContext context, List<Pallet> pallets, int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: pallets.length,
      itemBuilder: (context, index) {
        final pallet = pallets[index];
        return Card(
          child: InkWell(
            onTap: () {
              context.goNamed(
                RouterNotifier.palletDetail,
                pathParameters: {'pid': pallet.id}
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pallet.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${pallet.supplier ?? "Unknown"}'),
                  if (pallet.source != null && pallet.source!.isNotEmpty)
                    Text('Source: ${pallet.source}', 
                         style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
                  const Spacer(),
                  Text('\$${pallet.cost.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ItemsTab extends ConsumerWidget {
  final String searchQuery;

  const _ItemsTab({
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(simpleItemListProvider);
    
    return itemsAsync.when(
      loading: () => const ShimmerLoader(),
      error: (error, stackTrace) => Center(
        child: Text('Error loading items: $error'),
      ),
      data: (items) {
        // Filter items based on search query
        final filteredItems = searchQuery.isEmpty
            ? items
            : items.where((item) =>
                (item.name?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                (item.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                (item.condition.toLowerCase().contains(searchQuery.toLowerCase()))
              ).toList();
              
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(simpleItemListProvider);
          },
          child: filteredItems.isEmpty
            ? searchQuery.isNotEmpty
              ? Center(child: Text('No items match "$searchQuery"'))
              : _buildEmptyItemsView(context)
            : ResponsiveUtils.responsiveWidget(
                context: context,
                mobile: _buildItemsList(context, filteredItems),
                tablet: _buildItemsGrid(context, filteredItems, 2),
                desktop: _buildItemsGrid(context, filteredItems, 3),
              ),
        );
      },
    );
  }
  
  Widget _buildEmptyItemsView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 72, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'No Items Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a pallet first, then add items to it',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Pallet First'),
            onPressed: () {
              // Switch to pallets tab
              (context.findAncestorStateOfType<_InventoryListScreenState>())?._tabController.animateTo(0);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildItemsList(BuildContext context, List<SimpleItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(AppIcons.item),
            ),
            title: Text(item.name ?? 'Unnamed Item'),
            subtitle: Text(
              'Condition: ${item.condition}\nQty: ${item.quantity}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${item.purchasePrice?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(item.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: item.status == 'forSale'
                          ? Colors.green
                          : item.status == 'sold' 
                              ? Colors.red
                              : Colors.orange,
                    )),
              ],
            ),
            onTap: () {
              context.goNamed(
                RouterNotifier.itemDetail,
                pathParameters: {'iid': item.id}
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildItemsGrid(BuildContext context, List<SimpleItem> items, int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: InkWell(
            onTap: () {
              context.goNamed(
                RouterNotifier.itemDetail,
                pathParameters: {'iid': item.id}
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Icon(AppIcons.item),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.name ?? 'Unnamed Item', 
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Condition: ${item.condition}',
                             style: const TextStyle(fontSize: 12),
                             overflow: TextOverflow.ellipsis),
                        Text('Qty: ${item.quantity}',
                             style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${item.purchasePrice?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(item.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: item.status == 'forSale'
                                ? Colors.green
                                : item.status == 'sold' 
                                    ? Colors.red
                                    : Colors.orange,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 