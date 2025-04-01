import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider that exposes the global SupabaseClient instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  // Assumes Supabase.initialize() has been called in main.dart
  return Supabase.instance.client;
}); 