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


// --- Inventory Repository Providers ---

final palletRepositoryProvider = Provider<PalletRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePalletRepository(client);
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseItemRepository(client);
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