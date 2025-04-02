import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pallet_list_provider.dart'; // For SimplePallet model
import '../providers/pallet_detail_provider.dart';
import 'inventory_list_screen.dart'; // For ShimmerLoader access

class PalletDetailScreen extends ConsumerWidget {
  final String palletId;

  const PalletDetailScreen({required this.palletId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the provider we created to fetch pallet details
    final palletAsync = ref.watch(palletDetailProvider(palletId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pallet Details'),
        // TODO: Add Edit/Delete actions later
      ),
      body: palletAsync.when(
        loading: () => const ShimmerLoader(),
        error: (err, stack) => Center(
          child: Text('Error loading pallet: $err\n$stack'),
        ),
        data: (pallet) {
          if (pallet == null) {
            return const Center(child: Text('Pallet not found.'));
          }
          
          // Display pallet details
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('Supplier: ${pallet.supplier ?? "N/A"}', 
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Type: ${pallet.type ?? "N/A"}', 
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Purchase Date: ${pallet.purchaseDate?.toIso8601String() ?? "N/A"}', 
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Total Cost: \$${pallet.cost.toStringAsFixed(2)}', 
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('ID: ${pallet.id}', 
                    style: Theme.of(context).textTheme.bodySmall),
                // TODO: Add section to display items associated with this pallet
                // TODO: Add Edit button (Part 5.5)
                // TODO: Add Delete button (Part 5.6)
              ],
            ),
          );
        },
      ),
    );
  }
} 