import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/pallet_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart';

// Mock data for pallet details (reusing the SimplePallet model from pallet_list_provider.dart)
final _mockPalletDetails = [
  {
    'id': 'p1',
    'supplier': 'Amazon',
    'type': 'Returns',
    'cost': 500.0,
    'purchase_date': '2023-10-15T10:00:00.000Z',
    'created_at': '2023-10-15T10:00:00.000Z',
    'updated_at': '2023-10-15T10:00:00.000Z',
  },
  {
    'id': 'p2',
    'supplier': 'Walmart',
    'type': 'Overstock',
    'cost': 750.0,
    'purchase_date': '2023-11-20T14:30:00.000Z',
    'created_at': '2023-11-20T14:30:00.000Z',
    'updated_at': '2023-11-20T14:30:00.000Z',
  },
  {
    'id': 'p3',
    'supplier': 'Target',
    'type': 'Liquidation',
    'cost': 300.0,
    'purchase_date': '2023-12-05T09:15:00.000Z',
    'created_at': '2023-12-05T09:15:00.000Z',
    'updated_at': '2023-12-05T09:15:00.000Z',
  }
];

/// Provider that fetches a specific pallet by ID (mock implementation)
final palletDetailProvider = FutureProvider.family<SimplePallet?, String>((ref, palletId) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));
  
  try {
    // Find the matching pallet in our mock data
    final palletJson = _mockPalletDetails.firstWhere(
      (p) => p['id'] == palletId,
      orElse: () => throw NotFoundException('Pallet not found with ID: $palletId'),
    );
    
    return SimplePallet.fromJson(palletJson);
  } catch (e) {
    if (e is! AppException) {
      throw AppException('Failed to fetch pallet: $e');
    }
    rethrow;
  }
}); 