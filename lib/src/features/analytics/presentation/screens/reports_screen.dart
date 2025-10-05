import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pallet_pro_app/src/global/widgets/design_system.dart';
import 'package:pallet_pro_app/src/features/analytics/domain/time_period.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';

/// Reports/Analytics Screen
/// 
/// Comprehensive analytics dashboard showing financial performance,
/// top performers, and business insights for pallet resellers
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  TimePeriod _selectedPeriod = TimePeriod.last30Days;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // Trigger rebuild
        },
        child: CustomScrollView(
          slivers: [
            // App bar
            _buildAppBar(context),
            
            // Main content
            SliverToBoxAdapter(
              child: MaxWidthContainer(
                child: ResponsivePadding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDesignTokens.spacingL),
                      
                      // Time Period Selector
                      _buildTimePeriodSelector(context),
                      
                      const SizedBox(height: AppDesignTokens.spacingL),
                      
                      // Financial Metrics Cards
                      _buildFinancialMetrics(context),
                      
                      const SizedBox(height: AppDesignTokens.spacingL),
                      
                      // Quick Stats Grid
                      _buildQuickStatsGrid(context),
                      
                      const SizedBox(height: AppDesignTokens.spacingL),
                      
                      // Top Performers Section
                      _buildTopPerformersSection(context),
                      
                      const SizedBox(height: AppDesignTokens.spacingL),
                      
                      // Fun Facts Section
                      _buildFunFactsSection(context),
                      
                      const SizedBox(height: AppDesignTokens.spacingXxl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// App Bar with user personalization
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics & Reports',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppDesignTokens.fontXl,
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final authAsync = ref.watch(authControllerProvider);
                return authAsync.when(
                  data: (user) {
                    if (user?.email != null) {
                      return Text(
                        'Business Performance',
                        style: const TextStyle(
                          fontSize: AppDesignTokens.fontS,
                          fontWeight: FontWeight.normal,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
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
    );
  }

  /// Time Period Selector
  Widget _buildTimePeriodSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Period',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDesignTokens.spacingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPeriodChip(context, 'Last 7 Days', TimePeriod.last7Days),
              const SizedBox(width: AppDesignTokens.spacingS),
              _buildPeriodChip(context, 'Last 30 Days', TimePeriod.last30Days),
              const SizedBox(width: AppDesignTokens.spacingS),
              _buildPeriodChip(context, 'Last 90 Days', TimePeriod.last90Days),
              const SizedBox(width: AppDesignTokens.spacingS),
              _buildPeriodChip(context, 'All Time', TimePeriod.allTime),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(BuildContext context, String label, TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected 
            ? (isDark ? Colors.white : Theme.of(context).primaryColor)
            : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = period;
        });
      },
      selectedColor: isDark 
        ? Theme.of(context).primaryColor.withOpacity(0.3)
        : Theme.of(context).primaryColor.withOpacity(0.15),
      backgroundColor: isDark
        ? Theme.of(context).colorScheme.surface
        : null,
      side: isSelected
        ? BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          )
        : null,
      checkmarkColor: isDark ? Colors.white : Theme.of(context).primaryColor,
    );
  }

  /// Financial Metrics Cards
  Widget _buildFinancialMetrics(BuildContext context) {
    final repository = ref.read(itemRepositoryProvider);
    final dateRange = _selectedPeriod.toDateRange();
    
    return FutureBuilder(
      future: repository.getFinancialSummary(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(context);
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isFailure) {
          return _buildErrorCard(context, 'Unable to load financial data');
        }
        
        final data = snapshot.data!.value as Map<String, dynamic>;
        final netProfit = (data['total_profit'] as num?)?.toDouble() ?? 0.0;
        final actualRevenue = (data['actual_revenue'] as num?)?.toDouble() ?? 0.0;
        final avgMargin = (data['avg_margin'] as num?)?.toDouble() ?? 0.0;
        final avgProfit = (data['avg_profit'] as num?)?.toDouble() ?? 0.0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDesignTokens.spacingM),
            ResponsiveGrid(
              children: [
                _buildMetricCard(
                  context,
                  'Net Profit',
                  '\$${netProfit.toStringAsFixed(2)}',
                  Icons.trending_up,
                  netProfit >= 0 ? Colors.green : Colors.red,
                  subtitle: 'Total earnings',
                ),
                _buildMetricCard(
                  context,
                  'Revenue',
                  '\$${actualRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.blue,
                  subtitle: 'Sales income',
                ),
                _buildMetricCard(
                  context,
                  'Profit Margin',
                  '${avgMargin.toStringAsFixed(1)}%',
                  Icons.percent,
                  Colors.purple,
                  subtitle: 'Average',
                ),
                _buildMetricCard(
                  context,
                  'Avg Profit',
                  '\$${avgProfit.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  Colors.orange,
                  subtitle: 'Per item',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: AppDesignTokens.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDesignTokens.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(AppDesignTokens.opacityLight),
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusS),
              ),
              child: Icon(icon, color: color, size: AppDesignTokens.iconM),
            ),
            const SizedBox(height: AppDesignTokens.spacingS),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDesignTokens.spacingXs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDesignTokens.spacingXs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: AppDesignTokens.fontXs,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Quick Stats Grid
  Widget _buildQuickStatsGrid(BuildContext context) {
    final repository = ref.read(itemRepositoryProvider);
    final dateRange = _selectedPeriod.toDateRange();
    
    return FutureBuilder(
      future: repository.getFinancialSummary(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isFailure) {
          return const SizedBox.shrink();
        }
        
        final data = snapshot.data!.value as Map<String, dynamic>;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDesignTokens.spacingM),
            ResponsiveGrid(
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  icon: Icons.inventory_2,
                  label: 'In Stock',
                  value: '${data['in_stock_count'] ?? 0}',
                  color: Colors.blue,
                ),
                StatCard(
                  icon: Icons.storefront,
                  label: 'Listed',
                  value: '${data['listed_count'] ?? 0}',
                  color: Colors.purple,
                ),
                StatCard(
                  icon: Icons.check_circle,
                  label: 'Sold',
                  value: '${data['sold_count'] ?? 0}',
                  color: Colors.green,
                ),
                StatCard(
                  icon: Icons.category,
                  label: 'Total Items',
                  value: '${data['total_items'] ?? 0}',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Top Performers Section
  Widget _buildTopPerformersSection(BuildContext context) {
    final repository = ref.read(itemRepositoryProvider);
    final dateRange = _selectedPeriod.toDateRange();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDesignTokens.spacingM),
        FutureBuilder(
          future: Future.wait([
            repository.getBestPerformer(
              metric: 'revenue',
              startDate: dateRange.start,
              endDate: dateRange.end,
            ),
            repository.getBestPerformer(
              metric: 'profit',
              startDate: dateRange.start,
              endDate: dateRange.end,
            ),
            repository.getBestPerformer(
              metric: 'speed',
              startDate: dateRange.start,
              endDate: dateRange.end,
            ),
            repository.getBestPerformer(
              metric: 'margin',
              startDate: dateRange.start,
              endDate: dateRange.end,
            ),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard(context);
            }
            
            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorCard(context, 'Unable to load top performers');
            }
            
            final results = snapshot.data!;
            final bestSelling = results[0].isSuccess ? results[0].value : null;
            final highestProfit = results[1].isSuccess ? results[1].value : null;
            final fastestSelling = results[2].isSuccess ? results[2].value : null;
            final bestMargin = results[3].isSuccess ? results[3].value : null;
            
            if (bestSelling == null && highestProfit == null && fastestSelling == null && bestMargin == null) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDesignTokens.spacingL),
                  child: EmptyState(
                    icon: Icons.star_border,
                    title: 'No Sales Yet',
                    message: 'Sell some items to see top performers',
                  ),
                ),
              );
            }
            
            return Column(
              children: [
                if (bestSelling != null)
                  _buildPerformerCard(
                    context,
                    'Best Selling Item',
                    bestSelling.name,
                    '\$${bestSelling.soldPrice?.toStringAsFixed(2) ?? '0.00'}',
                    Icons.star,
                    Colors.amber,
                  ),
                if (highestProfit != null) ...[
                  const SizedBox(height: AppDesignTokens.spacingS),
                  _buildPerformerCard(
                    context,
                    'Highest Profit Item',
                    highestProfit.name,
                    '\$${((highestProfit.soldPrice ?? 0.0) - (highestProfit.purchasePrice ?? 0.0)).toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ],
                if (fastestSelling != null) ...[
                  const SizedBox(height: AppDesignTokens.spacingS),
                  _buildPerformerCard(
                    context,
                    'Fastest Selling Item',
                    fastestSelling.name,
                    (fastestSelling.soldDate != null && fastestSelling.createdAt != null)
                        ? '${fastestSelling.soldDate!.difference(fastestSelling.createdAt!).inDays} days'
                        : 'N/A',
                    Icons.speed,
                    Colors.blue,
                  ),
                ],
                if (bestMargin != null) ...[
                  const SizedBox(height: AppDesignTokens.spacingS),
                  _buildPerformerCard(
                    context,
                    'Best Margin Item',
                    bestMargin.name,
                    bestMargin.purchasePrice != null && bestMargin.purchasePrice! > 0
                        ? '${(((bestMargin.soldPrice ?? 0.0) - bestMargin.purchasePrice!) / bestMargin.purchasePrice! * 100).toStringAsFixed(1)}%'
                        : 'N/A',
                    Icons.percent,
                    Colors.purple,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPerformerCard(
    BuildContext context,
    String title,
    String itemName,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: AppDesignTokens.elevation1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spacingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDesignTokens.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(AppDesignTokens.opacityLight),
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
              ),
              child: Icon(icon, color: color, size: AppDesignTokens.iconL),
            ),
            const SizedBox(width: AppDesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: AppDesignTokens.spacingXs),
                  Text(
                    itemName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fun Facts Section
  Widget _buildFunFactsSection(BuildContext context) {
    final repository = ref.read(itemRepositoryProvider);
    final dateRange = _selectedPeriod.toDateRange();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fun Facts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDesignTokens.spacingM),
        FutureBuilder(
          future: Future.wait([
            repository.getFinancialSummary(
              startDate: dateRange.start,
              endDate: dateRange.end,
            ),
            repository.getBestDay(
              startDate: dateRange.start,
              endDate: dateRange.end,
            ),
            repository.getPalletSourcePerformance(
              startDate: dateRange.start,
              endDate: dateRange.end,
            ),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard(context);
            }
            
            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorCard(context, 'Unable to load fun facts');
            }
            
            final results = snapshot.data!;
            final financialData = results[0].isSuccess ? (results[0].value as Map<String, dynamic>) : null;
            final bestDayData = results[1].isSuccess ? results[1].value as Map<String, dynamic>? : null;
            final palletSourceData = results[2].isSuccess ? (results[2].value as List) : null;
            
            final facts = <Widget>[];
            
            // Fact 1: Items Sold
            if (financialData != null && financialData['sold_count'] != null) {
              final soldCount = financialData['sold_count'] as int;
              if (soldCount > 0) {
                facts.add(_buildFunFactCard(
                  context,
                  Icons.celebration,
                  'You\'ve sold $soldCount items in this period!',
                  Colors.green,
                ));
              }
            }
            
            // Fact 2: Best Day
            if (bestDayData != null && bestDayData['date'] != null) {
              final date = DateTime.parse(bestDayData['date'] as String);
              final profit = (bestDayData['profit'] as num).toDouble();
              facts.add(_buildFunFactCard(
                context,
                Icons.calendar_today,
                'Your best day was ${DateFormat('MMM d').format(date)} with \$${profit.toStringAsFixed(2)} profit!',
                Colors.amber,
              ));
            }
            
            // Fact 3: Average Profit Margin
            if (financialData != null && financialData['avg_margin'] != null) {
              final margin = (financialData['avg_margin'] as num).toDouble();
              if (margin > 0) {
                facts.add(_buildFunFactCard(
                  context,
                  Icons.insights,
                  'Your average profit margin is ${margin.toStringAsFixed(1)}% per item',
                  Colors.purple,
                ));
              }
            }
            
            // Fact 4: Most Profitable Pallet Source
            if (palletSourceData != null && palletSourceData.isNotEmpty) {
              final topSource = palletSourceData.first;
              final sourceName = topSource['source'] as String;
              final roi = (topSource['roi'] as num).toDouble();
              facts.add(_buildFunFactCard(
                context,
                Icons.local_shipping,
                'Your most profitable pallet source is $sourceName with ${roi.toStringAsFixed(1)}% ROI!',
                Colors.blue,
              ));
            }
            
            if (facts.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDesignTokens.spacingL),
                  child: EmptyState(
                    icon: Icons.lightbulb_outline,
                    title: 'No Fun Facts Yet',
                    message: 'Keep selling to unlock insights!',
                  ),
                ),
              );
            }
            
            return Column(
              children: facts.expand((fact) => [
                fact,
                const SizedBox(height: AppDesignTokens.spacingS),
              ]).toList()..removeLast(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFunFactCard(
    BuildContext context,
    IconData icon,
    String fact,
    Color color,
  ) {
    return Card(
      elevation: AppDesignTokens.elevation1,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spacingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDesignTokens.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(AppDesignTokens.opacityLight),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: AppDesignTokens.iconM),
            ),
            const SizedBox(width: AppDesignTokens.spacingM),
            Expanded(
              child: Text(
                fact,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Utility widgets
  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: AppDesignTokens.elevation1,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(AppDesignTokens.spacingL),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      elevation: AppDesignTokens.elevation1,
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spacingL),
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Error',
          message: message,
        ),
      ),
    );
  }
}

