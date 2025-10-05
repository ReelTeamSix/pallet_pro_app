import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';
import 'package:pallet_pro_app/src/global/widgets/design_system.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_list_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';

/// Dashboard - Command Center for Pallet Resale Business
/// 
/// Provides at-a-glance insights and quick actions for managing
/// liquidation pallet inventory and sales
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          _buildAppBar(context),
          
          // Main content
          SliverToBoxAdapter(
            child: MaxWidthContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsivePadding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome message
                        _buildWelcomeSection(context),
                        
                        const SizedBox(height: AppDesignTokens.spacingL),
                        
                        // Quick actions
                        _buildQuickActions(context),
                        
                        const SizedBox(height: AppDesignTokens.spacingL),
                        
                        // Stats overview
                        _buildStatsOverview(context, ref),
                        
                        const SizedBox(height: AppDesignTokens.spacingL),
                        
                        // Recent activity
                        _buildRecentActivity(context, ref),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom app bar with gradient
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Pallet Pro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Navigate to settings
            context.goNamed(RouterNotifier.settings);
          },
        ),
      ],
    );
  }

  /// Welcome section
  Widget _buildWelcomeSection(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDesignTokens.spacingXs),
        Text(
          'Ready to manage your pallet inventory?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppDesignTokens.neutral600,
              ),
        ),
      ],
    );
  }

  /// Quick actions section
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Quick Actions',
          subtitle: 'Common tasks at your fingertips',
        ),
        const SizedBox(height: AppDesignTokens.spacingM),
        ResponsiveGrid(
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              context,
              icon: Icons.add_box,
              title: 'New Pallet',
              subtitle: 'Add purchase',
              color: AppDesignTokens.statusInProgress,
              onTap: () => context.go(RouterNotifier.addEditPallet),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.inventory,
              title: 'View Pallets',
              subtitle: 'All inventory',
              color: AppDesignTokens.info,
              onTap: () => context.go(RouterNotifier.inventoryList),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.sell,
              title: 'List Items',
              subtitle: 'For sale',
              color: AppDesignTokens.statusListed,
              onTap: () => context.goNamed(RouterNotifier.inventoryList),
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'View reports',
              color: AppDesignTokens.success,
              onTap: () {
                // TODO: Navigate to analytics when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics coming soon!')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Quick action card
  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppDesignTokens.elevation2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDesignTokens.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppDesignTokens.spacingS),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDesignTokens.spacingXs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppDesignTokens.neutral600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Stats overview section
  Widget _buildStatsOverview(BuildContext context, WidgetRef ref) {
    final palletsAsync = ref.watch(palletListProvider);
    final itemsAsync = ref.watch(itemListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Overview',
          subtitle: 'Your business at a glance',
        ),
        const SizedBox(height: AppDesignTokens.spacingM),
        palletsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (pallets) {
            final inProgress = pallets.where((p) => p.status == PalletStatus.inProgress).length;
            final processed = pallets.where((p) => p.status == PalletStatus.processed).length;
            
            return itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) {
                final inStock = items.where((i) => i.status == ItemStatus.inStock).length;
                final listed = items.where((i) => i.status == ItemStatus.listed).length;
                final sold = items.where((i) => i.status == ItemStatus.sold).length;
                
                return ResponsiveGrid(
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      icon: Icons.inventory_2,
                      label: 'Active Pallets',
                      value: '$inProgress',
                      color: AppDesignTokens.statusInProgress,
                      onTap: () => context.go(RouterNotifier.inventoryList),
                    ),
                    StatCard(
                      icon: Icons.check_circle,
                      label: 'Processed',
                      value: '$processed',
                      color: AppDesignTokens.statusProcessed,
                    ),
                    StatCard(
                      icon: Icons.warehouse,
                      label: 'In Stock',
                      value: '$inStock',
                      color: AppDesignTokens.statusInStock,
                    ),
                    StatCard(
                      icon: Icons.storefront,
                      label: 'Listed',
                      value: '$listed',
                      color: AppDesignTokens.statusListed,
                    ),
                    StatCard(
                      icon: Icons.monetization_on,
                      label: 'Sold',
                      value: '$sold',
                      color: AppDesignTokens.statusSold,
                    ),
                    StatCard(
                      icon: Icons.attach_money,
                      label: 'Total Items',
                      value: '${items.length}',
                      color: AppDesignTokens.info,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Recent activity section
  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final palletsAsync = ref.watch(palletListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Pallets',
          subtitle: 'Latest additions',
          action: TextButton(
            onPressed: () => context.go(RouterNotifier.inventoryList),
            child: const Text('View All'),
          ),
        ),
        const SizedBox(height: AppDesignTokens.spacingS),
        palletsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDesignTokens.spacingXl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Error Loading',
            message: 'Could not load recent pallets',
          ),
          data: (pallets) {
            if (pallets.isEmpty) {
              return EmptyState(
                icon: Icons.inventory_2,
                title: 'No Pallets Yet',
                message: 'Add your first pallet to start tracking inventory',
                action: ElevatedButton.icon(
                  onPressed: () => context.go(RouterNotifier.addEditPallet),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Pallet'),
                ),
              );
            }

            // Show up to 5 most recent pallets
            final recentPallets = pallets.take(5).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentPallets.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDesignTokens.spacingS),
              itemBuilder: (context, index) {
                final pallet = recentPallets[index];
                return _buildRecentPalletCard(context, pallet);
              },
            );
          },
        ),
      ],
    );
  }

  /// Recent pallet card
  Widget _buildRecentPalletCard(BuildContext context, Pallet pallet) {
    final statusColor = _getStatusColor(pallet.status);

    return Card(
      elevation: AppDesignTokens.elevation1,
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
          child: Row(
            children: [
              // Icon with status color
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusS),
                ),
                child: Icon(Icons.inventory_2, color: statusColor, size: 24),
              ),
              const SizedBox(width: AppDesignTokens.spacingM),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pallet.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(
                          label: _formatStatus(pallet.status),
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDesignTokens.spacingXs),
                    Text(
                      '\$${pallet.cost.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Arrow
              const Icon(Icons.chevron_right, color: AppDesignTokens.neutral400),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
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
}

