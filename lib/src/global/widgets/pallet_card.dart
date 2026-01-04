import 'package:flutter/material.dart';
import 'package:pallet_pro_app/src/core/theme/status_colors.dart';
import 'package:pallet_pro_app/src/global/widgets/status_chip.dart';

/// Enhanced pallet card with profit-focused design.
///
/// Shows the financial story prominently: cost, total sold, and profit/ROI.
class PalletCard extends StatelessWidget {
  const PalletCard({
    required this.id,
    required this.name,
    required this.cost,
    required this.status,
    required this.onTap,
    super.key,
    this.supplier,
    this.source,
    this.itemCount = 0,
    this.soldCount = 0,
    this.totalRevenue = 0,
  });
  final String id;
  final String name;
  final String? supplier;
  final String? source;
  final double cost;
  final String status;
  final int itemCount;
  final int soldCount;
  final double totalRevenue;
  final VoidCallback onTap;

  double get profit => totalRevenue - cost;
  double get roi => cost > 0 ? (profit / cost) * 100 : 0;
  bool get isProfitable => profit >= 0;
  bool get isProcessed => status.toLowerCase() == 'processed';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = StatusColors.forPalletStatus(status);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Profit color
    final profitColor = isProfitable ? colorScheme.primary : colorScheme.error;

    return Card(
      elevation: isProcessed ? 4 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withValues(alpha: isDarkMode ? 0.5 : 0.3),
          width: StatusColors.hairlineWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Name + Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pallet Icon with status color background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 24,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + Supplier
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (supplier != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            supplier!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status Chip
                  StatusChip(status: status, isPalletStatus: true),
                ],
              ),

              const SizedBox(height: 16),

              // Stats Row: Items progress
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Items count
                    _buildStatColumn(
                      context,
                      icon: Icons.category_outlined,
                      label: 'Items',
                      value: '$itemCount',
                    ),
                    _buildDivider(context),
                    // Sold count
                    _buildStatColumn(
                      context,
                      icon: Icons.sell_outlined,
                      label: 'Sold',
                      value: '$soldCount',
                      valueColor: soldCount > 0 ? colorScheme.primary : null,
                    ),
                    _buildDivider(context),
                    // Progress
                    _buildStatColumn(
                      context,
                      icon: Icons.pie_chart_outline,
                      label: 'Progress',
                      value: itemCount > 0
                          ? '${((soldCount / itemCount) * 100).toInt()}%'
                          : '0%',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Financial Row: Cost, Revenue, Profit
              Row(
                children: [
                  // Cost (what you paid)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COST',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${cost.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Revenue (what you made)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'REVENUE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${totalRevenue.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Profit (the bottom line)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PROFIT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              isProfitable
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 16,
                              color: profitColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${isProfitable ? '+' : ''}\$${profit.toStringAsFixed(0)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: profitColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
    );
  }
}
