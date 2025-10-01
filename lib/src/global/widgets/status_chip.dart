import 'package:flutter/material.dart';
import 'package:pallet_pro_app/src/core/theme/status_colors.dart';
import 'package:pallet_pro_app/src/core/utils/string_formatter.dart';

/// A reusable chip widget for displaying status information with consistent styling.
/// 
/// This widget can be used for both pallet and item statuses.
class StatusChip extends StatelessWidget {
  final String status;
  final bool isPalletStatus;

  const StatusChip({
    Key? key,
    required this.status,
    this.isPalletStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isPalletStatus 
        ? StatusColors.forPalletStatus(status)
        : StatusColors.forItemStatus(status);
        
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Enhanced luminance-based text color with better dark mode contrast
    final Color textColor = statusColor.computeLuminance() > 0.5 
        ? Colors.black 
        : Colors.white;
        
    // Adjust background opacity based on theme
    final double bgOpacity = isDarkMode ? 0.9 : 1.0;
    
    // Adjust shadow opacity based on theme
    final double shadowOpacity = isDarkMode ? 0.5 : 0.3;

    // Select an icon based on the status
    IconData statusIcon = Icons.help_outline;
    if (isPalletStatus) {
      statusIcon = _getIconForPalletStatus(status);
    } else {
      statusIcon = _getIconForItemStatus(status);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(bgOpacity),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(shadowOpacity),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 10,
            color: textColor,
          ),
          const SizedBox(width: 2),
          Text(
            StringFormatter.snakeCaseToTitleCase(status),
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPalletStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return Icons.pending;
      case 'processed':
        return Icons.check_circle_outline;
      case 'archived':
        return Icons.archive_outlined;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getIconForItemStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_stock':
        return Icons.inventory_2;
      case 'listed':
      case 'for_sale':
        return Icons.storefront;
      case 'sold':
        return Icons.shopping_cart_checkout;
      default:
        return Icons.help_outline;
    }
  }
} 