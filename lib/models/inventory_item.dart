import 'package:cloud_firestore/cloud_firestore.dart';

/// InventoryItem Model - Thống nhất cho cả manual entry và barcode scan
/// 
/// Sử dụng pattern:
/// - `id`: Document ID trong Firestore
/// - `name`: Tên món (manual entry hoặc từ ingredient)
/// - `quickTag`: Category/tag nhanh cho phân loại
/// - Các field ingredient* để lưu data từ barcode scan (optional)
class InventoryItem {
  final String id; // Document ID
  final String? ingredientId; // ID của ingredient nếu từ barcode scan
  final String householdId;
  final String name; // Tên món ăn
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final String? addedByUid;
  final DateTime? createdAt;

  // Quick Tag / Category
  final String? quickTag;
  
  // Image URL
  final String? imageUrl;

  // Optional: Populated data from ingredient (for barcode scan)
  String? ingredientName;
  String? ingredientBarcode;
  String? ingredientCategory;
  String? ingredientImageUrl;

  InventoryItem({
    required this.id,
    this.ingredientId,
    this.householdId = '',
    required this.name,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.addedByUid,
    this.createdAt,
    this.quickTag,
    this.imageUrl,
    this.ingredientName,
    this.ingredientBarcode,
    this.ingredientCategory,
    this.ingredientImageUrl,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      ingredientId: data['ingredient_id'],
      householdId: data['household_id'] ?? '',
      name: data['name'] ?? 'Chưa đặt tên',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'cái',
      expiryDate: (data['expiry_date'] as Timestamp?)?.toDate(),
      addedByUid: data['added_by_uid'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      quickTag: data['quick_tag'] ?? data['category'], // Tương thích cả 2 field name
      imageUrl: data['image_url'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ingredient_id': ingredientId ?? '',
      'household_id': householdId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'added_by_uid': addedByUid ?? '',
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'quick_tag': quickTag ?? 'Khác',
      'image_url': imageUrl ?? '',
    };
  }

  /// Số ngày còn lại trước khi hết hạn
  int get daysLeft {
    if (expiryDate == null) return 999; // Không có ngày hết hạn
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Alias cho daysLeft (tương thích code cũ)
  int? get expiryDays {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Kiểm tra sắp hết hạn (trong 3 ngày)
  bool get isExpiringSoon {
    final days = expiryDays;
    return days != null && days <= 3 && days >= 0;
  }

  /// Kiểm tra đã hết hạn
  bool get isExpired {
    final days = expiryDays;
    return days != null && days < 0;
  }

  /// Lấy emoji dựa trên category
  String getCategoryEmoji() {
    final cat = quickTag ?? ingredientCategory;
    if (cat == null) return '🍽️';
    
    final lowerCat = cat.toLowerCase();
    if (lowerCat.contains('meat') || lowerCat.contains('thịt')) return '🥩';
    if (lowerCat.contains('dairy') || lowerCat.contains('sữa') || lowerCat.contains('trứng')) return '🥛';
    if (lowerCat.contains('veg') || lowerCat.contains('rau')) return '🥗';
    if (lowerCat.contains('fruit') || lowerCat.contains('trái') || lowerCat.contains('quả')) return '🍎';
    return '🍽️';
  }

  /// Copy with - để tạo bản sao với các field được thay đổi
  InventoryItem copyWith({
    String? id,
    String? ingredientId,
    String? householdId,
    String? name,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    String? addedByUid,
    DateTime? createdAt,
    String? quickTag,
    String? imageUrl,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      addedByUid: addedByUid ?? this.addedByUid,
      createdAt: createdAt ?? this.createdAt,
      quickTag: quickTag ?? this.quickTag,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}