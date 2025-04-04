import 'package:flutter/material.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';

/// A service class to manage dialog presentations throughout the app.
///
/// This class provides methods for showing various types of dialogs,
/// including confirmation dialogs, input forms, and informational dialogs.
class DialogService {
  /// Shows a confirmation dialog with custom title, message, and button text.
  ///
  /// Returns [true] if the user confirms, [false] otherwise.
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive 
                ? ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.red),
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// Shows a dialog to confirm marking a pallet as processed.
  ///
  /// This specialized dialog explains the implications of marking a pallet
  /// as processed, particularly the cost allocation to items.
  static Future<bool> showProcessPalletConfirmation({
    required BuildContext context,
    required String palletName,
    required int itemCount,
    required double palletCost,
    required String allocationMethod,
  }) async {
    final String allocationDescription = _getAllocationDescription(allocationMethod);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Process Pallet: $palletName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to mark this pallet as processed? '
                'This will finalize the pallet and allocate costs to all items.',
              ),
              const SizedBox(height: 16),
              Text('Items: $itemCount'),
              Text('Pallet Cost: \$${palletCost.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              Text('Cost Allocation Method: $allocationDescription'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Once processed, items will have their purchase prices '
                        'updated based on the allocation method.',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Process Pallet'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// Shows a dialog to collect data for marking an item as listed.
  ///
  /// Returns a map with the entered data if confirmed, null if cancelled.
  static Future<Map<String, dynamic>?> showListItemDialog({
    required BuildContext context,
    required String itemName,
    double? suggestedPrice,
  }) async {
    final formKey = GlobalKey<FormState>();
    double? listingPrice = suggestedPrice;
    String? listingPlatform;
    
    return showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('List for Sale: $itemName'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Listing Price *',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  initialValue: suggestedPrice?.toStringAsFixed(2),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a listing price';
                    }
                    try {
                      final price = double.parse(value);
                      if (price <= 0) {
                        return 'Price must be greater than zero';
                      }
                    } catch (e) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      listingPrice = double.parse(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Listing Platform *',
                  ),
                  items: [
                    'Facebook Marketplace',
                    'eBay',
                    'Amazon',
                    'Craigslist',
                    'OfferUp',
                    'Private Sale',
                    'Other',
                  ].map((platform) => DropdownMenuItem(
                    value: platform,
                    child: Text(platform),
                  )).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a platform';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    listingPlatform = value;
                  },
                  onSaved: (value) {
                    listingPlatform = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.of(context).pop({
                  'listingPrice': listingPrice,
                  'listingPlatform': listingPlatform,
                  'listingDate': DateTime.now(),
                });
              }
            },
            child: const Text('Mark as Listed'),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog to collect data for marking an item as sold.
  ///
  /// Returns a map with the entered data if confirmed, null if cancelled.
  static Future<Map<String, dynamic>?> showSoldItemDialog({
    required BuildContext context,
    required String itemName,
    double? listingPrice,
    String? listingPlatform,
  }) async {
    final formKey = GlobalKey<FormState>();
    double? soldPrice = listingPrice;
    String? sellingPlatform = listingPlatform;
    
    return showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as Sold: $itemName'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Selling Price *',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  initialValue: listingPrice?.toStringAsFixed(2),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a selling price';
                    }
                    try {
                      final price = double.parse(value);
                      if (price <= 0) {
                        return 'Price must be greater than zero';
                      }
                    } catch (e) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      soldPrice = double.parse(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Sales Platform *',
                  ),
                  value: listingPlatform,
                  items: [
                    'Facebook Marketplace',
                    'eBay',
                    'Amazon',
                    'Craigslist',
                    'OfferUp',
                    'Private Sale',
                    'Other',
                  ].map((platform) => DropdownMenuItem(
                    value: platform,
                    child: Text(platform),
                  )).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a platform';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    sellingPlatform = value;
                  },
                  onSaved: (value) {
                    sellingPlatform = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.of(context).pop({
                  'soldPrice': soldPrice,
                  'sellingPlatform': sellingPlatform,
                  'soldDate': DateTime.now(),
                });
              }
            },
            child: const Text('Mark as Sold'),
          ),
        ],
      ),
    );
  }

  /// Shows a generic error dialog with error details.
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Helper method to get a user-friendly description of the allocation method.
  static String _getAllocationDescription(String method) {
    switch (method.toLowerCase()) {
      case 'even':
        return 'Even Distribution (equal cost per item)';
      case 'proportional':
        return 'Proportional (based on listing price)';
      case 'manual':
        return 'Manual (you will assign costs individually)';
      default:
        return 'Even Distribution (equal cost per item)';
    }
  }
} 