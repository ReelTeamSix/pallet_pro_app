import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/tag.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/tag_repository_impl.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/repositories/tag_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_providers.dart'; // To access supabaseClientProvider and userIdProvider

/// Provider for the TagRepository implementation.
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(userIdProvider);
  return SupabaseTagRepository(client, userId);
});

/// FutureProvider to fetch the list of tags for the current user.
/// Handles loading and error states automatically.
final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  final repository = ref.watch(tagRepositoryProvider);
  try {
    return await repository.fetchTags();
  } catch (e) {
    print('Error fetching tags via provider: $e');
    // Consider how to handle errors in the UI. Returning empty list or rethrowing?
    // For now, rethrow to let the UI decide.
    rethrow;
  }
}); 