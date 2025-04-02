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
    'name': 'Electronics Pallet #1',
    'description': 'Mixed lot of consumer electronics',
    'purchase_price': 450.00,
    'source': 'ABC Liquidators',
    'supplier': 'Amazon',
    'type': 'Returns',
    'status': 'active',
    'cost': 500.0,
    'purchase_date': '2023-10-15T10:00:00.000Z',
    'created_at': '2023-10-15T10:00:00.000Z',
    'updated_at': '2023-10-15T10:00:00.000Z',
  },
  {
    'id': 'p2',
    'name': 'Clothing Pallet #1',
    'description': 'Assorted brand name clothing items',
    'purchase_price': 350.00,
    'source': 'Fashion Wholesale',
    'supplier': 'Walmart',
    'type': 'Overstock',
    'status': 'active',
    'cost': 750.0,
    'purchase_date': '2023-11-20T14:30:00.000Z',
    'created_at': '2023-11-20T14:30:00.000Z',
    'updated_at': '2023-11-20T14:30:00.000Z',
  },
  {
    'id': 'p3',
    'name': 'Home Goods Pallet',
    'description': 'Kitchen and bathroom items',
    'purchase_price': 275.50,
    'source': 'Home Liquidation Co',
    'supplier': 'Target',
    'type': 'Liquidation',
    'status': 'active',
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
    final matchedPallet = _mockPalletDetails.where((p) => p['id'] == palletId).toList();
    
    if (matchedPallet.isEmpty) {
      throw NotFoundException('Pallet not found with ID: $palletId');
    }
    
    final palletJson = matchedPallet.first;
    return SimplePallet.fromJson(palletJson);
  } catch (e) {
    if (e is AppException) {
      rethrow;
    }
    throw UnexpectedException('Failed to fetch pallet: $e');
  }
}); 