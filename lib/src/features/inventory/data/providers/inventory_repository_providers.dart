import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/global/providers/supabase_provider.dart'; // Import the new client provider

// Import Interfaces
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/storage_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/tag_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/expense_repository.dart';

// Import Implementations
import 'package:pallet_pro_app/src/features/inventory/data/repositories/supabase_pallet_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/supabase_item_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/supabase_storage_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/supabase_tag_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/supabase_expense_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/services/item_status_manager.dart';
import 'package:pallet_pro_app/src/features/inventory/data/services/pallet_status_manager.dart';
import 'package:pallet_pro_app/src/features/settings/data/providers/user_settings_repository_provider.dart';


// --- Inventory Repository Providers ---

// Item repository is defined first since Pallet repository depends on it
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseItemRepository(client);
});

final palletRepositoryProvider = Provider<PalletRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final itemRepository = ref.watch(itemRepositoryProvider);
  return SupabasePalletRepository(client, itemRepository);
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseStorageRepository(client);
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseTagRepository(client);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseExpenseRepository(client);
});

/// Provider for the ItemStatusManager service.
/// This centralizes all item status transition logic to follow DRY principle.
final itemStatusManagerProvider = Provider<ItemStatusManager>((ref) {
  final itemRepository = ref.watch(itemRepositoryProvider);
  return ItemStatusManager(itemRepository);
});

/// Provider for the PalletStatusManager service.
/// This centralizes all pallet status transition logic to follow DRY principle.
final palletStatusManagerProvider = Provider<PalletStatusManager>((ref) {
  final palletRepository = ref.watch(palletRepositoryProvider);
  final userSettingsRepository = ref.watch(userSettingsRepositoryProvider);
  return PalletStatusManager(palletRepository, userSettingsRepository);
}); 