import 'package:flutter/material.dart';

/// Design system for consistent UI across the app
/// Based on Material Design 3 principles with custom adaptations for pallet resale business

// =============================================================================
// DESIGN TOKENS
// =============================================================================

class AppDesignTokens {
  // Spacing (8dp grid system)
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 24.0;

  // Elevation
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 4.0;
  static const double elevation4 = 8.0;

  // Status colors
  static const Color statusInStock = Color(0xFF2196F3); // Blue
  static const Color statusListed = Color(0xFFFF9800); // Orange
  static const Color statusSold = Color(0xFF4CAF50); // Green
  static const Color statusInProgress = Color(0xFFFFB300); // Amber
  static const Color statusProcessed = Color(0xFF66BB6A); // Light Green
  static const Color statusArchived = Color(0xFF9E9E9E); // Grey

  // Condition colors
  static const Color conditionNew = Color(0xFF4CAF50); // Green
  static const Color conditionOpenBox = Color(0xFF8BC34A); // Light Green
  static const Color conditionUsedGood = Color(0xFF2196F3); // Blue
  static const Color conditionUsedFair = Color(0xFFFF9800); // Orange
  static const Color conditionDamaged = Color(0xFFF44336); // Red
  static const Color conditionForParts = Color(0xFF9E9E9E); // Grey

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral colors
  static const Color neutral100 = Color(0xFFFAFAFA);
  static const Color neutral200 = Color(0xFFF5F5F5);
  static const Color neutral300 = Color(0xFFEEEEEE);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
}

// =============================================================================
// RESPONSIVE BREAKPOINTS
// =============================================================================

class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

/// Status badge widget
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    required this.label,
    required this.color,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacingS,
        vertical: AppDesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info chip widget
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const InfoChip({
    required this.icon,
    required this.label,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).primaryColor;
    
    return Chip(
      avatar: Icon(icon, size: 18, color: chipColor),
      label: Text(label),
      backgroundColor: chipColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: chipColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppDesignTokens.neutral400,
            ),
            const SizedBox(height: AppDesignTokens.spacingM),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppDesignTokens.neutral700,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesignTokens.spacingS),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppDesignTokens.neutral500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppDesignTokens.spacingL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    required this.title,
    this.subtitle,
    this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacingM,
        vertical: AppDesignTokens.spacingS,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppDesignTokens.neutral500,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Price display widget
class PriceDisplay extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const PriceDisplay({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.isLarge = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: isLarge ? 24 : 20, color: color),
        const SizedBox(width: AppDesignTokens.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppDesignTokens.neutral600,
                    ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: (isLarge
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.titleMedium)
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Stat card widget
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).primaryColor;

    return Card(
      elevation: AppDesignTokens.elevation2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDesignTokens.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: cardColor, size: 32),
              const SizedBox(height: AppDesignTokens.spacingS),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
              ),
              const SizedBox(height: AppDesignTokens.spacingXs),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppDesignTokens.neutral600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;

  const ResponsiveGrid({
    required this.children,
    this.childAspectRatio = 1.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final columns = AppBreakpoints.getGridColumns(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: AppDesignTokens.spacingM,
      mainAxisSpacing: AppDesignTokens.spacingM,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}

/// Responsive padding wrapper
class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final padding = AppBreakpoints.isDesktop(context)
        ? AppDesignTokens.spacingXl
        : AppDesignTokens.spacingM;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

/// Max width container for web
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidthContainer({
    required this.child,
    this.maxWidth = 1200,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

