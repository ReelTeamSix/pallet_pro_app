import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart'; // Placeholder, add shimmer dependency if not present
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:pallet_pro_app/src/routing/app_router.dart'; // Import route names
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/core/utils/responsive_utils.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';
import 'package:pallet_pro_app/src/global/widgets/inventory_item_card.dart';
import 'package:pallet_pro_app/src/global/widgets/pallet_card.dart';
import 'package:pallet_pro_app/src/core/utils/string_formatter.dart';

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
    ref.read(itemListProvider.notifier).refreshItems();
    ref.read(palletListProvider.notifier).refreshPallets();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
                    label: Text(_formatPalletStatus(status)),
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
              onPressed: () => Navigator.of(context).pop(),
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
                
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
            if (_palletStatusFilter != null)
              TextButton(
                onPressed: () {
                  // Clear filters
                  setState(() {
                    _palletStatusFilter = null;
                  });
                  
                  // Clear filters in provider
                  ref.read(palletListProvider.notifier).clearFilters();
                  
                  Navigator.of(context).pop();
                },
                child: const Text('Clear Filters'),
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
                    label: Text(_formatItemStatus(status)),
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
  String _formatPalletStatus(String status) {
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
    // Get pallets for the dropdown
    final palletsAsync = ref.read(palletListProvider);
    
    palletsAsync.when(
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading pallets...'))
        );
      },
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pallets: $error'))
        );
      },
      data: (pallets) {
        if (pallets.isEmpty) {
          // No pallets, show message to create one first
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Pallets Available'),
              content: const Text('You need to create a pallet before adding items.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditPalletScreen(),
                      ),
                    ).then((result) {
                      if (result == true) {
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
        
        // Have pallets, show the selection dialog
        Pallet? selectedPallet = pallets.first;
        
        showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('Select Pallet for New Item'),
              content: DropdownButtonFormField<Pallet>(
                value: selectedPallet,
                items: pallets.map((pallet) => DropdownMenuItem<Pallet>(
                  value: pallet,
                  child: Text(pallet.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPallet = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (selectedPallet != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddEditItemScreen(palletId: selectedPallet!.id),
                        ),
                      ).then((result) {
                        if (result == true) {
                          ref.read(itemListProvider.notifier).refreshItems();
                        }
                      });
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
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
            // Add new pallet
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddEditPalletScreen(),
              ),
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
                _PalletsTab(),
                
                // Items Tab - Pass the necessary filters
                _ItemsTab(
                  searchQuery: _searchQuery,
                  statusFilter: _itemStatusFilter,
                  isTablet: MediaQuery.of(context).size.width >= 768,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to convert PalletStatus enum to string
  String _palletStatusToString(String status) {
    // Since we're using SimplePallet for testing, status is already a string
    return status;
  }
}

class _PalletsTab extends ConsumerWidget {
  final String searchQuery;
  final String? statusFilter;

  const _PalletsTab({
    this.searchQuery = '',
    this.statusFilter,
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
        // Filter pallets based on search query and status filter
        final filteredPallets = pallets.where((pallet) {
          // Apply status filter if set
          if (statusFilter != null && pallet.status != statusFilter) {
            return false;
          }
          
          // Apply search filter if set
          if (searchQuery.isNotEmpty) {
            return (pallet.name.toLowerCase().contains(searchQuery.toLowerCase())) ||
              (pallet.supplier?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
              (pallet.source?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
          }
          
          return true;
        }).toList();
        
        return RefreshIndicator(
          onRefresh: () async {
            // Use the notifier's refresh method
            ref.read(palletListProvider.notifier).refreshPallets();
          },
          child: filteredPallets.isEmpty
            ? searchQuery.isNotEmpty || statusFilter != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No matching pallets',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusFilter != null
                            ? 'No pallets with status "${_formatPalletStatus(statusFilter!)}"'
                            : 'No pallets match "$searchQuery"',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (statusFilter != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Filter'),
                          onPressed: () {
                            ref.read(palletListProvider.notifier).clearFilters();
                            // We need to update the UI state in the parent widget
                            // This is a limitation of using a ConsumerWidget instead of ConsumerStatefulWidget
                            // In a real app, we might use a different approach
                            // For now, let's just refresh the page
                            ref.invalidate(palletListProvider);
                          },
                        ),
                    ],
                  ),
                )
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
  
  // Helper method to format pallet status for display
  String _formatPalletStatus(String status) {
    return StringFormatter.snakeCaseToTitleCase(status);
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
  
  // Convert Pallet.status to a string
  String _palletStatusToString(PalletStatus status) {
    switch (status) {
      case PalletStatus.inProgress:
        return 'in_progress';
      case PalletStatus.processed:
        return 'processed';
      case PalletStatus.archived:
        return 'archived';
    }
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
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(_palletStatusToString(pallet.status)).withOpacity(0.2),
              child: Icon(Icons.inventory_2, color: _getStatusColor(_palletStatusToString(pallet.status))),
            ),
            title: Row(
              children: [
                Expanded(child: Text(pallet.name)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_palletStatusToString(pallet.status)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(_palletStatusToString(pallet.status)).withOpacity(0.5)),
                  ),
                  child: Text(
                    _formatPalletStatus(_palletStatusToString(pallet.status)),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(_palletStatusToString(pallet.status)),
                    ),
                  ),
                ),
              ],
            ),
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
        return PalletCard(
          id: pallet.id,
          name: pallet.name,
          supplier: pallet.supplier,
          source: pallet.source,
          cost: pallet.cost,
          status: _palletStatusToString(pallet.status),
          onTap: () {
            context.goNamed(
              RouterNotifier.palletDetail,
              pathParameters: {'pid': pallet.id}
            );
          },
        );
      },
    );
  }
}

class _ItemsTab extends ConsumerWidget {
  const _ItemsTab({
    required this.searchQuery,
    required this.statusFilter,
    required this.isTablet,
    Key? key,
  }) : super(key: key);

  final String searchQuery;
  final String? statusFilter;
  final bool isTablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('Building _ItemsTab with searchQuery: $searchQuery, statusFilter: $statusFilter');
    
    // Use the AsyncValue wrapper to get proper loading/error states
    final itemsAsync = ref.watch(itemListProvider);
    
    return itemsAsync.when(
      loading: () => const ShimmerLoader(itemCount: 10),
      error: (error, stackTrace) {
        print('Error in _ItemsTab: $error');
        print(stackTrace);
        return ErrorDisplay(
          message: 'Failed to load items',
          details: error.toString(),
          onRetry: () {
            ref.read(itemListProvider.notifier).refreshItems();
          }
        );
      },
      data: (items) {
        // Convert the full items to SimpleItems for display
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
        
        print('Converted ${simpleItems.length} items for display');
        
        // Filter items based on search query and status filter
        final filteredItems = simpleItems.where((item) {
          // Apply search filter if present
          final matchesSearch = searchQuery.isEmpty ||
              (item.name?.toLowerCase() ?? '').contains(searchQuery.toLowerCase()) ||
              (item.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
              
          // Apply status filter if present
          final matchesStatus = statusFilter == null || 
              (item.status.toLowerCase() == statusFilter!.toLowerCase());
              
          return matchesSearch && matchesStatus;
        }).toList();
        
        print('Filtered to ${filteredItems.length} items after applying filters');
        
        if (filteredItems.isEmpty) {
          // Show an empty state with filter clearing option if needed
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  items.isEmpty
                    ? 'No items in inventory yet'
                    : 'No items match your filters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (searchQuery.isNotEmpty || statusFilter != null)
                  const SizedBox(height: 16),
                if (searchQuery.isNotEmpty || statusFilter != null)
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement clear filters functionality
                      // This would typically call a method in the parent widget
                    },
                    child: const Text('Clear filters'),
                  ),
              ],
            ),
          );
        }
        
        // Determine grid columns based on screen size
        final int columns = isTablet ? 3 : 2;
        
        return RefreshIndicator(
          onRefresh: () async {
            // Refresh data without invalidating providers
            await ref.read(itemListProvider.notifier).refreshItems();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MasonryGridView.count(
              crossAxisCount: columns,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return InventoryItemCard(
                  id: item.id,
                  name: item.name ?? 'Unnamed Item',
                  description: item.description,
                  purchasePrice: item.purchasePrice,
                  quantity: item.quantity,
                  condition: item.condition,
                  status: item.status,
                  onTap: () => _navigateToItemDetails(context, item.id),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _navigateToItemDetails(BuildContext context, String itemId) {
    context.goNamed(
      RouterNotifier.itemDetail,
      pathParameters: {'iid': itemId},
    );
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