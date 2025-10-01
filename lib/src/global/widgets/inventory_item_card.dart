import 'package:flutter/material.dart';
import 'package:pallet_pro_app/src/core/theme/status_colors.dart';
import 'package:pallet_pro_app/src/global/widgets/status_chip.dart';

/// A reusable card widget for displaying inventory items in grid or list views.
/// 
/// This widget displays key information about an item such as name, description,
/// price, quantity, condition, and status with consistent styling.
class InventoryItemCard extends StatelessWidget {
  final String id;
  final String name;
  final String? description;
  final double? purchasePrice;
  final int quantity;
  final String condition;
  final String status;
  final String? imageUrl;
  final VoidCallback onTap;

  const InventoryItemCard({
    Key? key,
    required this.id,
    required this.name,
    this.description,
    this.purchasePrice,
    required this.quantity,
    required this.condition,
    required this.status,
    this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the status color for styling
    final Color statusColor = StatusColors.forItemStatus(status);
    
    // Check if in dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Adjust card elevation - items with higher value states get higher elevation
    final bool isSold = status.toLowerCase() == 'sold';
    final bool isListed = status.toLowerCase() == 'listed' || status.toLowerCase() == 'for_sale';
    
    // Items that are sold have highest elevation, then listed, then in_stock
    final double cardElevation = isSold ? 3.0 : (isListed ? 2.0 : 1.0);
    
    // Fixed height with extra space for description if needed
    final double cardHeight = 170.0;
    
    // Adjust border opacity for better visibility in dark mode
    final double borderOpacity = isDarkMode ? 0.6 : 0.3;
    
    // Get card background color from theme
    final Color cardColor = Theme.of(context).cardTheme.color ?? 
                           (isDarkMode ? Colors.grey.shade900 : Colors.white);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(borderOpacity),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: cardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview (if available)
              if (imageUrl != null)
                SizedBox(
                  height: 70,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                      child: Icon(
                        _getItemTypeIcon(),
                        size: 30,
                        color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                    ),
                  ),
                )
              else
                // Placeholder colored area for visual balance when no image
                Container(
                  height: 20,
                  width: double.infinity,
                  color: isDarkMode ? statusColor.withOpacity(0.25) : statusColor.withOpacity(0.1),
                ),
              
              // Content padding
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    // Add subtle gradient background for better visual hierarchy
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        cardColor,
                        isDarkMode 
                          ? statusColor.withOpacity(0.15) // Higher opacity for dark mode
                          : statusColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top row with name
                      Row(
                        children: [
                          Icon(
                            _getItemTypeIcon(),
                            size: 18,
                            color: statusColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      // Status Chip positioned below name
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: StatusChip(status: status),
                      ),
                      
                      // Description section (if available)
                      if (description != null && description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                          child: Text(
                            description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      
                      // Fixed space instead of Spacer
                      const SizedBox(height: 8),
                      
                      // Bottom rows with item details - Now at the end of the card
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.format_list_numbered,
                                        size: 14,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Qty: $quantity',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                // Price with financial indicators
                                _buildPriceIndicator(context),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  _getConditionIcon(),
                                  size: 14,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  condition,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to get item type icon based on name or other properties
  IconData _getItemTypeIcon() {
    // This is a simple implementation - could be enhanced with better categorization
    if (name.toLowerCase().contains('headset') || 
        name.toLowerCase().contains('earphone') ||
        name.toLowerCase().contains('audio')) {
      return Icons.headset;
    } else if (name.toLowerCase().contains('tv') || 
               name.toLowerCase().contains('monitor') ||
               name.toLowerCase().contains('display')) {
      return Icons.tv;
    } else if (name.toLowerCase().contains('phone') || 
               name.toLowerCase().contains('mobile')) {
      return Icons.smartphone;
    } else if (name.toLowerCase().contains('laptop') || 
               name.toLowerCase().contains('computer')) {
      return Icons.laptop;
    } else if (name.toLowerCase().contains('cup') || 
               name.toLowerCase().contains('tumbler') ||
               name.toLowerCase().contains('mug')) {
      return Icons.local_cafe;
    } else if (name.toLowerCase().contains('mop') || 
               name.toLowerCase().contains('clean')) {
      return Icons.cleaning_services;
    } else {
      return Icons.inventory_2;
    }
  }

  // Method to get condition icon
  IconData _getConditionIcon() {
    switch (condition.toLowerCase()) {
      case 'new':
      case 'newitem':
        return Icons.star;
      case 'usedgood':
      case 'used_good':
        return Icons.thumb_up_outlined;
      case 'usedfair':
      case 'used_fair':
        return Icons.thumbs_up_down;
      case 'usedpoor':
      case 'used_poor':
        return Icons.thumb_down_outlined;
      default:
        return Icons.label_outline;
    }
  }

  // Build price indicator with up/down arrow if applicable
  Widget _buildPriceIndicator(BuildContext context) {
    // You can enhance this in the future to show profit indicators
    // For now, just showing the purchase price
    Color priceColor = Theme.of(context).colorScheme.primary;
    
    // For sold items, we could show green if profitable
    if (status.toLowerCase() == 'sold') {
      priceColor = Colors.green;
    }
    
    return Text(
      '\$${purchasePrice?.toStringAsFixed(2) ?? '0.00'}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: priceColor,
      ),
    );
  }
} 