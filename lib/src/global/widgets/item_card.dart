import 'package:flutter/material.dart';
import 'package:pallet_pro_app/src/core/theme/status_colors.dart';
import 'package:pallet_pro_app/src/global/widgets/status_chip.dart';

/// Enhanced item card with profit-focused design.
///
/// Shows the item's financial story: cost allocation, listing price, and potential profit.
class ItemCard extends StatelessWidget {
  const ItemCard({
    required this.id,
    required this.name,
    required this.status,
    required this.onTap,
    super.key,
    this.imageUrl,
    this.storageLocation,
    this.salesChannel,
    this.allocatedCost = 0,
    this.listingPrice,
    this.soldPrice,
    this.listedDate,
    this.soldDate,
    this.isStale = false,
  });
  final String id;
  final String name;
  final String? imageUrl;
  final String status;
  final String? storageLocation;
  final String? salesChannel;
  final double allocatedCost;
  final double? listingPrice;
  final double? soldPrice;
  final DateTime? listedDate;
  final DateTime? soldDate;
  final bool isStale;
  final VoidCallback onTap;

  bool get isSold => status.toLowerCase() == 'sold';
  bool get isListed =>
      status.toLowerCase() == 'listed' || status.toLowerCase() == 'for_sale';

  double get profit {
    if (isSold && soldPrice != null) {
      return soldPrice! - allocatedCost;
    } else if (isListed && listingPrice != null) {
      return listingPrice! - allocatedCost; // Potential profit
    }
    return 0;
  }

  bool get isProfitable => profit >= 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = StatusColors.forItemStatus(status);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Price to display
    final displayPrice = isSold ? soldPrice : listingPrice;
    final priceLabel = isSold ? 'SOLD' : (isListed ? 'LISTED' : 'COST');

    // Profit color
    final profitColor = isProfitable ? colorScheme.primary : colorScheme.error;

    return Card(
      elevation: isSold ? 1 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isStale
              ? StatusColors.stale.withValues(alpha: 0.6)
              : statusColor.withValues(alpha: isDarkMode ? 0.4 : 0.25),
          width: isStale
              ? StatusColors.borderWidth
              : StatusColors.edgeWidthForStatus(status),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              // Image / Placeholder
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholder(statusColor),
                        ),
                      )
                    : _buildPlaceholder(statusColor),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Name + Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusChip(status: status),
                        ],
                      ),

                      const Spacer(),

                      // Location / Channel
                      if (storageLocation != null || salesChannel != null)
                        Row(
                          children: [
                            if (storageLocation != null) ...[
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                storageLocation!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                            if (storageLocation != null && salesChannel != null)
                              const SizedBox(width: 8),
                            if (salesChannel != null) ...[
                              Icon(
                                Icons.storefront_outlined,
                                size: 14,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                salesChannel!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                      const SizedBox(height: 8),

                      // Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                priceLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                displayPrice != null
                                    ? '\$${displayPrice.toStringAsFixed(2)}'
                                    : '\$${allocatedCost.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSold
                                      ? profitColor
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Profit indicator (only for listed/sold)
                          if ((isListed || isSold) && displayPrice != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: profitColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isProfitable
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 14,
                                    color: profitColor,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${isProfitable ? '+' : ''}\$${profit.toStringAsFixed(0)}',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: profitColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                          // Stale indicator
                          if (isStale && !isSold)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: StatusColors.stale.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: StatusColors.stale,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Stale',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: StatusColors.stale,
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color statusColor) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: statusColor.withValues(alpha: 0.4),
      ),
    );
  }
}
