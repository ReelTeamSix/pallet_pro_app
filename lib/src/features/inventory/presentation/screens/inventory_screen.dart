import 'dart:io'; // Added import for Platform
import 'package:flutter/foundation.dart'; // Added import for kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/core/utils/responsive_utils.dart';

/// The inventory screen.
class InventoryScreen extends StatefulWidget {
  /// Creates a new [InventoryScreen] instance.
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final bool useDrawerLayout = kIsWeb || !Platform.isIOS && !Platform.isAndroid;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search inventory...',
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: (value) {
                  // TODO: Implement search functionality
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
                  // TODO: Clear search results
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
          unselectedLabelColor: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.7),
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
          tabs: const [
            Tab(text: 'Pallets'),
            Tab(text: 'Items'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pallets tab
          _buildPalletsTab(),
          
          // Items tab
          _buildItemsTab(),
        ],
      ),
      // Conditionally display FAB based on layout
      floatingActionButton: useDrawerLayout 
          ? null // Don't show FAB on web/desktop
          : FloatingActionButton(
              onPressed: () {
                // Show dialog to add new pallet or item based on current tab
                final isItemsTab = _tabController.index == 1;
                _showAddDialog(isItemsTab);
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildPalletsTab() {
    // TODO: Replace with actual data from PalletListNotifier
    final pallets = <Map<String, dynamic>>[];
    
    if (pallets.isEmpty) {
      return _buildEmptyState(
        icon: AppIcons.pallet,
        title: 'No Pallets Yet',
        message: 'Add your first pallet to get started.',
        buttonText: 'Add Pallet',
        onPressed: () => _showAddDialog(false),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(context.spacingMd),
      itemCount: pallets.length,
      itemBuilder: (context, index) {
        final pallet = pallets[index];
        return Card(
          margin: EdgeInsets.only(bottom: context.spacingMd),
          child: ListTile(
            leading: Icon(AppIcons.pallet),
            title: Text(pallet['name'] as String),
            subtitle: Text('${pallet['itemCount'] as int} items'),
            trailing: Text('\$${pallet['totalValue'] as num}'),
            onTap: () {
              // TODO: Navigate to pallet detail screen
            },
          ),
        );
      },
    );
  }

  Widget _buildItemsTab() {
    // TODO: Replace with actual data from ItemListNotifier
    final items = <Map<String, dynamic>>[];
    
    if (items.isEmpty) {
      return _buildEmptyState(
        icon: AppIcons.item,
        title: 'No Items Yet',
        message: 'Add your first item to get started.',
        buttonText: 'Add Item',
        onPressed: () => _showAddDialog(true),
      );
    }
    
    return ResponsiveUtils.responsiveWidget(
      context: context,
      mobile: ListView.builder(
        padding: EdgeInsets.all(context.spacingMd),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: EdgeInsets.only(bottom: context.spacingMd),
            child: ListTile(
              leading: item['imageUrl'] != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(item['imageUrl'] as String),
                    )
                  : CircleAvatar(
                      child: Icon(AppIcons.item),
                    ),
              title: Text(item['name'] as String),
              subtitle: Text(item['palletName'] as String),
              trailing: Text('\$${item['sellingPrice'] as num}'),
              onTap: () {
                // TODO: Navigate to item detail screen
              },
            ),
          );
        },
      ),
      tablet: GridView.builder(
        padding: EdgeInsets.all(context.spacingMd),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: context.spacingMd,
          mainAxisSpacing: context.spacingMd,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: item['imageUrl'] != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(item['imageUrl'] as String),
                    )
                  : CircleAvatar(
                      child: Icon(AppIcons.item),
                    ),
              title: Text(item['name'] as String),
              subtitle: Text(item['palletName'] as String),
              trailing: Text('\$${item['sellingPrice'] as num}'),
              onTap: () {
                // TODO: Navigate to item detail screen
              },
            ),
          );
        },
      ),
      desktop: GridView.builder(
        padding: EdgeInsets.all(context.spacingMd),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3,
          crossAxisSpacing: context.spacingMd,
          mainAxisSpacing: context.spacingMd,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: item['imageUrl'] != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(item['imageUrl'] as String),
                    )
                  : CircleAvatar(
                      child: Icon(AppIcons.item),
                    ),
              title: Text(item['name'] as String),
              subtitle: Text(item['palletName'] as String),
              trailing: Text('\$${item['sellingPrice'] as num}'),
              onTap: () {
                // TODO: Navigate to item detail screen
              },
            ),
          );
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
            Icon(
              icon,
              size: 80,
              color: Colors.grey,
            ),
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
              icon: Icon(Icons.add),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(bool isItem) {
    // TODO: Implement add pallet/item dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isItem ? 'Add Item' : 'Add Pallet'),
        content: Text(
          'This is a placeholder. In the full implementation, this would show a form to add a new ${isItem ? 'item' : 'pallet'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
