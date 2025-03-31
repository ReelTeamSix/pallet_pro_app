import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../utils/constants/supabase_constants.dart';
import '../../domain/models/pallet.dart'; // Corrected import path
import 'pallet_repository.dart';

/// Supabase implementation for managing Pallet data.
class SupabasePalletRepositoryImpl implements PalletRepository {
  final SupabaseClient _supabaseClient;

  SupabasePalletRepositoryImpl(this._supabaseClient);

  String get _tableName => SupabaseConstants.palletsTable;

  @override
  Stream<List<Pallet>> watchPallets(String userId) {
    // Use .stream() for real-time updates
    // Filter by user_id
    // Order by creation date (most recent first)
    return _supabaseClient
        .from(_tableName)
        .stream(primaryKey: ['id']) // Specify primary key for stream stability
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((list) => list.map((data) => Pallet.fromJson(data)).toList());
  }

  @override
  Future<Pallet?> fetchPalletById(String palletId) async {
    try {
      final data = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', palletId)
          .maybeSingle(); // Use maybeSingle to handle not found case gracefully

      if (data == null) {
        return null;
      }
      return Pallet.fromJson(data);
    } catch (e) {
      // Consider logging the error
      print('Error fetching pallet by ID: $palletId - $e');
      rethrow; // Re-throw to allow higher layers to handle
    }
  }

  @override
  Future<void> addPallet(Pallet pallet) async {
    try {
      // Convert Pallet object to JSON, Supabase handles DateTime conversion
      await _supabaseClient.from(_tableName).insert(pallet.toJson());
    } catch (e) {
      // Consider logging the error
      print('Error adding pallet: ${pallet.id} - $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePallet(Pallet pallet) async {
    try {
      // Update where id matches
      await _supabaseClient
          .from(_tableName)
          .update(pallet.toJson()) // Pass the whole object (Supabase ignores pk)
          .eq('id', pallet.id);
    } catch (e) {
      // Consider logging the error
      print('Error updating pallet: ${pallet.id} - $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePallet(String palletId) async {
    try {
      await _supabaseClient.from(_tableName).delete().eq('id', palletId);
    } catch (e) {
      // Consider logging the error
      print('Error deleting pallet: $palletId - $e');
      rethrow;
    }
  }
} 