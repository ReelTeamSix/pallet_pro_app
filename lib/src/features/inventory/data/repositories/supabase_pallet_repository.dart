import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/item_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
// TODO: Import custom exceptions
// import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

class SupabasePalletRepository implements PalletRepository {
  final SupabaseClient _supabaseClient;
  final ItemRepository? _itemRepository; // Optional to maintain backward compatibility
  final String _tableName = 'pallets'; // Assuming table name is 'pallets'

  SupabasePalletRepository(this._supabaseClient, [this._itemRepository]);

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
  Future<Result<List<Pallet>>> getAllPallets({
    String? sourceFilter, 
    PalletStatus? statusFilter,
  }) async {
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

      // Apply status filter if provided
      if (statusFilter != null) {
        String statusValue;
        switch (statusFilter) {
          case PalletStatus.inProgress: statusValue = 'in_progress'; break;
          case PalletStatus.processed: statusValue = 'processed'; break;
          case PalletStatus.archived: statusValue = 'archived'; break;
        }
        query = query.eq('status', statusValue);
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

  @override
  Future<Result<Pallet>> updatePalletStatus({
    required String palletId,
    required PalletStatus newStatus,
    required bool shouldAllocateCosts,
    String? allocationMethod,
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // First get the current pallet to have access to its cost
      final palletResult = await getPalletById(palletId);
      if (palletResult.isFailure) {
        return Result.failure(palletResult.error!);
      }
      
      final pallet = palletResult.value;
      if (pallet == null) {
        return Result.failure(NotFoundException('Pallet with ID $palletId not found'));
      }
      
      // Convert status enum to string for database
      String statusValue;
      switch (newStatus) {
        case PalletStatus.inProgress: statusValue = 'in_progress'; break;
        case PalletStatus.processed: statusValue = 'processed'; break;
        case PalletStatus.archived: statusValue = 'archived'; break;
      }
      
      // Prepare update data
      final updateData = {
        'status': statusValue,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Update the pallet status
      final response = await _supabaseClient
          .from(_tableName)
          .update(updateData)
          .eq('id', palletId)
          .eq('user_id', userId)
          .select()
          .single();
      
      // If we're marking it as processed and should allocate costs
      if (newStatus == PalletStatus.processed && shouldAllocateCosts) {
        // Get the pallet cost
        final double palletCost = pallet.cost;
        
        // Use default allocation method if not provided
        final costAllocationMethod = allocationMethod ?? 'even';
        
        // Get the item repository to allocate costs
        // NOTE: This creates a dependency on ItemRepository. In a real app,
        // you might want to use dependency injection or pass the repository as a parameter.
        // For now, we'll assume we have access to the ItemRepository via constructor injection.
        if (_itemRepository != null) {
          final allocateResult = await _itemRepository.batchUpdateItemPurchasePrices(
            palletId: palletId,
            palletCost: palletCost,
            allocationMethod: costAllocationMethod,
          );
          
          if (allocateResult.isFailure) {
            // Cost allocation failed, but pallet status was updated
            // We could either revert the status change or just log the error
            // For now, we'll return the error to the caller
            return Result.failure(allocateResult.error!);
          }
        }
      }
      
      return Result.success(Pallet.fromJson(response));
    } on PostgrestException catch (e) {
      return Result.failure(DatabaseException.updateFailed('pallet status $palletId', e.message));
    } catch (e) {
      return Result.failure(UnexpectedException('Unexpected error updating pallet status', e));
    }
  }
} 