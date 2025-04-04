/// A simplified item model for UI display purposes.
/// 
/// This lightweight model contains only the properties needed for UI display,
/// reducing unnecessary data transfer and improving rendering performance.
class SimpleItem {
  final String id;
  final String? name;
  final String? description;
  final String palletId;
  final String condition;
  final int quantity;
  final double? purchasePrice;
  final String status;
  final String? storageLocation;
  final String? salesChannel;
  final DateTime? createdAt;
  
  SimpleItem({
    required this.id,
    this.name,
    this.description,
    required this.palletId,
    required this.condition,
    required this.quantity,
    this.purchasePrice,
    required this.status,
    this.storageLocation,
    this.salesChannel,
    this.createdAt,
  });
  
  factory SimpleItem.fromJson(Map<String, dynamic> json) {
    return SimpleItem(
      id: json['id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      palletId: json['pallet_id'] as String,
      condition: json['condition'] as String,
      quantity: json['quantity'] as int,
      purchasePrice: json['purchase_price'] as double?,
      status: json['status'] as String,
      storageLocation: json['storage_location'] as String?,
      salesChannel: json['sales_channel'] as String?,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String)
        : null,
    );
  }
} 