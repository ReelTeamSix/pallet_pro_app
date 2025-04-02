import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/item_list_provider.dart'; // For SimpleItem model
import '../providers/item_detail_provider.dart';
import 'inventory_list_screen.dart'; // For ShimmerLoader access

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({required this.itemId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemDetailProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        // TODO: Add Edit/Delete actions later
      ),
      body: itemAsync.when(
        loading: () => const ShimmerLoader(),
        error: (err, stack) => Center(
          child: Text('Error loading item: $err\n$stack'),
        ),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // TODO: Display item images (Part 5.4)
                Text('Name: ${item.name ?? "N/A"}', 
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Description: ${item.description ?? "N/A"}', 
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Quantity: ${item.quantity}', 
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Condition: ${item.condition}', 
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Purchase Price: \$${item.purchasePrice?.toStringAsFixed(2) ?? "N/A"}', 
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Created: ${item.createdAt?.toIso8601String() ?? "N/A"}', 
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text('Pallet ID: ${item.palletId}', 
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text('Item ID: ${item.id}', 
                    style: Theme.of(context).textTheme.bodySmall),
                // TODO: Add Scan button UI (Part 5.7)
                // TODO: Add Edit button (Part 5.5)
                // TODO: Add Delete button (Part 5.6)
                // TODO: Display Internal Price Suggestion / Break-even (Part 5.7)
              ],
            ),
          );
        },
      ),
    );
  }
} 