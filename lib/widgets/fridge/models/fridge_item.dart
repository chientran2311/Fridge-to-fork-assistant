class FridgeItem {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final String category;
  final String imageUrl;
  final int? expiryDays; // Số ngày còn lại trước khi hết hạn
  final DateTime? expiryDate;

  FridgeItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.imageUrl,
    this.expiryDays,
    this.expiryDate,
  });

  bool get isExpiringSoon => expiryDays != null && expiryDays! <= 3;
  
  String get quantityText => '$quantity$unit';

  FridgeItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    String? category,
    String? imageUrl,
    int? expiryDays,
    DateTime? expiryDate,
  }) {
    return FridgeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      expiryDays: expiryDays ?? this.expiryDays,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}