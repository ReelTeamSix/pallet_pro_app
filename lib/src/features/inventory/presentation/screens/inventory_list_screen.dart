import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart'; // Placeholder, add shimmer dependency if not present
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:pallet_pro_app/src/routing/app_router.dart'; // Import route names

import '../providers/item_list_provider.dart';
import '../providers/pallet_list_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
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

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Force rebuild when tab changes to update the FAB
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.inventory_2),
              text: 'Pallets',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'Items',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PalletsTab(),
          _ItemsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final String message = _tabController.index == 0
              ? 'Add Pallet feature coming in Phase 5.3'
              : 'Add Item feature coming in Phase 5.4';
              
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message))
          );
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Add Pallet' : 'Add Item'),
      ),
    );
  }
}

class _PalletsTab extends ConsumerWidget {
  const _PalletsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palletsAsync = ref.watch(simplePalletListProvider);
    
    return palletsAsync.when(
      loading: () => const ShimmerLoader(),
      error: (error, stackTrace) => Center(
        child: Text('Error loading pallets: $error'),
      ),
      data: (pallets) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(simplePalletListProvider);
        },
        child: pallets.isEmpty
          ? const Center(child: Text('No pallets found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: pallets.length,
              itemBuilder: (context, index) {
                final pallet = pallets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(pallet.name),
                    subtitle: Text('${pallet.supplier ?? "Unknown"} | \$${pallet.cost.toStringAsFixed(2)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.goNamed(
                        RouterNotifier.palletDetail,
                        pathParameters: {'pid': pallet.id}
                      );
                    },
                  ),
                );
              },
            ),
      ),
    );
  }
}

class _ItemsTab extends ConsumerWidget {
  const _ItemsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(simpleItemListProvider);
    
    return itemsAsync.when(
      loading: () => const ShimmerLoader(),
      error: (error, stackTrace) => Center(
        child: Text('Error loading items: $error'),
      ),
      data: (items) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(simpleItemListProvider);
        },
        child: items.isEmpty
          ? const Center(child: Text('No items found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(item.name ?? 'Unnamed Item'),
                    subtitle: Text('Condition: ${item.condition} | Qty: ${item.quantity}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.goNamed(
                        RouterNotifier.itemDetail,
                        pathParameters: {'iid': item.id}
                      );
                    },
                  ),
                );
              },
            ),
      ),
    );
  }
} 