import 'package:cloud_firestore/cloud_firestore.dart';

class HouseholdRecipe {
  final String? localRecipeId;
  final String? householdId;
  final int apiRecipeId;
  final String title;
  final String? imageUrl;
  final int readyInMinutes;
  final int? servings;        
  final double? calories;
  final String? difficulty; // Lưu trữ chuỗi "Easy", "Medium", "Hard"
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
    this.readyInMinutes = 0, // Mặc định là 0 nếu không có dữ liệu
    this.servings,
    this.calories,
    this.difficulty,
    this.instructions,
    this.addedByUid,
    this.addedAt,
    this.usedIngredientCount = 0,
    this.missedIngredientCount = 0,
  });

  // [CẬP NHẬT] Getter tiện ích: Nếu field difficulty null thì tự tính lại để hiển thị UI
  String get difficultyLabel {
    if (difficulty != null && difficulty!.isNotEmpty) {
      return difficulty!;
    }
    return _calculateDifficulty(readyInMinutes);
  }

  factory HouseholdRecipe.fromSpoonacular(Map<String, dynamic> json) {
    // [CẬP NHẬT] Lấy time ra trước để tính toán, default = 0 nếu null
    final int time = (json['readyInMinutes'] as num?)?.toInt() ?? 0;

    return HouseholdRecipe(
      apiRecipeId: json['id'],
      title: json['title'],
      imageUrl: json['image'],
      usedIngredientCount: json['usedIngredientCount'] ?? 0,
      missedIngredientCount: json['missedIngredientCount'] ?? 0,
      
      // [CẬP NHẬT] Gán giá trị time đã xử lý null safety
      readyInMinutes: time,
      
      servings: (json['servings'] as num?)?.toInt(),
      
      instructions: json['instructions'],
      calories: _parseCalories(json),
      
      // [CẬP NHẬT] Tự động tính độ khó dựa trên thời gian ngay khi parse từ API
      difficulty: _calculateDifficulty(time),
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
      
      // [CẬP NHẬT] Thêm ?? 0 để an toàn
      readyInMinutes: data['ready_in_minutes'] ?? 0,
      
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
      // [CẬP NHẬT] Thêm xử lý time cho fromJson thường
      readyInMinutes: (json['readyInMinutes'] as num?)?.toInt() ?? 0,
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
      'difficulty': difficulty, // Lưu giá trị đã tính toán vào DB
      'instructions': instructions,
      'added_by_uid': addedByUid,
      'added_at': addedAt != null ? Timestamp.fromDate(addedAt!) : FieldValue.serverTimestamp(),
    };
  }

  static double? _parseCalories(Map<String, dynamic> json) {
    // Kiểm tra an toàn hơn
    if (json['nutrition'] != null && json['nutrition']['nutrients'] is List) {
      final nutrients = json['nutrition']['nutrients'] as List;
      // Dùng firstWhereOrNull (cần collection package) hoặc try/catch check range
      // Cách cơ bản:
      try {
        final calItem = nutrients.firstWhere(
          (element) => element['name'] == 'Calories',
          orElse: () => null,
        );
        return (calItem?['amount'] as num?)?.toDouble();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // [CẬP NHẬT] Logic tính toán tập trung
  static String _calculateDifficulty(int? minutes) {
    if (minutes == null) return 'Medium';
    if (minutes <= 30) return 'Easy';
    if (minutes <= 60) return 'Medium';
    return 'Hard';
  }
}