import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final String? imageUrl;
  final String? quickTag;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.imageUrl,
    this.quickTag,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? 'Không tên',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? '',
      expiryDate: (data['expiry_date'] as Timestamp?)?.toDate(),
      imageUrl: data['image_url'],
      quickTag: data['quick_tag'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'image_url': imageUrl,
      'quick_tag': quickTag,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
  
  int get daysLeft {
    if (expiryDate == null) return 999;
    return expiryDate!.difference(DateTime.now()).inDays;
  }
}
