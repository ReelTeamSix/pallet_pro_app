import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

class PalletListScreen extends ConsumerWidget {
  const PalletListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the mock provider for testing
    final palletListAsync = ref.watch(palletListProviderMock);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.goNamed(RouterNotifier.addPallet);
            },
          ),
        ],
      ),
      body: palletListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (pallets) {
          if (pallets.isEmpty) {
            return const Center(
              child: Text('No pallets found. Add your first pallet to get started!'),
            );
          }
          
          return ListView.builder(
            itemCount: pallets.length,
            itemBuilder: (context, index) {
              final pallet = pallets[index];
              return PalletListItem(pallet: pallet);
            },
          );
        },
      ),
    );
  }
}

class PalletListItem extends StatelessWidget {
  final SimplePallet pallet;
  
  const PalletListItem({Key? key, required this.pallet}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          context.goNamed(
            RouterNotifier.palletDetail, 
            pathParameters: {'pid': pallet.id}
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pallet icon with status color
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(pallet.status).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inventory_2, color: _getStatusColor(pallet.status)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(pallet.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _getStatusColor(pallet.status).withOpacity(0.5)),
                          ),
                          child: Text(
                            _formatPalletStatus(pallet.status),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(pallet.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pallet.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (pallet.supplier != null && pallet.supplier!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Supplier: ${pallet.supplier}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        if (pallet.type != null && pallet.type!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Type: ${pallet.type}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cost',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '\$${pallet.cost.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getStatusColor(pallet.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Purchase Date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        pallet.purchaseDate != null
                            ? pallet.purchaseDate.toString().substring(0, 10)
                            : 'Not specified',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper methods for formatting
  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_progress':
        return Colors.blue;
      case 'processed':
        return Colors.green;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  String _formatPalletStatus(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'processed':
        return 'Processed';
      case 'archived':
        return 'Archived';
      default:
        return status.split('_')
            .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }
} 