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
    // Use the mock provider instead of the real one for testing
    final palletAsync = ref.watch(palletDetailProvider(palletId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pallet Details'),
      ),
      body: palletAsync.when(
        loading: () => const ShimmerLoader(),
        error: (err, stack) => Center(
          child: Text('Error loading pallet: $err'),
        ),
        data: (pallet) {
          if (pallet == null) {
            return const Center(child: Text('Pallet not found.'));
          }
          
          // Display pallet details with improved formatting
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Basic Information', 
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.business),
                          title: const Text('Supplier'),
                          subtitle: Text(pallet.supplier ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Type'),
                          subtitle: Text(pallet.type ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Purchase Date'),
                          subtitle: Text(pallet.purchaseDate?.toString().split(' ')[0] ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: const Text('Cost'),
                          subtitle: Text('\$${pallet.cost.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Items section (placeholder for Phase 5.4)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Items', style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Add Item feature coming in Phase 5.4'))
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text('Items will be displayed here in Phase 5.4'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Footer with ID for debugging
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text('Pallet ID: ${pallet.id}', 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit Pallet feature coming in Phase 5.5'))
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
} 