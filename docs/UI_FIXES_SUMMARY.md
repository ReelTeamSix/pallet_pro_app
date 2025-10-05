# UI Fixes Summary - Dashboard & Analytics Polish

## Completed Fixes ✅

### 1. Death Pile Alert - Duplicate Warning Icons
**Issue**: The alert had both an emoji warning (⚠️) and an icon warning (▲)  
**Fix**: Removed the emoji, kept only the Material Icon `Icons.warning_amber_rounded`  
**File**: `lib/src/features/dashboard/presentation/screens/dashboard_screen.dart` (line 841)

### 2. Light Mode Contrast - Card Borders
**Issue**: Card borders were too subtle in light mode (0.1 opacity)  
**Fix**: Increased border opacity from `0.1` to `0.2` for better visibility  
**Files**: 
- `lib/src/features/dashboard/presentation/screens/dashboard_screen.dart` (all cards)
- Applied to Quick Actions, Financial Overview, Stats Overview

### 3. Dark Mode Contrast - Analytics Page
**Issue**: Hardcoded `Colors.grey.shade600` didn't adapt to dark mode  
**Fix**: Changed to theme-aware `Theme.of(context).colorScheme.onSurface.withOpacity(0.6)`  
**File**: `lib/src/features/analytics/presentation/screens/reports_screen.dart` (line 315)  
**Bonus**: Added card borders to metric cards for consistency

### 4. Stale Items Navigation
**Issue**: Clicking "Death Pile Alert" showed ALL inventory, not just stale items  
**Fix**: Updated navigation to pass a filter parameter: `context.go('/home/inventory?filter=stale')`  
**File**: `lib/src/features/dashboard/presentation/screens/dashboard_screen.dart` (line 808)

---

## Pending Fixes 🔧

### 5. Inventory List Screen - Stale Items Filter (PRIORITY)
**What's Needed**: The inventory list screen needs to:
1. Read the `filter` query parameter from the route
2. When `filter=stale`, call `getStaleItems()` instead of `getAllItems()`
3. Show a chip/banner indicating "Showing Stale Items Only" with a clear filter button
4. Apply design system styling (cards, borders, consistent spacing)

**Implementation**:
```dart
// In InventoryListScreen
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Read query parameter
  final filterParam = GoRouterState.of(context).uri.queryParameters['filter'];
  final isStaleFilter = filterParam == 'stale';
  
  // Choose provider based on filter
  final itemsAsync = isStaleFilter 
    ? ref.watch(staleItemsProvider) 
    : ref.watch(itemListProvider);
  
  // Show filter banner if active
  if (isStaleFilter) {
    return Column(
      children: [
        // Stale Items Banner
        Container(
          color: AppDesignTokens.warning.withOpacity(0.1),
          padding: EdgeInsets.all(AppDesignTokens.spacingM),
          child: Row(
            children: [
              Icon(Icons.filter_list, color: AppDesignTokens.warning),
              SizedBox(width: AppDesignTokens.spacingS),
              Expanded(
                child: Text('Showing stale items only'),
              ),
              TextButton(
                onPressed: () => context.go('/home/inventory'),
                child: Text('Clear Filter'),
              ),
            ],
          ),
        ),
        // Rest of the list...
      ],
    );
  }
}
```

**New Provider Needed**:
```dart
// lib/src/features/inventory/presentation/providers/stale_items_provider.dart
final staleItemsProvider = FutureProvider<List<Item>>((ref) async {
  final repository = ref.read(itemRepositoryProvider);
  final settings = await ref.watch(userSettingsControllerProvider.future);
  
  if (settings == null) return [];
  
  final threshold = Duration(days: settings.staleThresholdDays);
  final result = await repository.getStaleItems(staleThreshold: threshold);
  
  return result.when(
    success: (items) => items,
    failure: (_) => [],
  );
});
```

### 6. Remove Back Arrow from Inventory Screen
**Issue**: The inventory screen has a back arrow that breaks navigation consistency  
**What's Needed**: Remove the leading back button from the app bar  
**File**: `lib/src/features/inventory/presentation/screens/inventory_list_screen.dart`

Look for:
```dart
AppBar(
  leading: BackButton(...), // REMOVE THIS
  title: Text('Inventory'),
)
```

Change to:
```dart
AppBar(
  automaticallyImplyLeading: false, // Prevents automatic back button
  title: Text('Inventory'),
)
```

### 7. Redesign Pallet/Item List Screens
**Issue**: Current design doesn't match the modern dashboard aesthetic  
**What's Needed**:
1. **Remove old status chips** - replace with modern `StatusBadge` from design_system.dart
2. **Update card styling**:
   - Add card borders: `Theme.of(context).colorScheme.outline.withOpacity(0.2)`
   - Use design system spacing: `AppDesignTokens.spacingM`, `AppDesignTokens.spacingL`
   - Use design system radius: `AppDesignTokens.radiusM`, `AppDesignTokens.radiusL`
3. **Remove hardcoded colors** - use theme colors and design tokens
4. **Consistent elevation**: Use `AppDesignTokens.elevation2` for cards
5. **Icon sizes**: Use `AppDesignTokens.iconM`, `AppDesignTokens.iconL`

**Files to Update**:
- `lib/src/features/inventory/presentation/screens/inventory_list_screen.dart`
- `lib/src/features/inventory/presentation/screens/pallet_list_screen.dart` (already updated, but may need filter support)
- `lib/src/global/widgets/inventory_item_card.dart` (if exists)

---

## Testing Checklist 🧪

- [ ] Light mode: All cards have visible borders
- [ ] Dark mode: All text is readable, no washed-out colors
- [ ] Death Pile Alert shows single warning icon
- [ ] Clicking Death Pile Alert shows ONLY stale items
- [ ] Filter banner appears when viewing stale items
- [ ] "Clear Filter" button returns to full inventory
- [ ] No back arrow on inventory screen
- [ ] Navigation flows correctly between Dashboard → Inventory → Item Detail
- [ ] All screens match design system aesthetics

---

## Design System Compliance ✨

All fixes follow these principles:
- ✅ Use `AppDesignTokens` for all spacing, sizing, colors
- ✅ Theme-aware colors: `Theme.of(context).colorScheme.*`
- ✅ Consistent card styling with borders
- ✅ No hardcoded values
- ✅ DRY code - reuse widgets from design_system.dart
- ✅ Mobile-first responsive design

