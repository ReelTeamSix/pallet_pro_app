import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_list_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/add_edit_item_screen.dart';
import 'package:pallet_pro_app/src/global/utils/dialog_service.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';
import '../providers/pallet_detail_provider.dart';
import 'inventory_list_screen.dart'; // For ShimmerLoader access
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart'; // Import SimplePallet class

class PalletDetailScreen extends ConsumerWidget {
  final String palletId;

  const PalletDetailScreen({required this.palletId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the real provider for pallet data
    final palletAsync = ref.watch(palletDetailProvider(palletId));
    
    // Use the real provider for item data with proper AsyncValue handling
    final itemsAsync = ref.watch(itemListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pallet Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh all relevant providers
              ref.invalidate(palletDetailProvider(palletId));
              ref.invalidate(itemListProvider);
              
              // Show a snackbar to confirm refresh
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing data...'), duration: Duration(seconds: 1))
              );
            },
          ),
          palletAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(), 
            data: (pallet) {
              if (pallet == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Pallet',
                onPressed: () {
                  // In a future phase, navigate to edit pallet screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Pallet feature coming in Phase 5.5'))
                  );
                },
              );
            },
          ),
        ],
      ),
      body: palletAsync.when(
        loading: () => const ShimmerLoader(),
        error: (err, stack) => Center(
          child: Text('Error loading pallet: $err'),
        ),
        data: (pallet) {
          if (pallet == null) {
            return const Center(child: Text('Pallet not found.'));
          }
          
          // Now handle the items AsyncValue inside the pallet data callback
          return itemsAsync.when(
            loading: () => const ShimmerLoader(),
            error: (err, stack) => Center(
              child: Text('Error loading items: $err'),
            ),
            data: (items) {
              // Filter items by palletId
              final filteredItems = items
                  .where((item) => item.palletId == palletId)
                  .toList();
              
              // Display pallet details with filtered items
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Action Card
                    _buildStatusActionCard(context, ref, pallet, filteredItems.length),
                    
                    // Basic Information Card
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Basic Information', 
                                style: Theme.of(context).textTheme.titleLarge),
                            const Divider(),
                            const SizedBox(height: 8),
                            ListTile(
                              leading: const Icon(Icons.business),
                              title: const Text('Supplier'),
                              subtitle: Text(pallet.supplier ?? 'Not specified'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.store),
                              title: const Text('Source'),
                              subtitle: Text(pallet.source ?? 'Not specified'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.category),
                              title: const Text('Type'),
                              subtitle: Text(pallet.type ?? 'Not specified'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: const Text('Purchase Date'),
                              subtitle: Text(pallet.purchaseDate?.toString().split(' ')[0] ?? 'Not specified'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.attach_money),
                              title: const Text('Cost'),
                              subtitle: Text('\$${pallet.cost.toStringAsFixed(2)}'),
                            ),
                            // Status Information
                            ListTile(
                              leading: Icon(
                                Icons.circle,
                                color: _getStatusColor(_palletStatusToString(pallet.status)),
                                size: 16,
                              ),
                              title: const Text('Status'),
                              subtitle: Text(_formatStatus(_palletStatusToString(pallet.status))),
                            ),
                            if (pallet.status == PalletStatus.processed)
                              ListTile(
                                leading: const Icon(Icons.event_available),
                                title: const Text('Processing Date'),
                                subtitle: Text('Not specified'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Items section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Items', style: Theme.of(context).textTheme.titleLarge),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: pallet.status == PalletStatus.processed 
                                    ? null  // Disable if pallet is processed
                                    : () {
                                        // Navigate to add item screen using GoRouter
                                        context.pushNamed(
                                          RouterNotifier.addItemToPallet,
                                          pathParameters: {'pid': pallet.id},
                                        ).then((added) {
                                          if (added == true) {
                                            // Refresh the screen and all item providers
                                            ref.invalidate(palletDetailProvider(pallet.id));
                                            ref.invalidate(itemListProvider);
                                            
                                            // Show success message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Item added successfully'))
                                            );
                                          }
                                        });
                                      },
                                  tooltip: pallet.status == PalletStatus.processed
                                    ? 'Cannot add items to a processed pallet'
                                    : 'Add Item',
                                ),
                              ],
                            ),
                            const Divider(),
                            if (filteredItems.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text('No items added to this pallet yet.'),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return ListTile(
                                    leading: const Icon(Icons.inventory),
                                    title: Text(item.name ?? 'Unnamed Item'),
                                    subtitle: Text(
                                      'Qty: ${item.quantity} • ${item.condition}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (item.status == 'listed')
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Icon(Icons.storefront, 
                                              color: Colors.orange, 
                                              size: 16,
                                            ),
                                          ),
                                        if (item.status == 'sold')
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Icon(Icons.paid, 
                                              color: Colors.green, 
                                              size: 16,
                                            ),
                                          ),
                                        Text(
                                          item.purchasePrice != null 
                                              ? '\$${item.purchasePrice!.toStringAsFixed(2)}'
                                              : '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      // Navigate to item detail
                                      context.goNamed(
                                        RouterNotifier.itemDetail,
                                        pathParameters: {'iid': item.id},
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Costs and Analytics
                    if (pallet.status == PalletStatus.processed)
                      Card(
                        margin: const EdgeInsets.only(top: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Costs and Analytics', 
                                  style: Theme.of(context).textTheme.titleLarge),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.payments),
                                title: const Text('Total Pallet Cost'),
                                subtitle: Text('\$${pallet.cost.toStringAsFixed(2)}'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.inventory_2),
                                title: const Text('Item Count'),
                                subtitle: Text('${filteredItems.length} items'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.calculate),
                                title: const Text('Cost Allocation Method'),
                                subtitle: Text('Even Distribution'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.price_change),
                                title: const Text('Average Cost Per Item'),
                                subtitle: Text(filteredItems.isNotEmpty 
                                  ? '\$${(pallet.cost / filteredItems.length).toStringAsFixed(2)}'
                                  : 'N/A'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Footer with ID for debugging
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text('Pallet ID: ${pallet.id}', 
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusActionCard(BuildContext context, WidgetRef ref, dynamic pallet, int itemCount) {
    final statusColor = _getStatusColor(_palletStatusToString(pallet.status));
    // Use the real notifier provider instead of mock
    final notifier = ref.read(palletDetailNotifierProvider(pallet.id).notifier);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Status: ${_formatStatus(_palletStatusToString(pallet.status))}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status update buttons - show different buttons based on current status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (pallet.status == PalletStatus.inProgress) ...[
                  if (itemCount > 0) 
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Process Pallet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        // Get allocation method (hardcoded for now, but should come from settings)
                        const allocationMethod = 'even'; // Default to even distribution
                        
                        final confirmed = await DialogService.showProcessPalletConfirmation(
                          context: context,
                          palletName: pallet.name ?? 'Pallet',
                          itemCount: itemCount,
                          palletCost: pallet.cost,
                          allocationMethod: allocationMethod,
                        );
                        
                        if (confirmed) {
                          await notifier.markAsProcessed();
                          
                          // Give UI feedback
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pallet processed successfully! Costs have been allocated to items.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add Items'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Navigate to add item screen using GoRouter
                        context.pushNamed(
                          RouterNotifier.addItemToPallet,
                          pathParameters: {'pid': pallet.id},
                        ).then((added) {
                          if (added == true) {
                            // Refresh the screen and all item providers
                            ref.invalidate(palletDetailProvider(pallet.id));
                            ref.invalidate(itemListProvider);
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Item added successfully'))
                            );
                          }
                        });
                      },
                    ),
                ],
                
                if (pallet.status == PalletStatus.processed)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.archive),
                    label: const Text('Archive Pallet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final confirmed = await DialogService.showConfirmationDialog(
                        context: context,
                        title: 'Archive Pallet',
                        message: 'Are you sure you want to archive this pallet? '
                          'This is typically done when all items have been sold or disposed of.',
                        confirmText: 'Archive',
                        cancelText: 'Cancel',
                      );
                      
                      if (confirmed) {
                        await notifier.markAsArchived();
                      }
                    },
                  ),
                  
                if (pallet.status == PalletStatus.archived)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore Pallet'),
                    onPressed: () async {
                      final confirmed = await DialogService.showConfirmationDialog(
                        context: context,
                        title: 'Restore Pallet',
                        message: 'Are you sure you want to restore this pallet from the archive '
                          'and mark it as processed?',
                        confirmText: 'Restore',
                        cancelText: 'Cancel',
                      );
                      
                      if (confirmed) {
                        await notifier.markAsProcessed();
                      }
                    },
                  ),
              ],
            ),
            
            if (pallet.status == PalletStatus.inProgress && itemCount == 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Before processing this pallet, add the items you unpacked from it. This will allow cost allocation to calculate each item\'s purchase price.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Helper methods
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
  
  String _palletStatusToString(dynamic status) {
    if (status is String) {
      return status;
    } else if (status is PalletStatus) {
      switch (status) {
        case PalletStatus.inProgress:
          return 'in_progress';
        case PalletStatus.processed:
          return 'processed';
        case PalletStatus.archived:
          return 'archived';
        default:
          return 'in_progress';
      }
    }
    return 'in_progress'; // Default fallback
  }
  
  String _formatStatus(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'processed':
        return 'Processed';
      case 'archived':
        return 'Archived';
      default:
        return status.split('_')
            .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }
  
  String _formatAllocationMethod(String method) {
    switch (method.toLowerCase()) {
      case 'even':
        return 'Even Distribution (equal cost per item)';
      case 'proportional':
        return 'Proportional (based on estimated value)';
      case 'manual':
        return 'Manual (costs assigned individually)';
      default:
        return 'Even Distribution';
    }
  }

  // Method to handle the process pallet action
  void _processPallet(BuildContext context, WidgetRef ref, Pallet pallet) {
    if (pallet.status == PalletStatus.processed) {
      // Already processed, show info dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pallet Already Processed'),
          content: const Text(
            'This pallet has already been processed. '
            'Processing allocates costs and finalizes the pallet inventory.'
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    // Confirm processing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Pallet?'),
        content: const Text(
          'Processing will finalize this pallet and allocate costs to all items. '
          'You won\'t be able to add more items after processing. '
          'Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close the dialog
              context.pop();
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Processing pallet...'),
                    ],
                  ),
                ),
              );
              
              // Process the pallet using available methods in the notifier
              await ref.read(palletDetailNotifierProvider(pallet.id).notifier).markAsProcessed();
              
              if (context.mounted) {
                // Close loading dialog
                context.pop();
                
                // Refresh the pallet detail
                ref.invalidate(palletDetailProvider(pallet.id));
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pallet processed successfully'))
                );
              }
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  // Method to archive a pallet
  void _archivePallet(BuildContext context, WidgetRef ref, Pallet pallet) {
    // Can only archive processed pallets
    if (pallet.status != PalletStatus.processed) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Archive'),
          content: const Text(
            'Only processed pallets can be archived. '
            'Process this pallet first before archiving.'
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    // Confirm archiving
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Pallet?'),
        content: const Text(
          'Archiving will move this pallet to the archive section. '
          'The pallet and its items will still be accessible but won\'t appear in the active inventory. '
          'Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close the dialog
              context.pop();
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Archiving pallet...'),
                    ],
                  ),
                ),
              );
              
              // Archive the pallet using available methods in the notifier
              await ref.read(palletDetailNotifierProvider(pallet.id).notifier).markAsArchived();
              
              if (context.mounted) {
                // Close loading dialog
                context.pop();
                
                // Refresh and navigate back to inventory list
                ref.invalidate(palletListProvider);
                context.pop();
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pallet archived successfully'))
                );
              }
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }
} 