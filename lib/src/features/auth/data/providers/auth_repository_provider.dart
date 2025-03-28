import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:pallet_pro_app/src/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabaseAuthRepository(client: client);
});
