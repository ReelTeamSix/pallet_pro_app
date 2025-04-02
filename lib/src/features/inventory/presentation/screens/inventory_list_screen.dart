import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart'; // Placeholder, add shimmer dependency if not present
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:pallet_pro_app/src/routing/app_router.dart'; // Import route names

import '../providers/item_list_provider.dart';
import '../providers/pallet_list_provider.dart';
import '../../data/models/pallet.dart'; // Import Pallet model
import '../../data/models/item.dart'; // Import Item model
import '../../data/models/simple_pallet.dart'; // Import SimplePallet model
import '../../data/models/simple_item.dart'; // Import SimpleItem model
// TODO: Import Pallet and Item models if needed for display

// Placeholder ShimmerLoader - Replace with your actual implementation or package
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6, // Placeholder count
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48.0,
                height: 48.0,
                color: Colors.white,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Container(
                      width: 40.0,
                      height: 8.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palletsAsync = ref.watch(palletListProvider);
    final itemsAsync = ref.watch(itemListProvider);

    // Combine loading/error states for simplicity, or handle separately
    final isLoading = palletsAsync.isLoading || itemsAsync.isLoading;
    final error = palletsAsync.error ?? itemsAsync.error;
    final stackTrace = palletsAsync.stackTrace ?? itemsAsync.stackTrace;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        // TODO: Add FAB later for adding pallets (Part 5.3)
      ),
      body: isLoading
          ? const ShimmerLoader()
          : error != null
              ? Center(child: Text('Error loading inventory: $error\n$stackTrace'))
              : RefreshIndicator( // Optional: Add pull-to-refresh
                  onRefresh: () async {
                    ref.invalidate(palletListProvider);
                    ref.invalidate(itemListProvider);
                    // Allow time for providers to start reloading
                    await Future.wait([
                       ref.read(palletListProvider.future),
                       ref.read(itemListProvider.future)
                    ]).catchError((_){}); // Ignore errors here, they are handled by the provider state
                  },
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Pallets', style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      palletsAsync.maybeWhen(
                        data: (pallets) => pallets.isEmpty
                            ? const Center(child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('No pallets found.')))
                            : ListView.builder(
                                shrinkWrap: true, // Important inside another ListView
                                physics: const NeverScrollableScrollPhysics(), // Disable nested scrolling
                                itemCount: pallets.length,
                                itemBuilder: (context, index) {
                                  final Pallet pallet = pallets[index];
                                  return ListTile(
                                    title: Text(pallet.supplier ?? 'Unknown Supplier'),
                                    subtitle: Text('Type: ${pallet.type ?? "Unknown"}, ID: ${pallet.id}'),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      // Navigate to PalletDetailScreen
                                      context.goNamed(
                                        RouterNotifier.palletDetail,
                                        pathParameters: {'pid': pallet.id} // Pass pallet ID
                                      );
                                    },
                                  );
                                },
                              ),
                        orElse: () => Container(), // Handled by combined loading/error state above
                      ),
                      const Divider(height: 32.0, thickness: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Items', style: Theme.of(context).textTheme.headlineSmall),
                      ),
                       itemsAsync.maybeWhen(
                        data: (items) => items.isEmpty
                            ? const Center(child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('No items found.')))
                            : ListView.builder(
                                shrinkWrap: true, // Important inside another ListView
                                physics: const NeverScrollableScrollPhysics(), // Disable nested scrolling
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final Item item = items[index];
                                  return ListTile(
                                    title: Text(item.name ?? 'No description'),
                                    subtitle: Text('Condition: ${item.condition}, Qty: ${item.quantity}, ID: ${item.id}'),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      // Navigate to ItemDetailScreen
                                      context.goNamed(
                                        RouterNotifier.itemDetail,
                                        pathParameters: {'iid': item.id} // Pass item ID
                                      );
                                    },
                                  );
                                },
                              ),
                        orElse: () => Container(), // Handled by combined loading/error state above
                      ),
                    ],
                  ),
                ),
    );
  }
} 