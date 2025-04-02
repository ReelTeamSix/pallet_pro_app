import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';

/// Provider that fetches distinct supplier values
final palletSuppliersProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(palletRepositoryProvider);
  final result = await repository.getDistinctFieldValues('supplier');
  
  return result.fold(
    (values) => values,
    (error) => [], // Return empty list on error
  );
});

/// Provider that fetches distinct source values
final palletSourcesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(palletRepositoryProvider);
  final result = await repository.getDistinctFieldValues('source');
  
  return result.fold(
    (values) => values,
    (error) => [], // Return empty list on error
  );
});

/// Provider that fetches distinct type values
final palletTypesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(palletRepositoryProvider);
  final result = await repository.getDistinctFieldValues('type');
  
  return result.fold(
    (values) => values,
    (error) => [], // Return empty list on error
  );
});

/// Provider that suggests the next pallet number by analyzing existing pallet names
final nextPalletNumberProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(palletRepositoryProvider);
  final result = await repository.getAllPallets();
  
  return result.fold(
    (pallets) {
      if (pallets.isEmpty) return 1;
      
      // Try to extract numbers from pallet names (e.g., "Pallet #3" would extract 3)
      final numbers = <int>[];
      
      for (final pallet in pallets) {
        final name = pallet.name;
        final hashIndex = name.indexOf('#');
        
        if (hashIndex != -1 && hashIndex < name.length - 1) {
          // Extract everything after # until non-digit character
          String numStr = '';
          for (int i = hashIndex + 1; i < name.length; i++) {
            if (name[i].contains(RegExp(r'[0-9]'))) {
              numStr += name[i];
            } else {
              break;
            }
          }
          
          if (numStr.isNotEmpty) {
            try {
              numbers.add(int.parse(numStr));
            } catch (_) {
              // Ignore parsing errors
            }
          }
        }
      }
      
      if (numbers.isEmpty) return 1;
      
      // Return highest number + 1
      return numbers.reduce((max, val) => max > val ? max : val) + 1;
    },
    (error) => 1, // Default to 1 if error occurs
  );
});

/// Helper to capitalize the first letter of each word
String capitalizeWords(String text) {
  if (text.isEmpty) return text;
  
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
} 