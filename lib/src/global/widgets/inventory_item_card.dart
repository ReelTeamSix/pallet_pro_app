import 'package:flutter/material.dart';
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
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 8),
              if (description != null && description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qty: $quantity',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '\$${purchasePrice?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.label_outline,
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
      ),
    );
  }
} 