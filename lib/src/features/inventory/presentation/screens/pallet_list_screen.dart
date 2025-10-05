import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart';
import 'package:pallet_pro_app/src/global/widgets/design_system.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

/// Pallet List Screen - Core inventory management for liquidation pallets
/// 
/// Shows all pallets with filtering and quick actions.
/// Optimized for pallet resale workflow.
class PalletListScreen extends ConsumerStatefulWidget {
  const PalletListScreen({super.key});

  @override
  ConsumerState<PalletListScreen> createState() => _PalletListScreenState();
}

class _PalletListScreenState extends ConsumerState<PalletListScreen>
    with WidgetsBindingObserver {
  String _filterStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(palletListProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(palletListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palletListAsync = ref.watch(palletListProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with search
          _buildAppBar(context),

          // Filter chips
          SliverToBoxAdapter(
            child: _buildFilterChips(context),
          ),

          // Pallet list
          palletListAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error Loading Pallets',
                message: 'Could not load your pallets. Please try again.',
                action: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(palletListProvider.notifier).refreshPallets();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ),
            ),
            data: (pallets) {
              // Apply filters
              var filteredPallets = pallets;

              // Status filter
              if (_filterStatus != 'all') {
                final statusFilter = _getStatusEnumFromString(_filterStatus);
                if (statusFilter != null) {
                  filteredPallets = filteredPallets
                      .where((p) => p.status == statusFilter)
                      .toList();
                }
              }

              // Search filter
              if (_searchQuery.isNotEmpty) {
                filteredPallets = filteredPallets
                    .where((p) =>
                        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (p.supplier?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
                    .toList();
              }

              if (filteredPallets.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.inventory_2,
                    title: pallets.isEmpty
                        ? 'No Pallets Yet'
                        : 'No Pallets Match',
                    message: pallets.isEmpty
                        ? 'Add your first pallet to start tracking inventory'
                        : 'Try adjusting your filters',
                    action: pallets.isEmpty
                        ? ElevatedButton.icon(
                            onPressed: () => context.go(RouterNotifier.addEditPallet),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Pallet'),
                          )
                        : null,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(AppDesignTokens.spacingM),
                sliver: AppBreakpoints.isMobile(context)
                    ? _buildListView(context, filteredPallets)
                    : _buildGridView(context, filteredPallets),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RouterNotifier.addEditPallet),
        icon: const Icon(Icons.add),
        label: const Text('New Pallet'),
      ),
    );
  }

  /// App bar with search
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Search pallets...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.white),
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(palletListProvider.notifier).refreshPallets();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Refreshing...'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Filter chips
  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacingM,
        vertical: AppDesignTokens.spacingS,
      ),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: AppDesignTokens.spacingS),
          _buildFilterChip('In Progress', 'in_progress'),
          const SizedBox(width: AppDesignTokens.spacingS),
          _buildFilterChip('Processed', 'processed'),
          const SizedBox(width: AppDesignTokens.spacingS),
          _buildFilterChip('Archived', 'archived'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    final color = _getStatusColor(value);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      backgroundColor: isSelected ? color.withOpacity(0.2) : null,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : AppDesignTokens.neutral700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// List view for mobile
  Widget _buildListView(BuildContext context, List<Pallet> pallets) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final pallet = pallets[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDesignTokens.spacingM),
            child: PalletCard(pallet: pallet),
          );
        },
        childCount: pallets.length,
      ),
    );
  }

  /// Grid view for tablet/desktop
  Widget _buildGridView(BuildContext context, List<Pallet> pallets) {
    final columns = AppBreakpoints.getGridColumns(context);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppDesignTokens.spacingM,
        mainAxisSpacing: AppDesignTokens.spacingM,
        childAspectRatio: 1.3,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final pallet = pallets[index];
          return PalletCard(pallet: pallet);
        },
        childCount: pallets.length,
      ),
    );
  }

  PalletStatus? _getStatusEnumFromString(String status) {
    switch (status) {
      case 'in_progress':
        return PalletStatus.inProgress;
      case 'processed':
        return PalletStatus.processed;
      case 'archived':
        return PalletStatus.archived;
      default:
        return null;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_progress':
        return AppDesignTokens.statusInProgress;
      case 'processed':
        return AppDesignTokens.statusProcessed;
      case 'archived':
        return AppDesignTokens.statusArchived;
      default:
        return AppDesignTokens.info;
    }
  }
}


/// Pallet card widget
class PalletCard extends StatelessWidget {
  final Pallet pallet;

  const PalletCard({required this.pallet, super.key});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(pallet.status);

    return Card(
      elevation: AppDesignTokens.elevation2,
      child: InkWell(
        onTap: () {
          context.goNamed(
            RouterNotifier.palletDetail,
            pathParameters: {'pid': pallet.id},
          );
        },
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDesignTokens.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and status
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDesignTokens.radiusS),
                    ),
                    child: Icon(Icons.inventory_2, color: statusColor),
                  ),
                  const Spacer(),
                  StatusBadge(
                    label: _formatStatus(pallet.status),
                    color: statusColor,
                  ),
                ],
              ),

              const SizedBox(height: AppDesignTokens.spacingM),

              // Pallet name
              Text(
                pallet.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppDesignTokens.spacingS),

              // Supplier and type
              if (pallet.supplier != null && pallet.supplier!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 14,
                      color: AppDesignTokens.neutral500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pallet.supplier!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppDesignTokens.neutral600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const Spacer(),

              // Divider
              const Divider(height: AppDesignTokens.spacingM),

              // Footer with cost and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cost
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cost',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppDesignTokens.neutral500,
                            ),
                      ),
                      Text(
                        '\$${pallet.cost.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                      ),
                    ],
                  ),

                  // Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Purchased',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppDesignTokens.neutral500,
                            ),
                      ),
                      Text(
                        _formatDate(pallet.purchaseDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
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

  Color _getStatusColor(PalletStatus status) {
    switch (status) {
      case PalletStatus.inProgress:
        return AppDesignTokens.statusInProgress;
      case PalletStatus.processed:
        return AppDesignTokens.statusProcessed;
      case PalletStatus.archived:
        return AppDesignTokens.statusArchived;
    }
  }

  String _formatStatus(PalletStatus status) {
    switch (status) {
      case PalletStatus.inProgress:
        return 'In Progress';
      case PalletStatus.processed:
        return 'Processed';
      case PalletStatus.archived:
        return 'Archived';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.month}/${date.day}/${date.year % 100}';
    }
  }
}
