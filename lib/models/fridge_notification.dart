import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho thông báo tủ lạnh
class FridgeNotification {
  final String id;
  final String title;
  final String itemName;
  final double? quantity;
  final String? unit;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  FridgeNotification({
    required this.id,
    required this.title,
    required this.itemName,
    this.quantity,
    this.unit,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  /// Factory từ Firestore
  factory FridgeNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FridgeNotification(
      id: doc.id,
      title: data['title'] ?? '',
      itemName: data['item_name'] ?? '',
      quantity: data['quantity']?.toDouble(),
      unit: data['unit'],
      type: NotificationType.fromString(data['type'] ?? 'other'),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['is_read'] ?? false,
    );
  }

  /// Chuyển thành Map để lưu Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'is_read': isRead,
    };
  }

  /// Copy với thay đổi
  FridgeNotification copyWith({
    String? id,
    String? title,
    String? itemName,
    double? quantity,
    String? unit,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return FridgeNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Tạo thông báo thêm món
  factory FridgeNotification.added({
    required String itemName,
    required double quantity,
    required String unit,
  }) {
    final quantityText = quantity % 1 == 0 
        ? quantity.toInt().toString() 
        : quantity.toString();
    
    return FridgeNotification(
      id: '',
      title: '$quantityText$unit $itemName has been added to the fridge.',
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      type: NotificationType.added,
      timestamp: DateTime.now(),
    );
  }

  /// Tạo thông báo lấy món ra
  factory FridgeNotification.removed({
    required String itemName,
    required double quantity,
    required String unit,
  }) {
    final quantityText = quantity % 1 == 0 
        ? quantity.toInt().toString() 
        : quantity.toString();
    
    return FridgeNotification(
      id: '',
      title: '$quantityText$unit $itemName has been taken out from the fridge.',
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      type: NotificationType.removed,
      timestamp: DateTime.now(),
    );
  }

  /// Tạo thông báo cập nhật món
  factory FridgeNotification.updated({
    required String itemName,
    required double quantity,
    required String unit,
  }) {
    final quantityText = quantity % 1 == 0 
        ? quantity.toInt().toString() 
        : quantity.toString();
    
    return FridgeNotification(
      id: '',
      title: '$itemName has been updated ($quantityText$unit).',
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      type: NotificationType.updated,
      timestamp: DateTime.now(),
    );
  }
}

/// Loại thông báo
enum NotificationType {
  added,    // Thêm vào tủ
  removed,  // Lấy ra khỏi tủ
  updated,  // Cập nhật thông tin
  expiring, // Sắp hết hạn
  other;    // Khác

  static NotificationType fromString(String value) {
    switch (value) {
      case 'added':
        return NotificationType.added;
      case 'removed':
        return NotificationType.removed;
      case 'updated':
        return NotificationType.updated;
      case 'expiring':
        return NotificationType.expiring;
      default:
        return NotificationType.other;
    }
  }
}