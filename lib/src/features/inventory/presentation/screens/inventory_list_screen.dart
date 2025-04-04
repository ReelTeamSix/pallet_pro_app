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
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/add_edit_item_screen.dart';
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

// Extension to provide a way to access the notifier from screens
// Renamed to avoid conflicts
extension SimpleItemListProviderScreenExtension on FutureProvider<List<SimpleItem>> {
  // Helper to get a reference to the actual StateNotifierProvider
  StateNotifierProvider<SimpleItemListNotifier, List<SimpleItem>> get screenNotifierProvider {
    return simpleItemListNotifierProvider;
  }
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
                
                // Apply filter using Provider
                ref.read(simpleItemListProvider.screenNotifierProvider.notifier).setFilters(
                  statusFilter: selectedStatus,
                );
                
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
                  ref.read(simpleItemListProvider.screenNotifierProvider.notifier).clearFilters();
                  
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
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'processed':
        return 'Processed';
      case 'archived':
        return 'Archived';
      default:
        return status.split('_').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ');
    }
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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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
          _PalletsTab(searchQuery: _searchQuery, statusFilter: _palletStatusFilter),
          _ItemsTab(searchQuery: _searchQuery, statusFilter: _itemStatusFilter),
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
            // For Items tab (index 1), we need to show a dialog to select which pallet to add items to
            // Get the list of pallets
            final palletsAsync = ref.read(palletListProvider);
            
            if (palletsAsync is AsyncData && palletsAsync.value?.isNotEmpty == true) {
              // Show dialog to select a pallet
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Pallet'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        // Option to add an item without a pallet
                        ListTile(
                          leading: const Icon(Icons.add_circle_outline),
                          title: const Text('No Pallet / Direct Source'),
                          subtitle: const Text('Add an item not from a pallet'),
                          onTap: () {
                            Navigator.of(context).pop(); // Close the dialog
                            
                            // Navigate to AddEditItemScreen without a pallet ID
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AddEditItemScreen(),
                              ),
                            ).then((result) {
                              if (result == true) {
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Item added successfully!'))
                                );
                                
                                // Refresh items
                                ref.invalidate(simpleItemListProvider);
                              }
                            });
                          },
                        ),
                        
                        const Divider(),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Or select a pallet:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        
                        // List of pallets
                        ...List.generate(
                          palletsAsync.value?.length ?? 0,
                          (index) {
                            final pallet = palletsAsync.value?[index];
                            return ListTile(
                              title: Text(pallet?.name ?? ''),
                              subtitle: Text(pallet?.supplier ?? 'Unknown Supplier'),
                              onTap: () {
                                Navigator.of(context).pop(); // Close the dialog
                                
                                if (pallet?.id != null) {
                                  // Navigate to AddEditItemScreen with the selected pallet ID
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddEditItemScreen(
                                        palletId: pallet!.id,
                                      ),
                                    ),
                                  ).then((result) {
                                    if (result == true) {
                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Item added successfully!'))
                                      );
                                      
                                      // Refresh items
                                      ref.invalidate(simpleItemListProvider);
                                    }
                                  });
                                } else {
                                  // Show error if palletId is null
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Error: Invalid pallet selected'))
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            } else if (palletsAsync is AsyncData && palletsAsync.value?.isEmpty == true) {
              // No pallets exist yet, but allow adding an item without a pallet
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add Item'),
                  content: const Text('You don\'t have any pallets yet. Would you like to add a pallet first, or add an item directly?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _tabController.animateTo(0); // Switch to Pallets tab
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Switched to Pallets tab to add a pallet'))
                        );
                      },
                      child: const Text('Add Pallet First'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        
                        // Navigate to AddEditItemScreen without a pallet ID
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddEditItemScreen(),
                          ),
                        ).then((result) {
                          if (result == true) {
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Item added successfully!'))
                            );
                            
                            // Refresh items
                            ref.invalidate(simpleItemListProvider);
                          }
                        });
                      },
                      child: const Text('Add Item Directly'),
                    ),
                  ],
                ),
              );
            } else {
              // Loading or error state
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unable to load pallets. Please try again.'))
              );
            }
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Add Pallet' : 'Add Item'),
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
            return pallet.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
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
                            ref.refresh(palletListProvider);
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
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'processed':
        return 'Processed';
      case 'archived':
        return 'Archived';
      default:
        return status.split('_').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ');
    }
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
                  Row(
                    children: [
                      Icon(Icons.inventory_2, 
                        color: _getStatusColor(_palletStatusToString(pallet.status)),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(pallet.name, 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
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
  final String? statusFilter;

  const _ItemsTab({
    this.searchQuery = '',
    this.statusFilter,
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
        // Filter items based on search query and status filter
        final filteredItems = items.where((item) {
          // Apply status filter if set
          if (statusFilter != null && item.status != statusFilter) {
            return false;
          }
          
          // Apply search filter if set
          if (searchQuery.isNotEmpty) {
            return (item.name?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
              (item.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
              (item.condition.toLowerCase().contains(searchQuery.toLowerCase()));
          }
          
          return true;
        }).toList();
              
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(simpleItemListProvider);
          },
          child: filteredItems.isEmpty
            ? searchQuery.isNotEmpty || statusFilter != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No matching items',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusFilter != null
                            ? 'No items with status "${_formatItemStatus(statusFilter!)}"'
                            : 'No items match "$searchQuery"',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (statusFilter != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Filter'),
                          onPressed: () {
                            ref.read(simpleItemListProvider.screenNotifierProvider.notifier).clearFilters();
                            // We need to update the UI state in the parent widget
                            // This is a limitation of using a ConsumerWidget instead of ConsumerStatefulWidget
                            // In a real app, we might use a different approach
                            // For now, let's just refresh the page
                            ref.refresh(simpleItemListProvider);
                          },
                        ),
                    ],
                  ),
                )
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
  
  // Helper method to format status for display
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
  
  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_stock':
        return Colors.blue;
      case 'listed':
        return Colors.orange;
      case 'sold':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  // Helper method to get status icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'in_stock':
        return Icons.inventory;
      case 'listed':
        return Icons.storefront;
      case 'sold':
        return Icons.paid;
      default:
        return Icons.inventory;
    }
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
            'Add your first item to begin tracking inventory',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
            onPressed: () {
              // Get reference to the riverpod container
              final container = ProviderScope.containerOf(context);
              
              // Check if pallets exist
              final palletsAsync = container.read(palletListProvider);
              
              if (palletsAsync is AsyncData && palletsAsync.value?.isNotEmpty == true) {
                // Show dialog to select a pallet or add without a pallet
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Pallet'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          // Option to add an item without a pallet
                          ListTile(
                            leading: const Icon(Icons.add_circle_outline),
                            title: const Text('No Pallet / Direct Source'),
                            subtitle: const Text('Add an item not from a pallet'),
                            onTap: () {
                              Navigator.of(context).pop(); // Close the dialog
                              
                              // Navigate to AddEditItemScreen without a pallet ID
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AddEditItemScreen(),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Item added successfully!'))
                                  );
                                  
                                  // Refresh items
                                  container.refresh(simpleItemListProvider);
                                }
                              });
                            },
                          ),
                          
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text('Or select a pallet:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          
                          // List of pallets
                          ...List.generate(
                            palletsAsync.value?.length ?? 0,
                            (index) {
                              final pallet = palletsAsync.value?[index];
                              return ListTile(
                                title: Text(pallet?.name ?? ''),
                                subtitle: Text(pallet?.supplier ?? 'Unknown Supplier'),
                                onTap: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                  
                                  if (pallet?.id != null) {
                                    // Navigate to AddEditItemScreen with the selected pallet ID
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddEditItemScreen(
                                          palletId: pallet!.id,
                                        ),
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        // Show success message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Item added successfully!'))
                                        );
                                        
                                        // Refresh items
                                        container.refresh(simpleItemListProvider);
                                      }
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              } else {
                // No pallets exist yet, but allow adding an item without a pallet
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Item'),
                    content: const Text('You don\'t have any pallets yet. Would you like to add a pallet first, or add an item directly?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Switch to pallets tab
                          (context.findAncestorStateOfType<_InventoryListScreenState>())?._tabController.animateTo(0);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Switched to Pallets tab to add a pallet'))
                          );
                        },
                        child: const Text('Add Pallet First'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          
                          // Navigate to AddEditItemScreen without a pallet ID
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddEditItemScreen(),
                            ),
                          ).then((result) {
                            if (result == true) {
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Item added successfully!'))
                              );
                              
                              // Refresh items
                              container.refresh(simpleItemListProvider);
                            }
                          });
                        },
                        child: const Text('Add Item Directly'),
                      ),
                    ],
                  ),
                );
              }
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
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(item.status).withOpacity(0.2),
              child: Icon(_getStatusIcon(item.status), color: _getStatusColor(item.status)),
            ),
            title: Row(
              children: [
                Expanded(child: Text(item.name ?? 'Unnamed Item')),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(item.status).withOpacity(0.5)),
                  ),
                  child: Text(
                    _formatItemStatus(item.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(item.status),
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Condition: ${item.condition}\nQty: ${item.quantity}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text('\$${item.purchasePrice?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    backgroundColor: _getStatusColor(item.status).withOpacity(0.2),
                    child: Icon(_getStatusIcon(item.status), color: _getStatusColor(item.status)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(item.name ?? 'Unnamed Item', 
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getStatusColor(item.status).withOpacity(0.5)),
                              ),
                              child: Text(
                                _formatItemStatus(item.status),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getStatusColor(item.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Condition: ${item.condition}',
                             style: const TextStyle(fontSize: 12),
                             overflow: TextOverflow.ellipsis),
                        Text('Qty: ${item.quantity}',
                             style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('\$${item.purchasePrice?.toStringAsFixed(2) ?? '0.00'}',
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