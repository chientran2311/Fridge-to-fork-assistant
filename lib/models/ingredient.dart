import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String ingredientId;
  final String name;
  final String barcode;
  final String category;
  final String defaultUnit;
  final String imageUrl;
  final Map<String, dynamic>? nutrition;
  final DateTime? createdAt;

  Ingredient({
    required this.ingredientId,
    required this.name,
    required this.barcode,
    required this.category,
    required this.defaultUnit,
    this.imageUrl = '',
    this.nutrition,
    this.createdAt,
  });

  factory Ingredient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ingredient(
      ingredientId: data['ingredient_id'] ?? doc.id,
      name: data['name'] ?? '',
      barcode: data['barcode'] ?? '',
      category: data['category'] ?? '',
      defaultUnit: data['default_unit'] ?? 'pcs',
      imageUrl: data['image_url'] ?? '',
      nutrition: data['nutrition'] as Map<String, dynamic>?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ingredient_id': ingredientId,
      'name': name,
      'barcode': barcode,
      'category': category,
      'default_unit': defaultUnit,
      'image_url': imageUrl,
      'nutrition': nutrition,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  String getCategoryEmoji() {
    switch (category.toLowerCase()) {
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