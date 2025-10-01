import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart'; // Placeholder, add shimmer dependency if not present
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:pallet_pro_app/src/routing/app_router.dart'; // Import route names
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math' as math; // Add math library
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/core/utils/responsive_utils.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';
import 'package:pallet_pro_app/src/global/widgets/inventory_item_card.dart';
import 'package:pallet_pro_app/src/global/widgets/pallet_card.dart';
import 'package:pallet_pro_app/src/core/utils/string_formatter.dart';
import 'package:pallet_pro_app/src/global/widgets/status_chip.dart';
import 'package:pallet_pro_app/src/core/theme/status_colors.dart';

import '../providers/item_list_provider.dart';
import '../providers/pallet_list_provider.dart';
import '../providers/simple_item_list_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/entities/simple_item.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/add_edit_pallet_screen.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/add_edit_item_screen.dart';
// TODO: Import Pallet and Item models if needed for display

// Placeholder ShimmerLoader - Replace with your actual implementation or package
class ShimmerLoader extends StatelessWidget {
  final int itemCount;

  const ShimmerLoader({
    Key? key,
    this.itemCount = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: itemCount, // Placeholder count
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
  
  // Status filter variables
  String? _palletStatusFilter;
  String? _itemStatusFilter;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    
    // Refresh providers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Force refreshing providers on screen init');
      ref.read(itemListProvider.notifier).refreshItems();
      ref.read(palletListProvider.notifier).refreshPallets();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will ensure the providers are refreshed whenever the screen becomes active again
    // Instead of invalidating, which can cause initialization issues, use the refresh methods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController.index == 1) {
        // Items tab - refresh items
        ref.read(itemListProvider.notifier).refreshItems();
      } else {
        // Pallets tab - refresh pallets
        ref.read(palletListProvider.notifier).refreshPallets();
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Force rebuild when tab changes to update the FAB
    if (_tabController.indexIsChanging) {
      setState(() {});
      
      // When switching to the Items tab (index 1), refresh the item list
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tabController.index == 1) {
          // Items tab - refresh items
          ref.read(itemListProvider.notifier).refreshItems();
        } else {
          // Pallets tab - refresh pallets
          ref.read(palletListProvider.notifier).refreshPallets();
        }
      });
    }
  }

  // Updated filter dialog to include status filtering
  void _showFilterDialog() {
    if (_tabController.index == 0) {
      // Pallet filter dialog
      _showPalletFilterDialog();
    } else {
      // Item filter dialog
      _showItemFilterDialog();
    }
  }
  
  void _showPalletFilterDialog() {
    // Get pallet status enum values
    final palletStatuses = PalletStatus.values.map((e) => e.name).toList();
    
    // Local variable to track the selected filter during dialog interaction
    String? selectedStatus = _palletStatusFilter;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Pallets'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // Status filter options
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: selectedStatus == null,
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = null;
                      });
                    },
                  ),
                  ...palletStatuses.map((status) => FilterChip(
                    label: Text(_formatStatus(status)),
                    selected: selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = selected ? status : null;
                      });
                    },
                  )),
                ],
              ),
              
              const SizedBox(height: 16),
              const Text('Coming soon:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('• Filter by pallet source'),
              const Text('• Filter by date added'),
              const Text('• Filter by cost range'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply the selected filters
                setState(() {
                  _palletStatusFilter = selectedStatus;
                });
                
                // Apply filter using Provider
                ref.read(palletListProvider.notifier).setFilters(
                  statusFilter: selectedStatus,
                );
                
                context.pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showItemFilterDialog() {
    // Get item status enum values
    final itemStatuses = ItemStatus.values.map((e) => e.name).toList();
    
    // Local variable to track the selected filter during dialog interaction
    String? selectedStatus = _itemStatusFilter;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // Status filter options
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: selectedStatus == null,
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = null;
                      });
                    },
                  ),
                  ...itemStatuses.map((status) => FilterChip(
                    label: Text(_formatStatus(status)),
                    selected: selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = selected ? status : null;
                      });
                    },
                  )),
                ],
              ),
              
              const SizedBox(height: 16),
              const Text('Coming soon:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('• Filter by storage location'),
              const Text('• Filter by sales channel'),
              const Text('• Filter by date added'),
              const Text('• Filter by price range'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply the selected filters
                setState(() {
                  _itemStatusFilter = selectedStatus;
                });
                
                // Instead of using simpleItemListProvider, we'll set status filter
                // on the itemListProvider directly
                if (selectedStatus != null) {
                  // Convert the string status to enum
                  final ItemStatus? enumStatus = _stringToItemStatus(selectedStatus);
                  if (enumStatus != null) {
                    ref.read(itemListProvider.notifier).setFilters(
                      statusFilter: enumStatus,
                    );
                  }
                } else {
                  ref.read(itemListProvider.notifier).clearFilters();
                }
                
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
            if (_itemStatusFilter != null)
              TextButton(
                onPressed: () {
                  // Clear filters
                  setState(() {
                    _itemStatusFilter = null;
                  });
                  
                  // Clear filters in provider
                  ref.read(itemListProvider.notifier).clearFilters();
                  
                  Navigator.of(context).pop();
                },
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      ),
    );
  }
  
  // Helper methods for formatting status values
  String _formatStatus(String status) {
    return StringFormatter.snakeCaseToTitleCase(status);
  }
  
  String _formatItemStatus(String status) {
    switch (status) {
      case 'in_stock':
        return 'In Stock';
      case 'listed':
        return 'Listed';
      case 'sold':
        return 'Sold';
      default:
        return status.split('_').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ');
    }
  }

  // Helper to convert string status to ItemStatus enum
  ItemStatus? _stringToItemStatus(String? status) {
    if (status == null) return null;
    
    switch (status.toLowerCase()) {
      case 'in_stock':
        return ItemStatus.inStock;
      case 'for_sale':
        return ItemStatus.forSale;
      case 'listed':
        return ItemStatus.listed;
      case 'sold':
        return ItemStatus.sold;
      default:
        return null;
    }
  }

  void _showAddItemToPalletDialog(BuildContext context) {
    final itemListNotifier = ref.read(itemListProvider.notifier);
    final palletListState = ref.watch(palletListProvider);
  
    palletListState.whenOrNull(
      data: (pallets) {
        if (pallets.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Pallets Available'),
              content: const Text(
                'You need to create a pallet before adding items. '
                'Create a pallet first?',
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(
                      RouterNotifier.addEditPallet,
                    ).then((created) {
                      if (created == true) {
                        // Refresh pallets list
                        ref.read(palletListProvider.notifier).refreshPallets();
                      }
                    });
                  },
                  child: const Text('Create Pallet'),
                ),
              ],
            ),
          );
          return;
        }
      
        // Filter only in-progress pallets
        final activePallets = pallets.where((p) => p.status == PalletStatus.inProgress).toList();
      
        if (activePallets.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Active Pallets'),
              content: const Text(
                'You can only add items to pallets that are not yet processed. '
                'Create a new pallet?',
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(
                      RouterNotifier.addEditPallet,
                    ).then((created) {
                      if (created == true) {
                        // Refresh pallets list
                        ref.read(palletListProvider.notifier).refreshPallets();
                      }
                    });
                  },
                  child: const Text('Create Pallet'),
                ),
              ],
            ),
          );
          return;
        }
      
        // Show pallet selection dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Pallet'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: math.min(activePallets.length, 10), // Fix Math to math
                itemBuilder: (context, index) {
                  final pallet = activePallets[index];
                  return ListTile(
                    title: Text(pallet.name),
                    subtitle: Text('Tap to add item'), // Replace itemCount reference
                    onTap: () {
                      context.pop();
                      context.pushNamed(
                        RouterNotifier.addEditItemStandalone,
                        queryParameters: {'palletId': pallet.id}
                      ).then((added) {
                        if (added == true) {
                          // Refresh both providers
                          itemListNotifier.refreshItems();
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
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
    
    // Show active filter indicator based on the current tab
    final bool hasActiveFilter = _tabController.index == 0 
        ? _palletStatusFilter != null
        : _itemStatusFilter != null;
    
    print('Building InventoryListScreen, debugging providers...');
    
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
        ],
      ),
      // Add the Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            // Add new pallet - replace MaterialPageRoute with GoRouter
            context.pushNamed(
              RouterNotifier.addEditPallet,
            ).then((result) {
              if (result == true) {
                // Refresh the pallet list
                ref.read(palletListProvider.notifier).refreshPallets();
              }
            });
          } else {
            // Show dialog to select a pallet for the new item
            _showAddItemToPalletDialog(context);
          }
        },
        child: Icon(_tabController.index == 0 ? Icons.add : Icons.inventory_2),
      ),
      body: Column(
        children: [
          // Custom Tab Bar with filter indicators
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(
                text: 'Pallets',
                icon: Badge(
                  isLabelVisible: _palletStatusFilter != null,
                  child: const Icon(Icons.view_comfy),
                ),
              ),
              Tab(
                text: 'Items',
                icon: Badge(
                  isLabelVisible: _itemStatusFilter != null,
                  child: const Icon(Icons.inventory),
                ),
              ),
            ],
          ),
          
          // Filter chips that appear when a filter is active
          if (hasActiveFilter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Text('Filters: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  if (_tabController.index == 0 && _palletStatusFilter != null)
                    Chip(
                      label: Text(_palletStatusFilter!),
                      onDeleted: () {
                        setState(() {
                          _palletStatusFilter = null;
                        });
                      },
                    ),
                  if (_tabController.index == 1 && _itemStatusFilter != null)
                    Chip(
                      label: Text(_itemStatusFilter!),
                      onDeleted: () {
                        setState(() {
                          _itemStatusFilter = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pallets Tab
                _PalletsTab(
                  statusFilter: _palletStatusFilter,
                  searchQuery: _searchQuery,
                  onAddPressed: _showAddItemToPalletDialog,
                ),
                
                // Items Tab - Pass the necessary filters
                _ItemsTab(
                  searchQuery: _searchQuery,
                  statusFilter: _itemStatusFilter,
                  isTablet: MediaQuery.of(context).size.width >= 768,
                  onReload: () => ref.invalidate(itemListProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_progress':
        return Colors.blue;
      case 'processed':
        return Colors.green;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _PalletsTab extends ConsumerWidget {
  final String? statusFilter;
  final String searchQuery;
  final Function onAddPressed;
  
  const _PalletsTab({
    required this.statusFilter,
    required this.searchQuery,
    required this.onAddPressed,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the pallet provider with proper filtering
    final palletsAsync = ref.watch(palletListProvider);
    
    // Determine if we're on a tablet based on screen width
    final isTablet = MediaQuery.of(context).size.width >= 768;
    
    return palletsAsync.when(
      loading: () => const ShimmerLoader(),
      error: (error, stack) => Center(
        child: Text('Error loading pallets: $error'),
      ),
      data: (pallets) {
        // Apply status filter and search query
        final filteredPallets = pallets.where((pallet) {
          // Status filter check
          final matchesStatus = statusFilter == null || 
            pallet.status.toString().split('.').last == statusFilter;
          
          // Search query check
          final matchesSearch = searchQuery.isEmpty || 
            pallet.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (pallet.supplier ?? '').toLowerCase().contains(searchQuery.toLowerCase());
          
          return matchesStatus && matchesSearch;
        }).toList();
        
        // Show empty pallets view if no pallets found
        if (filteredPallets.isEmpty) {
          return buildEmptyPalletsView(context, ref);
        }
        
        // Determine grid columns based on screen size
        final int columns = isTablet ? 3 : 2;

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh the pallets list
            ref.read(palletListProvider.notifier).refreshPallets();
          },
          child: Container(
            // Ensure the container has a defined height constraint
            constraints: const BoxConstraints.expand(),
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: isTablet ? 1.2 : 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredPallets.length,
              itemBuilder: (context, index) {
                final pallet = filteredPallets[index];
                final statusString = pallet.status.toString().split('.').last;
                return PalletCard(
                  id: pallet.id,
                  name: pallet.name,
                  supplier: pallet.supplier,
                  source: pallet.source,
                  cost: pallet.cost,
                  status: statusString,
                  onTap: () {
                    // Navigate to pallet detail
                    context.goNamed(
                      RouterNotifier.palletDetail,
                      pathParameters: {'pid': pallet.id},
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget buildEmptyPalletsView(BuildContext context, WidgetRef ref) {
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
              // Navigate to the AddEditPalletScreen using GoRouter
              context.pushNamed(
                RouterNotifier.addEditPallet,
              ).then((created) {
                if (created == true) {
                  // Refresh pallets when returning with success
                  ref.read(palletListProvider.notifier).refreshPallets();
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class _ItemsTab extends ConsumerWidget {
  const _ItemsTab({
    required this.searchQuery,
    required this.statusFilter,
    required this.isTablet,
    required this.onReload,
    Key? key,
  }) : super(key: key);

  final String searchQuery;
  final String? statusFilter;
  final bool isTablet;
  final VoidCallback onReload;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('Building _ItemsTab with searchQuery: $searchQuery, statusFilter: $statusFilter');
    
    // Add state provider for view mode
    final viewMode = ref.watch(itemViewModeProvider);
    
    // Use the AsyncValue wrapper to get proper loading/error states
    final itemsAsync = ref.watch(itemListProvider);
    
    // DON'T force refresh here - it causes infinite rebuilds
    // The refresh is already happening in didChangeDependencies of InventoryListScreen

    return itemsAsync.when(
      loading: () => const Center(
        child: SizedBox(
          height: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading inventory items...'),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) {
        print('Error in _ItemsTab: $error');
        return ErrorDisplay(
          message: 'Failed to load items',
          details: error.toString(),
          onRetry: onReload,
        );
      },
      data: (items) {
        // Apply filters based on the search query and status filter
        final filteredItems = items.where((item) {
          // Search query filter
          final matchesSearch = searchQuery.isEmpty || 
            (item.name?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (item.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
          
          // Status filter
          final matchesStatus = statusFilter == null || 
            item.status.toString().split('.').last == statusFilter;
          
          return matchesSearch && matchesStatus;
        }).toList();
        
        // Show a message when no items match the filters
        if (filteredItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Add this to fix layout issues
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No items found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (searchQuery.isNotEmpty || statusFilter != null)
                  ElevatedButton(
                    onPressed: onReload,
                    child: const Text('Clear filters'),
                  ),
              ],
            ),
          );
        }
        
        // Stack with RefreshIndicator and FloatingActionButton for view toggle
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                // Refresh data
                ref.read(itemListProvider.notifier).refreshItems();
              },
              child: Container(
                constraints: const BoxConstraints.expand(),
                child: viewMode == ItemViewMode.grid 
                    ? _buildGridView(context, filteredItems, isTablet)
                    : _buildListView(context, filteredItems),
              ),
            ),
            // FAB for toggling view mode
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'viewToggleFab',
                mini: true,
                onPressed: () {
                  ref.read(itemViewModeProvider.notifier).toggleViewMode();
                },
                child: Icon(
                  viewMode == ItemViewMode.grid ? Icons.view_list : Icons.grid_view,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildGridView(BuildContext context, List<Item> items, bool isTablet) {
    // Determine grid columns based on screen size and platform
    final width = MediaQuery.of(context).size.width;
    int columns;
    
    // More responsive column count based on available width
    if (width > 1200) {
      columns = 4; // Large desktop
    } else if (width > 900) {
      columns = 3; // Desktop/tablet landscape
    } else if (width > 600) {
      columns = 2; // Tablet portrait
    } else {
      columns = 2; // Phone
    }
    
    // Calculate the aspect ratio based on platform and size
    final double aspectRatio = isTablet ? 0.85 : 0.8;
    
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InventoryItemCard(
          id: item.id,
          name: item.name ?? 'Unnamed Item',
          description: item.description,
          purchasePrice: item.purchasePrice,
          quantity: item.quantity,
          condition: item.condition.toString().split('.').last,
          status: item.status.toString().split('.').last,
          imageUrl: null,
          onTap: () {
            // Navigate to item detail
            context.goNamed(
              RouterNotifier.itemDetail,
              pathParameters: {'iid': item.id},
            );
          },
        );
      },
    );
  }
  
  Widget _buildListView(BuildContext context, List<Item> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        
        // Get status color for styling
        final Color statusColor = StatusColors.forItemStatus(
          item.status.toString().split('.').last
        );
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: statusColor.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2, 
                color: statusColor,
                size: 24,
              ),
            ),
            title: Text(
              item.name ?? 'Unnamed Item',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description != null && item.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      item.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        _getConditionIcon(item.condition.toString().split('.').last),
                        size: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatCondition(item.condition.toString().split('.').last)} • Qty: ${item.quantity}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status: item.status.toString().split('.').last),
                if (item.purchasePrice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '\$${item.purchasePrice!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              context.goNamed(
                RouterNotifier.itemDetail,
                pathParameters: {'iid': item.id},
              );
            },
          ),
        );
      },
    );
  }
  
  // Helper method to get condition icon
  IconData _getConditionIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
      case 'newitem':
      case 'new item':
        return Icons.star;
      case 'usedgood':
      case 'used_good':
      case 'used - good':
        return Icons.thumb_up_outlined;
      case 'usedfair':
      case 'used_fair':
      case 'used - fair':
        return Icons.thumbs_up_down;
      case 'usedpoor':
      case 'used_poor':
      case 'used - poor':
        return Icons.thumb_down_outlined;
      case 'damaged':
        return Icons.broken_image;
      case 'for parts':
      case 'forparts':
        return Icons.build;
      case 'open box':
      case 'openbox':
        return Icons.inventory;
      default:
        return Icons.label_outline;
    }
  }
  
  // Helper method to format condition text for display
  String _formatCondition(String rawCondition) {
    switch (rawCondition.toLowerCase()) {
      case 'newitem':
        return 'New Item';
      case 'openbox':
        return 'Open Box';
      case 'usedgood':
        return 'Used - Good';
      case 'usedfair':
        return 'Used - Fair';
      case 'usedpoor':
        return 'Used - Poor';
      case 'forparts':
        return 'For Parts';
      default:
        return rawCondition;
    }
  }
}

// View mode provider
enum ItemViewMode { grid, list }

final itemViewModeProvider = StateNotifierProvider<ItemViewModeNotifier, ItemViewMode>((ref) {
  return ItemViewModeNotifier();
});

class ItemViewModeNotifier extends StateNotifier<ItemViewMode> {
  ItemViewModeNotifier() : super(ItemViewMode.grid);
  
  void toggleViewMode() {
    state = state == ItemViewMode.grid ? ItemViewMode.list : ItemViewMode.grid;
  }
}

class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.details,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use min to prevent flex issues
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (details != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  details!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            if (onRetry != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 