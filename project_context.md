# Pallet Pro App - Project Context and Structure

## Application Overview
Pallet Pro is an inventory management application designed for resellers who purchase pallets of merchandise and need to track items, costs, sales, and profitability. The app allows users to:

1. Track pallets from purchase through processing and archiving
2. Track individual items within pallets through their lifecycle (in stock, listed, sold)
3. Allocate pallet costs to items
4. Monitor profitability

## Architecture

The application follows a clean architecture approach with the following high-level structure:

```
lib/
├── main.dart
└── src/
    ├── app.dart
    ├── core/
    │   ├── exceptions/
    │   └── utils/
    ├── features/
    │   ├── auth/
    │   ├── inventory/
    │   ├── reporting/
    │   └── settings/
    ├── global/
    └── routing/
```

### Key Design Patterns
- **Riverpod** for state management
- **Provider** pattern for dependency injection
- **Repository** pattern for data access
- **Notifier** pattern for state handling
- **Service** pattern for business logic

## Recent Enhancements - KISS/DRY Improvements

### 1. Centralized Status Management
We've extracted duplicate status transition logic into dedicated service classes:

- `ItemStatusManager`: Centralizes all item status transitions (in_stock → listed → sold)
- `PalletStatusManager`: Centralizes all pallet status transitions (in_progress → processed → archived)

This eliminates code duplication between list and detail notifiers, following the DRY principle.

### 2. Unified Extension Methods
Fixed duplicate extension methods in `ItemDetailProviderExtension` by merging them into a single extension with multiple properties.

### 3. Provider Structure
Introduced providers for the new services:
- `itemStatusManagerProvider`
- `palletStatusManagerProvider`

### 4. Consistent Error Handling
Standardized error handling across the application with consistent use of the Result type.

## Current File Structure

### Core Services and Models
- `ItemStatusManager` - Manages item status transitions
- `PalletStatusManager` - Manages pallet status transitions

### Providers
- `ItemDetailNotifier` - Manages single item state
- `ItemListNotifier` - Manages multiple items state
- `PalletDetailNotifier` - Manages single pallet state
- `PalletListNotifier` - Manages multiple pallets state

### Models
- `Item` - Freezed model for item data
- `Pallet` - Freezed model for pallet data
- `SimpleItem` - Lightweight model for UI
- `SimplePallet` - Lightweight model for UI

### Mock Implementations
For testing and UI development:
- `MockItemDetailNotifier`
- Mock providers with extension methods to easily transition between mock and real implementations

## Workflow
1. User creates pallets with cost information
2. Items are added to pallets
3. Pallet is processed - costs allocated to items
4. Items are listed for sale
5. Items are marked as sold
6. Profitability reports are generated

## Best Practices Enforced
- **DRY (Don't Repeat Yourself)**: Centralized business logic in service classes
- **KISS (Keep It Simple, Stupid)**: Clear, focused classes with single responsibilities
- **Separation of Concerns**: UI, business logic, and data access are cleanly separated

## Recent Bug Fixes and Improvements

### Type-Safety and Enum Handling
- Added `forSale` value to `ItemStatus` enum to handle string values consistently
- Fixed enum usage by replacing string-based comparisons with proper enum comparisons
- Added helper methods to convert enum values to strings when needed for UI formatting

### Extension and Provider Conflicts
- Renamed conflicting extensions to avoid ambiguity
- Fixed provider type mismatches to ensure consistent access patterns
- Standardized extension methods across files for consistency and developer experience

### Exception Handling
- Standardized on `AppException` for error handling
- Ensured consistent Result type usage across the codebase
- Fixed error handling in repository methods

These improvements ensure type safety and maintainability while preserving the clean architecture approach of the application. 