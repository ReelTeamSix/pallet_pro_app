# Pallet Pro: Developer Notes & Context

## Project Concept

Pallet Pro is designed as a specialized mobile and web application for resellers who primarily source their inventory from pallets (such as liquidation, returns, or overstock).

**Core Purpose:** To help resellers move beyond spreadsheets or manual tracking by providing a dedicated digital tool to:

*   **Organize Inventory:** Easily log purchased pallets (cost, type, supplier, date) and their individual items (quantity, condition, photos, etc.).
*   **Track Profitability:** Automatically calculate profit/loss for items and pallets by tracking sales prices against costs and expenses.
*   **Provide Business Insights:** Offer dashboards and analytics showing financial health, ROI, pallet profitability, and stale inventory identification.

Essentially, Pallet Pro aims to give resellers clear visibility into their inventory and finances, helping them optimize costs, maximize profits, and make smarter sourcing decisions.

**Current State:** The codebase represents an early Minimum Viable Product (MVP) stage. The goal is to build a solid foundation for future expansion based on this core concept.

## Technical Notes & Conventions

This section outlines key architectural decisions, conventions, and potential gotchas discovered during the initial MVP development, particularly related to authentication, user settings, and routing.

## Inventory Feature - Data Layer

*   **`Pallet` Model:**
    *   Defined in `lib/src/features/inventory/data/models/pallet.dart` using `@freezed` for immutability and code generation.
    *   Includes fields like `id`, `user_id`, `name`, `supplier`, `type`, and `created_at`.
    *   Uses `@JsonKey` annotations to map Dart field names (e.g., `userId`, `createdAt`) to database column names (e.g., `user_id`, `created_at`).
*   **`PalletRepository` Interface:**
    *   Defined in `lib/src/features/inventory/data/repositories/pallet_repository.dart`.
    *   Provides an abstract contract for CRUD operations (watch, fetchById, add, update, delete) on Pallet data.
    *   This separation allows for different implementations (e.g., Supabase, local mock) without changing the components that use the repository.

## User Settings & Database Interaction

1.  **`user_settings` Table Schema Convention:**
    *   The Supabase `user_settings` table uses its `id` column (UUID type) as **both** the primary key for the settings record *and* the foreign key referencing the `auth.users(id)` column.
    *   There is **no separate `user_id` column** in this table.

2.  **`SupabaseUserSettingsRepository` Implementation (`user_settings_repository_impl.dart`):**
    *   This repository implementation has been specifically modified to query the `user_settings` table using `.eq('id', _userId)` for all operations (fetch, update, etc.) to match the schema convention where `id` acts as the foreign key.
    *   **Important:** Future modifications or troubleshooting related to this repository *must* use `id` for user-based filtering, not `user_id`.

3.  **Row Level Security (RLS):**
    *   RLS policies for the `user_settings` table must also align with the schema. Policies should use `auth.uid() = id` (comparing the authenticated user's ID to the table's `id` column) for access control.

## Providers & State Management (Riverpod)

4.  **Repository Provider Dependencies (`userSettingsRepositoryProvider`):**
    *   This provider depends on the user's authentication state (`authUserStreamProvider`). It can only successfully instantiate the `SupabaseUserSettingsRepository` *after* a user is properly authenticated and their ID is available.
    *   Attempting to `ref.read(userSettingsRepositoryProvider)` before the auth state is ready can throw an exception.

5.  **`UserSettingsController` Error Handling:**
    *   The controller's `build` method wraps the initial repository read (`ref.read(userSettingsRepositoryProvider)`) in a `try-catch`. If the repository cannot be created immediately (due to auth timing), the controller provider enters an error state.
    *   The `refreshSettings` method *also* attempts to read the repository provider at its start, making it resilient even if the initial `build` failed to initialize the repository instance.

6.  **Riverpod Code Generation (`@riverpod`) Requirements & Troubleshooting:**
    *   Using the `@riverpod` annotation requires specific packages:
        *   `riverpod_annotation` in `dependencies`.
        *   `riverpod_generator` in `dev_dependencies`.
    *   **Gotcha:** Missing these packages will cause `flutter pub run build_runner build` to fail with errors like `Could not resolve annotation for ... (InvalidType ref)`. Ensure both packages are present in `pubspec.yaml` with compatible versions.
    *   **Provider Locations:** Core providers used across features might be located in different feature directories. As of this writing:
        *   `authStateChangesProvider` is in `lib/src/features/auth/presentation/providers/auth_controller.dart`.
        *   `supabaseClientProvider` is in `lib/src/features/settings/data/repositories/user_settings_providers.dart`.

## Routing (`RouterNotifier` & GoRouter)

7.  **Routing Logic Dependencies:**
    *   The `RouterNotifier`'s redirection logic heavily depends on the state of `userSettingsControllerProvider`.
    *   An `AsyncError` state in `userSettingsControllerProvider` (whether from failed repository initialization or failed settings fetch after login) will trigger a redirect back to `/login?from=settings_error`. This is the expected behavior if settings cannot be loaded. 