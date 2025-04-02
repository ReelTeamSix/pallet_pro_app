import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

import '../providers/item_list_provider.dart'; // For SimpleItem model
import '../providers/item_detail_provider.dart';
import 'inventory_list_screen.dart'; // For ShimmerLoader access

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({required this.itemId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the mock provider instead of the real one for testing
    final itemAsync = ref.watch(itemDetailProviderMock(itemId));
    // final itemAsync = ref.watch(itemDetailProvider(itemId)); // Use the real provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: itemAsync.when(
        loading: () => const ShimmerLoader(),
        error: (err, stack) => Center(
          child: Text('Error loading item: $err'),
        ),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder for images (Phase 5.4)
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Images', style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              icon: const Icon(Icons.add_a_photo),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Add Image feature coming in Phase 5.4'))
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text('Image placeholder - Coming in Phase 5.4'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Item details
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Item Information',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: const Text('Name'),
                          subtitle: Text(item.name ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('Description'),
                          subtitle: Text(item.description ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Storage Location'),
                          subtitle: Text(item.storageLocation ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.storefront),
                          title: const Text('Sales Channel'),
                          subtitle: Text(item.salesChannel ?? 'Not specified'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.numbers),
                          title: const Text('Quantity'),
                          subtitle: Text('${item.quantity}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.star),
                          title: const Text('Condition'),
                          subtitle: Text(item.condition),
                        ),
                        ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: const Text('Purchase Price'),
                          subtitle: Text(item.purchasePrice != null
                              ? '\$${item.purchasePrice!.toStringAsFixed(2)}'
                              : 'Not specified'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Pallet association
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pallet Association', 
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Pallet ID'),
                          subtitle: Text(item.palletId),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () {
                              context.goNamed(
                                RouterNotifier.palletDetail,
                                pathParameters: {'pid': item.palletId}
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Status and dates
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Information', 
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.sell),
                          title: const Text('Status'),
                          subtitle: Text(item.status),
                        ),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Added Date'),
                          subtitle: Text(item.createdAt?.toString().split(' ')[0] ?? 'Not specified'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Footer with ID
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text('Item ID: ${item.id}', 
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
            const SnackBar(content: Text('Edit Item feature coming in Phase 5.5'))
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
} 