# Sprint 1: Analytics & Dashboard Enhancement Implementation

**Start Date**: [Current]  
**Goal**: Implement comprehensive analytics system with mobile-first focus, cost-effective design, and clear premium tier preparation  
**Reference**: feature_enhancement_plan.md, plan.md (Phase 6), phase_5_subplan.md

---

## ✅ Pre-Implementation Checklist

- [x] All compilation errors resolved
- [x] Feature enhancement plan approved
- [x] Design principles understood:
  - Mobile-first
  - Cost-effective (minimize queries, use aggregations)
  - Free tier: 30-90 days lookback
  - Premium tier: Unlimited time resolution + advanced features
- [x] User requirements confirmed:
  - Analytics: More is better (use best judgment)
  - Stale threshold: Already in settings (review placement)
  - No database migrations (stay in free tier)
  - Charts: Sleek and elegant (research best practices)
  - Payment processing: Features first, infrastructure later

---

## 📋 Implementation Plan Overview

### Phase 1A: Data Layer - Analytics Provider
**Estimated Time**: 2-3 hours  
**Status**: 🔄 Not Started

- [ ] Create `AnalyticsData` model (freezed)
- [ ] Create `AnalyticsProvider` for data aggregation
- [ ] Add efficient query methods to repositories
- [ ] Implement time-based filtering utilities
- [ ] Add stale inventory detection logic

### Phase 1B: Dashboard Financial Cards
**Estimated Time**: 2-3 hours  
**Status**: 🔄 Not Started

- [ ] Update dashboard with financial overview
- [ ] Add quick stats grid
- [ ] Implement stale inventory alert card
- [ ] Add recent activity feed
- [ ] Optimize for mobile layout

### Phase 1C: Analytics Screen
**Estimated Time**: 3-4 hours  
**Status**: 🔄 Not Started

- [ ] Create AnalyticsScreen with time period selector
- [ ] Implement revenue vs cost visualization
- [ ] Add profit/loss trend charts
- [ ] Create top performers section
- [ ] Add fun facts section

### Phase 1D: Storage Location & Sales Channel
**Estimated Time**: 2-3 hours  
**Status**: 🔄 Not Started

- [ ] Add storage_location field (no migration, use existing schema)
- [ ] Add listing_url field
- [ ] Update AddEditItemScreen
- [ ] Add location-based filtering
- [ ] Enhance sales channel tracking

---

## 🎯 Current Sprint Goals (Week 1)

### Must Have (Priority 1) ✅
1. **Analytics Provider** - Data aggregation foundation
2. **Dashboard Enhancement** - Financial overview cards
3. **Basic Analytics Screen** - Time filters + key metrics
4. **Fun Facts** - Engagement and delight

### Should Have (Priority 2) ⭐
1. **Stale Inventory Alerts** - Visual indicators
2. **Storage Location** - Field addition
3. **Sales Channel Enhancement** - URL tracking
4. **Top Performers** - Best items/pallets

### Nice to Have (Priority 3) 🌟
1. **Chart Animations** - Smooth transitions
2. **Export Prep** - Data structure ready
3. **Filter Presets** - Foundation for premium

---

## 📊 Detailed Implementation Steps

### Step 1: Create Analytics Data Model
**File**: `lib/src/features/analytics/data/models/analytics_data.dart`

**Requirements**:
```dart
@freezed
class AnalyticsData with _$AnalyticsData {
  const factory AnalyticsData({
    // Financial Metrics
    required double totalInventoryValue,    // Sum of all item purchase prices (in stock)
    required double totalPotentialRevenue,  // Sum of all listing prices
    required double totalActualRevenue,     // Sum of all selling prices
    required double netProfit,              // actualRevenue - costs
    
    // Item Counts
    required int itemsInStock,
    required int itemsListed,
    required int itemsSold,
    required int staleItemsCount,
    
    // Averages
    required double averageProfitMargin,    // Percentage
    required double averageProfitPerItem,   // Dollar amount
    required double averageTimeToSell,      // Days
    
    // Top Performers (Separate models)
    required BestItem? bestSellingItem,
    required BestItem? highestProfitItem,
    required BestItem? fastestSellingItem,
    
    // Pallet Insights
    required String? mostProfitablePalletSource,
    required double mostProfitablePalletROI,
    
    // Fun Facts
    required DateTime? bestDay,
    required double bestDayProfit,
    required int totalItemsProcessed,
    required int daysTracking,
  }) = _AnalyticsData;
}

@freezed
class BestItem with _$BestItem {
  const factory BestItem({
    required String id,
    required String name,
    required double value,
    required String metric, // 'revenue', 'profit', 'speed'
  }) = _BestItem;
}

@freezed  
class TimeSeriesData with _$TimeSeriesData {
  const factory TimeSeriesData({
    required DateTime date,
    required double revenue,
    required double cost,
    required double profit,
  }) = _TimeSeriesData;
}
```

**Tasks**:
- [ ] Create model files
- [ ] Run build_runner
- [ ] Add JSON serialization if needed for caching

---

### Step 2: Create Analytics Repository Methods
**File**: `lib/src/features/inventory/data/repositories/item_repository.dart` (extend existing)

**New Methods Needed**:
```dart
abstract class ItemRepository {
  // Existing methods...
  
  // Analytics queries (optimized for performance)
  Future<Result<Map<String, dynamic>>> getFinancialSummary({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Result<List<TimeSeriesData>>> getTimeSeries({
    required String userId,
    required String resolution, // 'day', 'week', 'month'
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Result<List<Item>>> getStaleItems({
    required String userId,
    required int thresholdDays,
  });
  
  Future<Result<Map<String, dynamic>>> getPalletSourcePerformance({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Result<Item?>> getBestPerformer({
    required String userId,
    required String metric, // 'profit', 'revenue', 'speed'
    DateTime? startDate,
    DateTime? endDate,
  });
}
```

**Implementation Strategy**:
```sql
-- Efficient query example for financial summary
SELECT 
  -- In Stock
  SUM(CASE WHEN status = 'in_stock' THEN purchase_price ELSE 0 END) as inventory_value,
  COUNT(CASE WHEN status = 'in_stock' THEN 1 END) as in_stock_count,
  
  -- Listed  
  SUM(CASE WHEN status = 'listed' THEN listing_price ELSE 0 END) as potential_revenue,
  COUNT(CASE WHEN status = 'listed' THEN 1 END) as listed_count,
  
  -- Sold
  SUM(CASE WHEN status = 'sold' THEN selling_price ELSE 0 END) as actual_revenue,
  SUM(CASE WHEN status = 'sold' THEN (selling_price - purchase_price) ELSE 0 END) as total_profit,
  COUNT(CASE WHEN status = 'sold' THEN 1 END) as sold_count,
  AVG(CASE WHEN status = 'sold' THEN (selling_price - purchase_price) ELSE NULL END) as avg_profit
FROM items
WHERE user_id = $1
  AND ($2::timestamp IS NULL OR created_at >= $2)
  AND ($3::timestamp IS NULL OR created_at <= $3);
```

**Tasks**:
- [ ] Add methods to abstract interface
- [ ] Implement in SupabaseItemRepository
- [ ] Add error handling
- [ ] Write unit tests
- [ ] Document query performance expectations

---

### Step 3: Create Analytics Provider
**File**: `lib/src/features/analytics/presentation/providers/analytics_provider.dart`

**Structure**:
```dart
@riverpod
class AnalyticsNotifier extends _$AnalyticsNotifier {
  @override
  Future<AnalyticsData> build({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = ref.watch(authControllerProvider).value?.id;
    if (userId == null) throw Exception('Not authenticated');
    
    // Fetch all required data in parallel
    final results = await Future.wait([
      ref.read(itemRepositoryProvider).getFinancialSummary(...),
      ref.read(itemRepositoryProvider).getStaleItems(...),
      ref.read(itemRepositoryProvider).getPalletSourcePerformance(...),
      // ... other queries
    ]);
    
    // Aggregate and return
    return _buildAnalyticsData(results);
  }
  
  // Helper methods
  Future<void> refreshAnalytics() async {
    ref.invalidateSelf();
  }
}

// Time period helper
enum TimePeriod {
  last7Days,
  last30Days,
  last90Days,
  allTime,
  custom;
  
  DateTimeRange toDateRange() {
    final now = DateTime.now();
    switch (this) {
      case TimePeriod.last7Days:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      // ... other cases
    }
  }
}
```

**Tasks**:
- [ ] Create provider structure
- [ ] Implement parallel data fetching
- [ ] Add caching strategy (5-10 min refresh)
- [ ] Handle errors gracefully
- [ ] Add loading states
- [ ] Write unit tests

---

### Step 4: Enhance Dashboard Screen
**File**: `lib/src/features/dashboard/presentation/screens/dashboard_screen.dart` (update existing)

**New Widgets to Add**:

1. **Financial Overview Card**:
```dart
Widget _buildFinancialOverviewCard(BuildContext context, AnalyticsData data) {
  return Card(
    elevation: AppDesignTokens.elevation2,
    child: Padding(
      padding: const EdgeInsets.all(AppDesignTokens.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppDesignTokens.success),
              const SizedBox(width: 8),
              Text('Financial Overview', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            ],
          ),
          const SizedBox(height: AppDesignTokens.spacingM),
          _buildFinancialRow('Inventory Value', data.totalInventoryValue, Colors.blue),
          _buildFinancialRow('Potential Revenue', data.totalPotentialRevenue, Colors.orange),
          _buildFinancialRow('Actual Revenue', data.totalActualRevenue, Colors.green),
          const Divider(),
          _buildFinancialRow('Net Profit', data.netProfit, 
            data.netProfit >= 0 ? Colors.green : Colors.red,
            isLarge: true,
          ),
        ],
      ),
    ),
  );
}
```

2. **Stale Inventory Alert**:
```dart
Widget _buildStaleInventoryAlert(BuildContext context, int count) {
  if (count == 0) return const SizedBox.shrink();
  
  return Card(
    color: AppDesignTokens.warning.withOpacity(0.1),
    child: InkWell(
      onTap: () {
        // Navigate to filtered inventory view
        context.go('/inventory?filter=stale');
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spacingM),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: AppDesignTokens.warning, size: 32),
            const SizedBox(width: AppDesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stale Inventory Alert',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('$count items haven\'t sold. Consider price adjustments.'),
                ],
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}
```

**Tasks**:
- [ ] Add AnalyticsProvider watch
- [ ] Implement financial overview card
- [ ] Add stale inventory alert
- [ ] Update quick stats grid with real data
- [ ] Add recent activity feed
- [ ] Handle loading/error states
- [ ] Test responsiveness

---

### Step 5: Create Analytics Screen
**File**: `lib/src/features/analytics/presentation/screens/analytics_screen.dart`

**Screen Structure**:
```dart
class AnalyticsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  TimePeriod _selectedPeriod = TimePeriod.last30Days;
  
  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsNotifierProvider(
      startDate: _selectedPeriod.toDateRange().start,
      endDate: _selectedPeriod.toDateRange().end,
    ));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(analyticsNotifierProvider),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () => const AnalyticsShimmerLoader(),
        error: (error, _) => ErrorWidget(error),
        data: (analytics) => _buildAnalyticsContent(analytics),
      ),
    );
  }
  
  Widget _buildAnalyticsContent(AnalyticsData data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTimePeriodSelector(),
          _buildProfitChart(data),
          _buildTopPerformers(data),
          _buildFunFacts(data),
        ],
      ),
    );
  }
}
```

**Chart Implementation** (using fl_chart):
```dart
Widget _buildProfitChart(AnalyticsData data) {
  // Research: Best practices for mobile charts
  // - Simple, not cluttered
  // - Clear labels
  // - Touch interactions
  // - Smooth animations
  // - Color coding: Green (profit), Red (loss), Blue (revenue)
  
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Revenue vs Cost', style: titleStyle),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                // ... chart configuration
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

**Tasks**:
- [ ] Create screen structure
- [ ] Implement time period selector
- [ ] Add profit chart (LineChart)
- [ ] Create top performers section
- [ ] Add fun facts with icons
- [ ] Implement shimmer loader
- [ ] Add pull-to-refresh
- [ ] Test on mobile devices

---

### Step 6: Add Storage Location & Sales Channel
**File**: `lib/src/features/inventory/presentation/screens/add_edit_item_screen.dart`

**No Database Migration Needed**:
- Check if fields already exist in schema
- If not, add via Supabase UI (preserves free tier)
- Update models to include optional fields

**UI Changes**:
```dart
// Add to form
StyledTextField(
  controller: _storageLocationController,
  label: 'Storage Location',
  hint: 'e.g., Garage Shelf 2, Bin 3',
  icon: Icons.location_on,
  suggestions: _recentLocations, // From recent entries
),

StyledTextField(
  controller: _listingUrlController,
  label: 'Listing URL (Optional)',
  hint: 'Facebook Marketplace or eBay link',
  icon: Icons.link,
  keyboardType: TextInputType.url,
),
```

**Tasks**:
- [ ] Verify schema has fields
- [ ] Update Item model
- [ ] Add fields to AddEditItemScreen
- [ ] Implement location suggestions
- [ ] Add location filter to inventory list
- [ ] Test data persistence

---

## 🔍 Testing Checklist

### Unit Tests
- [ ] AnalyticsData model serialization
- [ ] Analytics repository methods
- [ ] AnalyticsProvider state management
- [ ] Time period utilities
- [ ] Data aggregation logic

### Widget Tests
- [ ] Financial overview card
- [ ] Stale inventory alert
- [ ] Time period selector
- [ ] Chart widgets
- [ ] Fun facts section

### Integration Tests
- [ ] End-to-end analytics data flow
- [ ] Dashboard refresh
- [ ] Time period switching
- [ ] Navigation to filtered views

### Manual Tests
- [ ] Mobile responsiveness (Android device)
- [ ] Chart touch interactions
- [ ] Loading states
- [ ] Error handling
- [ ] Performance with large datasets

---

## 📈 Success Metrics

### Performance Targets
- [ ] Analytics query < 2 seconds
- [ ] Dashboard load < 1 second (cached)
- [ ] Chart render < 500ms
- [ ] Smooth 60fps animations

### User Experience
- [ ] Clear financial overview at a glance
- [ ] Fun facts are engaging and accurate
- [ ] Charts are easy to understand
- [ ] Navigation is intuitive
- [ ] Actions (refresh, filter) are responsive

---

## 🚀 Next Steps After Sprint 1

1. User feedback collection
2. Performance optimization
3. Premium tier infrastructure
4. Advanced analytics (Sprint 2)
5. Export functionality
6. Batch processing features

---

## 📝 Notes & Decisions Log

**[Date]**: Initial setup
- Decision: Use fl_chart for visualizations (best mobile support)
- Decision: 30-day default for free tier analytics
- Decision: Keep stale threshold in settings
- Decision: No database migration, use existing schema
- Decision: Analytics queries use efficient aggregation

**Chart Library Research**:
- fl_chart: ✅ Best for Flutter, smooth animations, touch support
- syncfusion_flutter_charts: ❌ Paid license required
- charts_flutter: ❌ Deprecated

**Stale Inventory Decision**:
- Keep in Settings for user control
- Add visual indicator to dashboard
- Add filter shortcut in inventory list
- Consider adding quick action to adjust prices

---

## ⚠️ Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Slow analytics queries | High | Use indexed queries, caching, pagination |
| Too many free tier requests | High | Implement aggressive caching, batch queries |
| Complex chart logic | Medium | Use established library, keep simple |
| Stale data confusion | Medium | Clear labeling, refresh indicators |

---

## 🎯 Current Status: MODELS COMPLETE - MOVING TO REPOSITORY

**Completed**:
- ✅ AnalyticsData, BestItem, TimeSeriesData, ChannelPerformance, PalletSourcePerformance models
- ✅ TimePeriod and TimeResolution utilities
- ✅ Build runner generated all freezed/json code successfully
- ✅ Extended ItemRepository interface with 6 new analytics methods
- ✅ Created comprehensive test structure
- ✅ Created CHECKPOINT_1_TESTING.md with full testing guide

**Current Issues**:
- ⚠️ Dart Analyzer showing false errors (caching issue) - models ARE generated correctly
- ✅ Build will fail until we implement methods in SupabaseItemRepository (expected!)

**Next Action**: Implement analytics methods in SupabaseItemRepository

Let's continue! 🚀

