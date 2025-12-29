import 'package:cloud_firestore/cloud_firestore.dart';

class HouseholdRecipe {
  final String? localRecipeId;
  final String? householdId;
  final int apiRecipeId;
  final String title;
  final String? imageUrl;
  final int? readyInMinutes;
  final int? servings;         // Khẩu phần ăn
  final double? calories;
  final String? difficulty;
  final String? instructions;
  final String? addedByUid;
  final DateTime? addedAt;
  final int usedIngredientCount;
  final int missedIngredientCount;

  HouseholdRecipe({
    this.localRecipeId,
    this.householdId,
    required this.apiRecipeId,
    required this.title,
    this.imageUrl,
    this.readyInMinutes,
    this.servings,
    this.calories,
    this.difficulty,
    this.instructions,
    this.addedByUid,
    this.addedAt,
    this.usedIngredientCount = 0,
    this.missedIngredientCount = 0,
  });

  factory HouseholdRecipe.fromSpoonacular(Map<String, dynamic> json) {
    return HouseholdRecipe(
      apiRecipeId: json['id'],
      title: json['title'],
      imageUrl: json['image'],
      usedIngredientCount: json['usedIngredientCount'] ?? 0,
      missedIngredientCount: json['missedIngredientCount'] ?? 0,
      
      // [FIX] Ép kiểu an toàn: (num?)?.toInt()
      readyInMinutes: (json['readyInMinutes'] as num?)?.toInt(),
      servings: (json['servings'] as num?)?.toInt(), 
      
      instructions: json['instructions'],
      calories: _parseCalories(json),
      difficulty: _calculateDifficulty((json['readyInMinutes'] as num?)?.toInt()),
    );
  }

  factory HouseholdRecipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HouseholdRecipe(
      localRecipeId: doc.id,
      householdId: data['household_id'],
      apiRecipeId: data['api_recipe_id'],
      title: data['title'],
      imageUrl: data['image_url'],
      readyInMinutes: data['ready_in_minutes'],
      servings: data['servings'],
      calories: (data['calories'] as num?)?.toDouble(),
      difficulty: data['difficulty'],
      instructions: data['instructions'],
      addedByUid: data['added_by_uid'],
      addedAt: (data['added_at'] as Timestamp?)?.toDate(),
      usedIngredientCount: 0,
      missedIngredientCount: 0,
    );
  }

  factory HouseholdRecipe.fromJson(Map<String, dynamic> json) {
    return HouseholdRecipe(
      apiRecipeId: json['id'],
      title: json['title'],
      imageUrl: json['image'] ?? '',
      missedIngredientCount: json['missedIngredientCount'] ?? 0,
      usedIngredientCount: json['usedIngredientCount'] ?? 0,
      servings: (json['servings'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'household_id': householdId,
      'api_recipe_id': apiRecipeId,
      'title': title,
      'image_url': imageUrl,
      'ready_in_minutes': readyInMinutes,
      'servings': servings,
      'calories': calories,
      'difficulty': difficulty,
      'instructions': instructions,
      'added_by_uid': addedByUid,
      'added_at': addedAt != null ? Timestamp.fromDate(addedAt!) : FieldValue.serverTimestamp(),
    };
  }

  static double? _parseCalories(Map<String, dynamic> json) {
    if (json['nutrition'] != null && json['nutrition']['nutrients'] != null) {
      final nutrients = json['nutrition']['nutrients'] as List;
      final calItem = nutrients.firstWhere(
        (element) => element['name'] == 'Calories',
        orElse: () => null,
      );
      return (calItem?['amount'] as num?)?.toDouble();
    }
    return null;
  }

  static String _calculateDifficulty(int? minutes) {
    if (minutes == null) return 'Medium';
    if (minutes <= 30) return 'Easy';
    if (minutes <= 60) return 'Medium';
    return 'Hard';
  }
}