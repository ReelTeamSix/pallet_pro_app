import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
// TODO: Import custom exceptions
// import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

class SupabasePalletRepository implements PalletRepository {
  final SupabaseClient _supabaseClient;
  final String _tableName = 'pallets'; // Assuming table name is 'pallets'

  SupabasePalletRepository(this._supabaseClient);

  String _getCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw AuthException.sessionExpired();
    }
    return user.id;
  }

  @override
  Future<Result<Pallet>> createPallet(Pallet pallet) async {
    try {
      final userId = _getCurrentUserId();
      final palletData = pallet.toJson();
      palletData['user_id'] = userId;
      palletData.remove('id');
      palletData['created_at'] ??= DateTime.now().toIso8601String();
      palletData['updated_at'] ??= DateTime.now().toIso8601String();

      final response = await _supabaseClient
          .from(_tableName)
          .insert(palletData)
          .select()
          .single();

      return Result.success(Pallet.fromJson(response));
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.creationFailed('pallet', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error creating pallet', e));
    }
  }

  @override
  Future<Result<Pallet?>> getPalletById(String id) async {
    try {
      final userId = _getCurrentUserId();
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('user_id', userId) 
          .maybeSingle();

      final pallet = response == null ? null : Pallet.fromJson(response);
      return Result.success(pallet);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('pallet $id', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching pallet', e));
    }
  }

  @override
  Future<Result<List<Pallet>>> getAllPallets({String? sourceFilter}) async {
    try {
      final userId = _getCurrentUserId();
      var query = _supabaseClient
          .from(_tableName)
          .select()
          .eq('user_id', userId);

      // Apply source filter if provided
      if (sourceFilter != null && sourceFilter.isNotEmpty) {
        // Assuming 'source' is the column name in your DB
        // Use 'ilike' for case-insensitive partial matching
        query = query.ilike('source', '%$sourceFilter%');
      }

      final response = await query.order('created_at', ascending: false);

      final pallets = response.map((json) => Pallet.fromJson(json)).toList();
      return Result.success(pallets);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('all pallets', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching all pallets', e));
    }
  }

  @override
  Future<Result<Pallet>> updatePallet(Pallet pallet) async {
    try {
      final userId = _getCurrentUserId();
      final palletData = pallet.toJson();
      palletData.remove('user_id');
      palletData.remove('id');
      palletData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseClient
          .from(_tableName)
          .update(palletData)
          .eq('id', pallet.id)
          .eq('user_id', userId) 
          .select()
          .single();

      return Result.success(Pallet.fromJson(response));
    } on PostgrestException catch (e) {
       return Result.failure(DatabaseException.updateFailed('pallet ${pallet.id}', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error updating pallet', e));
    }
  }

  @override
  Future<Result<void>> deletePallet(String id) async {
    try {
      final userId = _getCurrentUserId();
      await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', userId); 

      return const Result.success(null); // Success for void
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.deletionFailed('pallet $id', e.message));
    } catch (e) {
       return Result.failure(UnexpectedException('Unexpected error deleting pallet', e));
    }
  }

  @override
  Future<Result<List<String>>> getDistinctFieldValues(String field) async {
    try {
      final userId = _getCurrentUserId();
      
      // Fetch distinct non-null values for the specified field
      final response = await _supabaseClient
          .from(_tableName)
          .select(field)
          .eq('user_id', userId)
          .not(field, 'is', null)
          .order(field);
      
      // Extract unique values from the response
      final values = response
          .map((row) => row[field].toString())
          .toSet() // Use Set to ensure uniqueness
          .toList();
      
      return Result.success(values);
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.fetchFailed('distinct $field values', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error fetching distinct $field values', e));
    }
  }
} 