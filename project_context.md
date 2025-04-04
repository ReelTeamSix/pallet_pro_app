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
    │   ├── theme/
    │   └── utils/
    ├── features/
    │   ├── auth/
    │   ├── inventory/
    │   │   ├── data/
    │   │   │   ├── models/
    │   │   │   └── repositories/
    │   │   ├── domain/
    │   │   │   └── entities/
    │   │   └── presentation/
    │   │       ├── providers/
    │   │       ├── screens/
    │   │       └── widgets/
    │   ├── reporting/
    │   └── settings/
    ├── global/
    │   └── widgets/
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

### 5. Responsive Navigation
Implemented platform-adaptive navigation:

- **Web/Desktop**: Uses a collapsible drawer for primary navigation without a bottom bar. Settings access is located in the drawer for a cleaner interface.
- **Mobile**: Uses a bottom navigation bar with Dashboard, Inventory, Reports, and Settings tabs. No drawer is shown on mobile to maximize screen space.

This improves user experience by following platform conventions:
- Web users expect side navigation via drawer
- Mobile users expect bottom tab navigation for all main sections

The implementation follows KISS/DRY principles by:
- Using a single responsive component (`ScaffoldWithNavBar`)
- Conditionally rendering UI elements based on screen size
- Centralizing navigation logic in one place
- Using the `ResponsiveUtils` utility class for consistent responsive behavior

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
- **Platform-Adaptive Design**: UI adapts to different platforms and screen sizes

## Recent Bug Fixes and Improvements

### Image Upload and Storage
- Added `ItemPhotoRepository` interface and `SupabaseItemPhotoRepository` implementation to properly handle image metadata
- Fixed the image upload flow to ensure image references are saved to the database
- Added functionality to generate proper public URLs for accessing images
- Implemented automatic bucket creation to ensure storage is properly set up
- Enhanced error handling and logging for image uploads
- Fixed relationship between storage path and image URL in the database

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

### Navigation and Responsiveness
- Implemented platform-specific navigation patterns
- Improved responsiveness for different screen sizes and orientations
- Added dynamic layout switching based on device type (mobile/tablet/desktop)

These improvements ensure type safety and maintainability while preserving the clean architecture approach of the application.

## Data Model Updates (April 2024)

### Pallet Models and Item Relationship

The application has been updated to enforce a more structured relationship between pallets and items:

* **Removal of Standalone Items**: Previously, the application had a concept of "standalone items" that were not associated with any pallet, using a special placeholder pallet ID (`NO_PALLET_UUID`). This functionality has been removed to better align with the core business workflow, where all items are sourced from pallets.

* **Required Pallet Association**: All inventory items must now be associated with a valid pallet. This change improves data consistency and simplifies inventory management.

* **Model Updates**:
  * The `Pallet` model now uses a standardized enum for status values:
    * `inProgress` - Default for new pallets, indicates inventory processing is ongoing
    * `processed` - Indicates pallet inventory is complete and cost allocation is finalized
    * `archived` - For pallets that are no longer active in inventory
  
  * The `Item` model requires a valid `palletId` for all items, with other fields like:
    * Purchase price - Can be auto-calculated based on pallet cost
    * Condition - Using standardized enum values
    * Status - Tracking item through the inventory lifecycle

* **Simplification**:
  * Added a `SimplePallet` helper class to facilitate UI operations and data transformation
  * Implemented better filtering system with dedicated `Filter` enum
  * Standardized date formatting and currency handling through utility functions

These changes support a more accurate representation of the pallet-based inventory business model, where all items originate from wholesale pallets rather than individual acquisitions.

### Technical Improvements

* **Widget Reusability**: Created reusable components for common patterns:
  * `ImagePickerGrid` - Standardized image selection and management
  * `SalesChannelDropdown` - Consistent sales channel selection across the app
  * `InventoryItemCard` - Reusable card for displaying inventory items
  * `PalletCard` - Reusable card for displaying pallets
  * `StatusChip` - Centralized status display with consistent styling
  
* **Display Utilities**: Added formatting helpers for:
  * Currency display with proper symbols
  * Date formatting
  * Profit calculations with visual indicators
  * Status formatting with `StringFormatter` utility
  * Status colors with `StatusColors` utility class
  
* **Repository Pattern Refinement**:
  * Updated repository interfaces to ensure consistency
  * Better alignment between database schema and application models
  * Improved error handling and type safety

These updates strengthen the application's foundation, making it more reliable, maintainable, and aligned with the actual business workflow of pallet-based inventory management. 