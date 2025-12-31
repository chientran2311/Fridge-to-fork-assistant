import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String inventoryId;
  final String ingredientId;
  final String householdId;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final String addedByUid;
  final DateTime? createdAt;

  // Optional: Populated data from ingredient
  String? ingredientName;
  String? ingredientBarcode;
  String? ingredientCategory;
  String? ingredientImageUrl;

  InventoryItem({
    required this.inventoryId,
    required this.ingredientId,
    required this.householdId,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.addedByUid,
    this.createdAt,
    this.ingredientName,
    this.ingredientBarcode,
    this.ingredientCategory,
    this.ingredientImageUrl,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      inventoryId: data['inventory_id'] ?? doc.id,
      ingredientId: data['ingredient_id'] ?? '',
      householdId: data['household_id'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      expiryDate: (data['expiry_date'] as Timestamp?)?.toDate(),
      addedByUid: data['added_by_uid'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'inventory_id': inventoryId,
      'ingredient_id': ingredientId,
      'household_id': householdId,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'added_by_uid': addedByUid,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  int? get expiryDays {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  bool get isExpiringSoon {
    final days = expiryDays;
    return days != null && days <= 3 && days >= 0;
  }

  String getCategoryEmoji() {
    if (ingredientCategory == null) return '🍽️';
    switch (ingredientCategory!.toLowerCase()) {
      case 'meat':
        return '🥩';
      case 'dairy':
        return '🥛';
      case 'vegetable':
        return '🥗';
      case 'fruit':
        return '🍎';
      default:
        return '🍽️';
    }
  }
}
