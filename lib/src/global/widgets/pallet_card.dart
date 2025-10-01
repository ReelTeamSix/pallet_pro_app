import 'package:flutter/material.dart';
import 'package:pallet_pro_app/src/core/theme/status_colors.dart';
import 'package:pallet_pro_app/src/global/widgets/status_chip.dart';

/// A reusable card widget for displaying pallets in grid or list views.
///
/// This widget displays key information about a pallet such as name, supplier,
/// source, cost, and status with consistent styling.
class PalletCard extends StatelessWidget {
  final String id;
  final String name;
  final String? supplier;
  final String? source;
  final double cost;
  final String status;
  final VoidCallback onTap;

  const PalletCard({
    Key? key,
    required this.id,
    required this.name,
    this.supplier,
    this.source,
    required this.cost,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the status color for subtle background tint
    final Color statusColor = StatusColors.forPalletStatus(status);
    final bool isProcessed = status.toLowerCase() == 'processed';
    
    // Check for dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Adjust elevation based on status - processed items get higher elevation
    final double cardElevation = isProcessed ? 3.0 : 1.0;
    
    // Adjust border opacity for better visibility in dark mode
    final double borderOpacity = isDarkMode ? 0.6 : 0.3;
    
    // Get card background color from theme
    final Color cardColor = Theme.of(context).cardTheme.color ?? 
                            (isDarkMode ? Colors.grey.shade900 : Colors.white);

    return Card(
      elevation: cardElevation,
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
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
        child: Container(
          height: 130, // Increased height to accommodate better spacing
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            // Add a very subtle gradient background based on status
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 18,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: StatusChip(
                  status: status,
                  isPalletStatus: true,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    supplier ?? "Unknown",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (source != null && source!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Source: $source',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profit/ROI indicator could go here in future
                  Container(),
                  Text(
                    '\$${cost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 