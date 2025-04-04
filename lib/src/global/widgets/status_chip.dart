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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Text(
        StringFormatter.snakeCaseToTitleCase(status),
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
        ),
      ),
    );
  }
} 