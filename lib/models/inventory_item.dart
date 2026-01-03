import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final String? imageUrl;
  final String? quickTag; // Ví dụ: meat, veg, dairy

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.imageUrl,
    this.quickTag,
  });

  // Factory chuyển từ Firestore Document sang Object
  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? 'Không tên',
      // Xử lý an toàn cho số (vì Firestore có thể trả về int hoặc double)
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? '',
      // Xử lý Timestamp của Firebase
      expiryDate: (data['expiry_date'] as Timestamp?)?.toDate(),
      imageUrl: data['image_url'],
      quickTag: data['quick_tag'],
    );
  }

  // Chuyển Object sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'image_url': imageUrl,
      'quick_tag': quickTag,
    };
  }

  // Hàm kiểm tra xem đã hết hạn chưa (Hỗ trợ UI)
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
  
  // Hàm tính số ngày còn lại
  int get daysLeft {
    if (expiryDate == null) return 999;
    return expiryDate!.difference(DateTime.now()).inDays;
  }
}
