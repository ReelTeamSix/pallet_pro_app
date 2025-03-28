import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/supabase_user_settings_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the [UserSettingsRepository].
final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabaseUserSettingsRepository(client: client);
});
