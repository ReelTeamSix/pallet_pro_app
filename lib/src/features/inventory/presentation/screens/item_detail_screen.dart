import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/global/utils/dialog_service.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

import '../providers/item_detail_provider.dart';
import 'inventory_list_screen.dart';
import '../widgets/photo_management_dialog.dart';

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
  
  String get displayName {
    switch (this) {
      case ItemStatus.inStock: return 'In Stock';
      case ItemStatus.forSale: return 'For Sale';
      case ItemStatus.listed: return 'Listed';
      case ItemStatus.sold: return 'Sold';
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
    final itemAsync = ref.watch(itemDetailProvider(itemId));
    
    return Scaffold(
      body: itemAsync.when(
        loading: () => const ShimmerLoader(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading item', 
                style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('$err', 
                style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found.'));
          }
          
          return CustomScrollView(
            slivers: [
              // Custom app bar with image
              _buildAppBar(context, ref, item),
              
              // Main content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item name and basic info
                    _buildItemHeader(context, item),
                    
                    // Status and quick actions
                    _buildStatusCard(context, ref, item),
                    
                    // Pricing information (contextual based on status)
                    if (_shouldShowPricing(item))
                      _buildPricingCard(context, item),
                    
                    // Additional details (collapsible)
                    _buildDetailsSection(context, ref, item),
                    
                    const SizedBox(height: 80), // Bottom padding for FAB
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: itemAsync.maybeWhen(
        data: (item) => item != null ? _buildFloatingActions(context, ref, item) : null,
        orElse: () => null,
      ),
    );
  }

  /// App bar with hero image
  Widget _buildAppBar(BuildContext context, WidgetRef ref, Item item) {
    final photosFuture = ref.watch(itemPhotoRepositoryProvider).getItemPhotos(item.id);
    
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: FutureBuilder<Result<List<ItemPhoto>>>(
          future: photosFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData && 
                snapshot.data!.isSuccess && 
                snapshot.data!.value!.isNotEmpty) {
              final photos = snapshot.data!.value!;
              return Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        photos[index].imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                          Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 64, color: Colors.grey),
                          ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Photo count indicator
                  if (photos.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${photos.length}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }
            
            // No photos - show placeholder
            return Container(
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 64, color: Colors.grey[500]),
                  const SizedBox(height: 8),
                  Text(
                    'No photos',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.goNamed(
              RouterNotifier.editItem,
              pathParameters: {'iid': item.id},
            );
          },
        ),
      ],
    );
  }

  /// Item name, condition, quantity
  Widget _buildItemHeader(BuildContext context, Item item) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name
          Text(
            item.name ?? 'Unnamed Item',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Condition and quantity chips
          Wrap(
            spacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.star, size: 18),
                label: Text(item.condition.asString),
                backgroundColor: _getConditionColor(item.condition).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _getConditionColor(item.condition),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.inventory_2, size: 18),
                label: Text('Qty: ${item.quantity}'),
                backgroundColor: Colors.blue.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          // Description if available
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
          
          // Storage location if available
          if (item.storageLocation != null && item.storageLocation!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item.storageLocation!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Status card with action buttons
  Widget _buildStatusCard(BuildContext context, WidgetRef ref, Item item) {
    final statusColor = _getStatusColor(item.status.asString);
    final notifier = ref.watch(itemDetailNotifierProvider(item.id).notifier);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.status.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons based on status
            _buildStatusActions(context, ref, item, notifier),
          ],
        ),
      ),
    );
  }

  /// Status-specific action buttons
  Widget _buildStatusActions(
    BuildContext context,
    WidgetRef ref,
    Item item,
    dynamic notifier,
  ) {
    switch (item.status) {
      case ItemStatus.inStock:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.sell),
            label: const Text('List for Sale'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () async {
              final result = await DialogService.showListItemDialog(
                context: context,
                itemName: item.name ?? 'Unnamed Item',
                suggestedPrice: item.purchasePrice != null ? item.purchasePrice! * 1.5 : 0.0,
              );
              
              if (result != null) {
                await notifier.markAsListed(
                  listingPrice: result['listingPrice'] as double,
                  listingPlatform: result['listingPlatform'] as String,
                  listingDate: result['listingDate'] as DateTime,
                );
              }
            },
          ),
        );
        
      case ItemStatus.listed:
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark Sold'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  final result = await DialogService.showSoldItemDialog(
                    context: context,
                    itemName: item.name ?? 'Unnamed Item',
                    listingPrice: 0.0,
                    listingPlatform: 'Unknown',
                  );
                  
                  if (result != null) {
                    await notifier.markAsSold(
                      soldPrice: result['soldPrice'] as double,
                      sellingPlatform: result['sellingPlatform'] as String,
                      soldDate: result['soldDate'] as DateTime,
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Unlist'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  final confirmed = await DialogService.showConfirmationDialog(
                    context: context,
                    title: 'Unlist Item',
                    message: 'Remove this item from sale?',
                    confirmText: 'Unlist',
                    cancelText: 'Cancel',
                  );
                  
                  if (confirmed) {
                    await notifier.markAsInStock();
                  }
                },
              ),
            ),
          ],
        );
        
      case ItemStatus.sold:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.celebration, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Item sold!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.undo),
                label: const Text('Revert to Listed'),
                onPressed: () async {
                  final confirmed = await DialogService.showConfirmationDialog(
                    context: context,
                    title: 'Revert Sale',
                    message: 'Mark this item as listed again?',
                    confirmText: 'Revert',
                    cancelText: 'Cancel',
                  );
                  
                  if (confirmed) {
                    final result = await DialogService.showListItemDialog(
                      context: context,
                      itemName: item.name ?? 'Unnamed Item',
                      suggestedPrice: item.purchasePrice != null ? item.purchasePrice! * 1.5 : 0.0,
                    );
                    
                    if (result != null) {
                      await notifier.markAsListed(
                        listingPrice: result['listingPrice'] as double,
                        listingPlatform: result['listingPlatform'] as String,
                        listingDate: result['listingDate'] as DateTime,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        );
        
      default:
        return const SizedBox.shrink();
    }
  }

  /// Pricing card (shown contextually)
  Widget _buildPricingCard(BuildContext context, Item item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Purchase price (always shown if available)
            if (item.purchasePrice != null)
              _buildPriceRow(
                context,
                'Purchase Price',
                item.purchasePrice!,
                Icons.shopping_cart,
                Colors.blue,
              ),
            
            // Listing price (shown when listed or sold)
            if (item.listingPrice != null && 
                (item.status == ItemStatus.listed || item.status == ItemStatus.sold))
              _buildPriceRow(
                context,
                'Listed At',
                item.listingPrice!,
                Icons.local_offer,
                Colors.orange,
              ),
            
            // Sold price (shown when sold)
            if (item.soldPrice != null && item.status == ItemStatus.sold)
              _buildPriceRow(
                context,
                'Sold For',
                item.soldPrice!,
                Icons.monetization_on,
                Colors.green,
              ),
            
            // Profit/Loss (shown when sold)
            if (item.status == ItemStatus.sold && 
                item.purchasePrice != null && 
                item.soldPrice != null) ...[
              const Divider(height: 24),
              _buildProfitRow(context, item),
            ],
          ],
        ),
      ),
    );
  }

  /// Price row
  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double price,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Profit/Loss row
  Widget _buildProfitRow(BuildContext context, Item item) {
    final profit = item.soldPrice! - item.purchasePrice!;
    final isProfit = profit >= 0;
    final color = isProfit ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isProfit ? Icons.trending_up : Icons.trending_down,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isProfit ? 'Profit' : 'Loss',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Text(
            '${isProfit ? '+' : '-'}\$${profit.abs().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Additional details section (expandable)
  Widget _buildDetailsSection(BuildContext context, WidgetRef ref, Item item) {
    return ExpansionTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Additional Details'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Sales channel
              if (item.salesChannel != null)
                _buildDetailRow(
                  context,
                  'Sales Channel',
                  item.salesChannel!,
                  Icons.storefront,
                ),
              
              // Pallet link
              _buildDetailRow(
                context,
                'From Pallet',
                'View Pallet Details',
                Icons.category,
                onTap: () {
                  context.goNamed(
                    RouterNotifier.palletDetail,
                    pathParameters: {'pid': item.palletId},
                  );
                },
              ),
              
              // Created date
              if (item.createdAt != null)
                _buildDetailRow(
                  context,
                  'Added',
                  _formatDate(item.createdAt!),
                  Icons.calendar_today,
                ),
              
              // Listing date
              if (item.listingDate != null)
                _buildDetailRow(
                  context,
                  'Listed',
                  _formatDate(item.listingDate!),
                  Icons.schedule,
                ),
              
              // Sold date
              if (item.soldDate != null)
                _buildDetailRow(
                  context,
                  'Sold',
                  _formatDate(item.soldDate!),
                  Icons.check_circle,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Detail row
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: onTap != null ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  /// Floating action button
  Widget _buildFloatingActions(BuildContext context, WidgetRef ref, Item item) {
    return FloatingActionButton.extended(
      onPressed: () => _showPhotoManagementDialog(context, ref, item.id),
      icon: const Icon(Icons.add_a_photo),
      label: const Text('Manage Photos'),
    );
  }

  // Helper methods
  bool _shouldShowPricing(Item item) {
    return item.purchasePrice != null || 
           item.listingPrice != null || 
           item.soldPrice != null;
  }

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

  Color _getConditionColor(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.newItem:
        return Colors.green;
      case ItemCondition.openBox:
        return Colors.lightGreen;
      case ItemCondition.usedGood:
        return Colors.blue;
      case ItemCondition.usedFair:
        return Colors.orange;
      case ItemCondition.damaged:
        return Colors.red;
      case ItemCondition.forParts:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// Show the photo management dialog
  Future<void> _showPhotoManagementDialog(
    BuildContext context,
    WidgetRef ref,
    String itemId,
  ) async {
    final photosResult = await ref.read(itemPhotoRepositoryProvider).getItemPhotos(itemId);
    
    if (photosResult.isFailure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading photos: ${photosResult.error?.message}')),
        );
      }
      return;
    }

    final currentPhotos = photosResult.value ?? [];

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => PhotoManagementDialog(
          itemId: itemId,
          existingPhotos: currentPhotos,
          onSave: () {
            ref.invalidate(itemDetailProvider(itemId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photos updated successfully!')),
            );
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      );
    }
  }
}
