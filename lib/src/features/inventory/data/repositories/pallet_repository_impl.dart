import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/domain/repositories/pallet_repository.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

class SupabasePalletRepository implements PalletRepository {
  final SupabaseClient _client;
  final String _userId;

  SupabasePalletRepository(this._client, this._userId);

  String get _tableName => 'pallets';

  @override
  Future<List<Pallet>> fetchPallets() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false); // Example ordering

      return (response as List).map((data) => Pallet.fromJson(data)).toList();
    } on PostgrestException catch (e) {
      print('Error fetching pallets: ${e.message}');
      throw DatabaseException('Failed to fetch pallets: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred fetching pallets: $e');
    }
  }

  @override
  Future<Pallet?> fetchPalletById(int palletId) async {
     try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', palletId)
          .eq('user_id', _userId)
          .maybeSingle(); // Use maybeSingle to handle null if not found

      return response == null ? null : Pallet.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error fetching pallet $palletId: ${e.message}');
      throw DatabaseException('Failed to fetch pallet: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred fetching pallet: $e');
    }
  }

  @override
  Future<Pallet> createPallet(Pallet pallet) async {
    try {
      // Prepare data, ensuring user_id is set and id/created_at are omitted
      final palletData = pallet.toJson()
        ..['user_id'] = _userId
        ..remove('id')
        ..remove('created_at');

      final response = await _client
          .from(_tableName)
          .insert(palletData)
          .select()
          .single();

      return Pallet.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error creating pallet: ${e.message}');
      // Handle potential unique constraint violation (e.g., duplicate name?)
      if (e.code == '23505') { // unique_violation
        // Adapt error message based on what constraint was violated (e.g., name)
        throw ValidationException('A pallet with this identifier might already exist.');
      }
      throw DatabaseException('Failed to create pallet: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred creating pallet: $e');
    }
  }

  @override
  Future<Pallet> updatePallet(Pallet pallet) async {
    try {
      // Prepare data, ensuring user_id and id are not in the update map directly
       final palletData = pallet.toJson()
        ..remove('id')
        ..remove('user_id')
        ..remove('created_at');

      final response = await _client
          .from(_tableName)
          .update(palletData)
          .eq('id', pallet.id)
          .eq('user_id', _userId) // Ensure user owns the pallet
          .select()
          .single();

      return Pallet.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error updating pallet: ${e.message}');
       if (e.code == '23505') { // unique_violation
         throw ValidationException('Cannot update pallet, potential conflict (e.g., name exists).');
       }
       if (e.code == 'PGRST116' || e.details.contains('0 rows')) { // Resource Not Found or no rows updated
           throw NotFoundException('Pallet not found or you do not have permission to update it.');
       }
      throw DatabaseException('Failed to update pallet: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred updating pallet: $e');
    }
  }

  @override
  Future<void> deletePallet(int palletId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', palletId)
          .eq('user_id', _userId); // Ensure user owns the pallet

    } on PostgrestException catch (e) {
      print('Error deleting pallet: ${e.message}');
      // Handle FK constraint violation (e.g., if items still reference this pallet)
      if (e.code == '23503') { // foreign_key_violation
        throw ValidationException('Cannot delete pallet: it still contains items.');
      }
      throw DatabaseException('Failed to delete pallet: ${e.message}');
    } catch (e) {
      throw DatabaseException('An unexpected error occurred deleting pallet: $e');
    }
  }
} 