import 'package:flutter/material.dart';
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
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  StatusChip(
                    status: status,
                    isPalletStatus: true,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${supplier ?? "Unknown"}'),
              if (source != null && source!.isNotEmpty)
                Text(
                  'Source: $source',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              const Spacer(),
              Text(
                '\$${cost.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 