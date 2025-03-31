import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_photo_repository_impl.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/repositories/item_photo_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_providers.dart'; // Access common providers

/// Provider for the ItemPhotoRepository implementation.
final itemPhotoRepositoryProvider = Provider<ItemPhotoRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(userIdProvider);
  return SupabaseItemPhotoRepository(client, userId);
});

/// Family FutureProvider to fetch photo metadata for a specific item.
final photosByItemProvider = FutureProvider.family<List<ItemPhoto>, int>((ref, itemId) async {
  final repository = ref.watch(itemPhotoRepositoryProvider);
  try {
    return await repository.fetchPhotosForItem(itemId);
  } catch (e) {
     print('Error fetching photos for item $itemId via provider: $e');
     rethrow;
  }
});

// As before, add/delete actions are usually called directly from state management logic,
// followed by invalidating the `photosByItemProvider` for the relevant item ID. 