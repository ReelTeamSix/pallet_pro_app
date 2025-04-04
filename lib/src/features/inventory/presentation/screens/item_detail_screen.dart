import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/storage_repository.dart';
import 'package:pallet_pro_app/src/global/utils/dialog_service.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

import '../providers/item_list_provider.dart'; // For SimpleItem model
import '../providers/item_detail_provider.dart';
import 'inventory_list_screen.dart'; // For ShimmerLoader access
import 'add_edit_item_screen.dart';

// Helper extension for item status conversion
extension ItemStatusExtension on ItemStatus {
  String get asString {
    switch (this) {
      case ItemStatus.inStock: return 'in_stock';
      case ItemStatus.forSale: return 'for_sale';
      case ItemStatus.listed: return 'listed';
      case ItemStatus.sold: return 'sold';
    }
  }
}

// Helper extension for item condition conversion
extension ItemConditionExtension on ItemCondition {
  String get asString {
    switch (this) {
      case ItemCondition.newItem: return 'New';
      case ItemCondition.openBox: return 'Open Box';
      case ItemCondition.usedGood: return 'Used - Good';
      case ItemCondition.usedFair: return 'Used - Fair';
      case ItemCondition.damaged: return 'Damaged';
      case ItemCondition.forParts: return 'For Parts';
    }
  }
}

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({required this.itemId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the real provider instead of the mock
    print('Attempting to load item with ID: $itemId');
    final itemAsync = ref.watch(itemDetailProvider(itemId));
    
    // Create a FutureBuilder for photos
    final photosFuture = ref.watch(itemPhotoRepositoryProvider).getItemPhotos(itemId);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          itemAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (item) {
              if (item == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit screen
                  context.goNamed(
                    RouterNotifier.addEditItem,
                    pathParameters: {'pid': item.palletId},
                    queryParameters: {'itemId': item.id},
                  );
                },
              );
            },
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const ShimmerLoader(),
        error: (err, stack) {
          print('Error loading item: $err'); // Debug logging
          print('Stack trace: $stack'); // Debug logging
          return Center(
            child: Text('Error loading item: $err'),
          );
        },
        data: (item) {
          if (item == null) {
            print('Item is null'); // Debug logging
            return const Center(child: Text('Item not found.'));
          }
          
          print('Successfully loaded item: ${item.id}'); // Debug logging
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Action Card - no longer pass the full item object
                _buildStatusActionCard(
                  context, 
                  ref, 
                  item.id, 
                  item.name ?? 'Unnamed Item', 
                  item.status.asString, // Convert enum to string
                  item.purchasePrice
                ),
                
                // Images
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Images', style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              icon: const Icon(Icons.add_a_photo),
                              onPressed: () {
                                // Navigate to edit item screen
                                context.goNamed(
                                  RouterNotifier.addEditItem,
                                  pathParameters: {'pid': item.palletId},
                                  queryParameters: {'itemId': item.id},
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        FutureBuilder<Result<List<ItemPhoto>>>(
                          future: photosFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            
                            if (snapshot.hasError) {
                              print('Error loading photos: ${snapshot.error}'); // Debug logging
                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text('Error loading photos: ${snapshot.error}'),
                                ),
                              );
                            }
                            
                            if (!snapshot.hasData || snapshot.data?.isFailure == true) {
                              print('No photo data available'); // Debug logging
                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    snapshot.data?.isFailure == true 
                                      ? 'Error: ${snapshot.data?.error?.message}' 
                                      : 'No photos available'
                                  ),
                                ),
                              );
                            }
                            
                            final photos = snapshot.data!.value;
                            print('Loaded ${photos.length} photos'); // Debug logging
                            
                            if (photos.isEmpty) {
                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text('No photos available for this item'),
                                ),
                              );
                            }
                            
                            return SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: photos.length,
                                itemBuilder: (context, index) {
                                  final photo = photos[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        photo.imageUrl,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('Error loading image: $error'); // Debug logging
                                          return Container(
                                            width: 200,
                                            color: Colors.grey[400],
                                            child: Center(
                                              child: Text('Error loading image: $error'),
                                            ),
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            width: 200,
                                            color: Colors.grey[300],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / 
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Item details
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Item Information',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: const Text('Name'),
                          subtitle: Text(item.name ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('Description'),
                          subtitle: Text(item.description ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Storage Location'),
                          subtitle: Text(item.storageLocation ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.storefront),
                          title: const Text('Sales Channel'),
                          subtitle: Text(item.salesChannel ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.numbers),
                          title: const Text('Quantity'),
                          subtitle: Text('${item.quantity}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.star),
                          title: const Text('Condition'),
                          subtitle: Text(item.condition.asString), // Convert enum to string
                        ),
                        ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: const Text('Purchase Price'),
                          subtitle: Text(item.purchasePrice != null
                              ? '\$${item.purchasePrice!.toStringAsFixed(2)}'
                              : 'Not specified'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Pallet association
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pallet Association', 
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Pallet ID'),
                          subtitle: Text(item.palletId),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () {
                              context.goNamed(
                                RouterNotifier.palletDetail,
                                pathParameters: {'pid': item.palletId}
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Status and dates
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Information', 
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        _buildItemStatusDetails(context, item),
                      ],
                    ),
                  ),
                ),
                
                // Footer with ID
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text('Item ID: ${item.id}', 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Card showing status and providing action buttons based on current status
  Widget _buildStatusActionCard(
    BuildContext context, 
    WidgetRef ref, 
    String itemId, 
    String itemName,
    String status,
    double? purchasePrice,
  ) {
    final statusColor = _getStatusColor(status);
    // Use the notifier provider instead of the FutureProvider
    final notifier = ref.watch(itemDetailNotifierProvider(itemId).notifier);
    
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
                  'Status: ${_formatStatus(status)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Show different action buttons based on current status
                if (status == "in_stock")
                  ElevatedButton.icon(
                    icon: const Icon(Icons.storefront),
                    label: const Text('List for Sale'),
                    onPressed: () async {
                      final result = await DialogService.showListItemDialog(
                        context: context,
                        itemName: itemName,
                        suggestedPrice: purchasePrice != null ? purchasePrice * 1.5 : 0.0,
                      );
                      
                      if (result != null) {
                        // Use the real notifier method
                        await notifier.markAsListed(
                          listingPrice: result['listingPrice'] as double,
                          listingPlatform: result['listingPlatform'] as String,
                          listingDate: result['listingDate'] as DateTime,
                        );
                      }
                    },
                  ),
                  
                if (status == "listed")
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.paid),
                        label: const Text('Mark Sold'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final result = await DialogService.showSoldItemDialog(
                            context: context,
                            itemName: itemName,
                            listingPrice: 0.0, // Placeholder until model updated
                            listingPlatform: 'Unknown', // Placeholder
                          );
                          
                          if (result != null) {
                            // Use the real notifier method
                            await notifier.markAsSold(
                              soldPrice: result['soldPrice'] as double,
                              sellingPlatform: result['sellingPlatform'] as String,
                              soldDate: result['soldDate'] as DateTime,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.undo),
                        label: const Text('Unlist'),
                        onPressed: () async {
                          final confirmed = await DialogService.showConfirmationDialog(
                            context: context,
                            title: 'Unlist Item',
                            message: 'Are you sure you want to remove this item from sale and mark it as in stock?',
                            confirmText: 'Unlist',
                            cancelText: 'Cancel',
                          );
                          
                          if (confirmed) {
                            // Use the real notifier method
                            await notifier.markAsInStock();
                          }
                        },
                      ),
                    ],
                  ),
                  
                if (status == "sold")
                  OutlinedButton.icon(
                    icon: const Icon(Icons.undo),
                    label: const Text('Mark as Listed Again'),
                    onPressed: () async {
                      final confirmed = await DialogService.showConfirmationDialog(
                        context: context,
                        title: 'Revert Sale',
                        message: 'Are you sure you want to revert this item\'s status from sold back to listed?',
                        confirmText: 'Revert to Listed',
                        cancelText: 'Cancel',
                      );
                      
                      if (confirmed) {
                        // We would need to keep the listing data when marking as sold to reuse here
                        // For now, we'll just show the listing dialog again
                        final result = await DialogService.showListItemDialog(
                          context: context,
                          itemName: itemName,
                          suggestedPrice: purchasePrice != null ? purchasePrice * 1.5 : 0.0,
                        );
                        
                        if (result != null) {
                          // Use the real notifier method
                          await notifier.markAsListed(
                            listingPrice: result['listingPrice'] as double,
                            listingPlatform: result['listingPlatform'] as String,
                            listingDate: result['listingDate'] as DateTime,
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build status details for Item type
  Widget _buildItemStatusDetails(BuildContext context, Item item) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.circle,
            color: _getStatusColor(item.status.asString),
            size: 16,
          ),
          title: const Text('Current Status'),
          subtitle: Text(_formatStatus(item.status.asString)),
        ),
        const Divider(),
        // Note: We're removing conditional rendering based on missing fields for now
        // We'll add those back in once the model is updated
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Added Date'),
          subtitle: Text(item.createdAt?.toString().split(' ')[0] ?? 'Not specified'),
        ),
      ],
    );
  }
  
  // Helper methods
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
  
  String _formatStatus(String status) {
    switch (status) {
      case 'in_stock':
        return 'In Stock';
      case 'listed':
        return 'Listed for Sale';
      case 'sold':
        return 'Sold';
      default:
        return status.split('_').map((word) => word.substring(0, 1).toUpperCase() + word.substring(1)).join(' ');
    }
  }
  
  double _getSuggestedPrice(Item item) {
    // Simple logic to suggest a price: cost + 50% markup
    if (item.purchasePrice != null) {
      return item.purchasePrice! * 1.5;
    }
    return 0.0;
  }
  
  IconData _getProfitIcon(Item item) {
    if (item.purchasePrice == null || item.soldPrice == null) return Icons.info_outline;
    
    double profit = item.soldPrice! - item.purchasePrice!;
    if (profit > 0) {
      return Icons.trending_up;
    } else if (profit < 0) {
      return Icons.trending_down;
    } else {
      return Icons.drag_handle;
    }
  }
  
  Color _getProfitColor(Item item) {
    if (item.purchasePrice == null || item.soldPrice == null) return Colors.grey;
    
    double profit = item.soldPrice! - item.purchasePrice!;
    if (profit > 0) {
      return Colors.green;
    } else if (profit < 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
  
  String _calculateProfitLoss(Item item) {
    if (item.purchasePrice == null || item.soldPrice == null) return 'Unknown';
    
    double profit = item.soldPrice! - item.purchasePrice!;
    return profit >= 0 
        ? '+\$${profit.toStringAsFixed(2)}' 
        : '-\$${profit.abs().toStringAsFixed(2)}';
  }
} 