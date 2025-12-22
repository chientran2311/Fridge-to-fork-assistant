import 'package:cloud_firestore/cloud_firestore.dart';

class HouseholdRecipe {
  // --- Fields khớp với Database (Household_Recipes) ---
  final String? localRecipeId; // PK: ID document trong Firestore (nullable vì khi lấy từ API chưa có)
  final String? householdId;   // FK: Thuộc về nhà nào
  final int apiRecipeId;       // ID gốc từ Spoonacular
  final String title;
  final String? imageUrl;
  final int? readyInMinutes;
  final double? calories;
  final String? difficulty;    // Easy/Medium/Hard
  final String? instructions;  // Hướng dẫn nấu chi tiết
  final String? addedByUid;    // Người thêm
  final DateTime? addedAt;

  // --- Fields hỗ trợ Logic App (Không lưu trong bảng Household_Recipes chính) ---
  // Những field này dùng để hiển thị UI khi search hoặc gợi ý (FR2)
  final int usedIngredientCount;
  final int missedIngredientCount;

  HouseholdRecipe({
    this.localRecipeId,
    this.householdId,
    required this.apiRecipeId,
    required this.title,
    this.imageUrl,
    this.readyInMinutes,
    this.calories,
    this.difficulty,
    this.instructions,
    this.addedByUid,
    this.addedAt,
    this.usedIngredientCount = 0,
    this.missedIngredientCount = 0,
  });

  // ==========================================================
  // 1. Factory: Tạo từ JSON của Spoonacular API
  // Dùng cho màn hình Search/Suggest (FR2)
  // ==========================================================
  factory HouseholdRecipe.fromSpoonacular(Map<String, dynamic> json) {
    return HouseholdRecipe(
      apiRecipeId: json['id'],
      title: json['title'],
      imageUrl: json['image'],
      // API findByIngredients trả về 2 trường này
      usedIngredientCount: json['usedIngredientCount'] ?? 0,
      missedIngredientCount: json['missedIngredientCount'] ?? 0,
      // Các trường detail có thể null nếu chỉ gọi search cơ bản
      readyInMinutes: json['readyInMinutes'],
      instructions: json['instructions'], // Spoonacular trả về string hoặc html
      // Logic tính calories và difficulty nếu API trả về (thường nằm trong nutrition)
      calories: _parseCalories(json),
      difficulty: _calculateDifficulty(json['readyInMinutes']),
    );
  }

  // ==========================================================
  // 2. Factory: Tạo từ Firestore (Database của bạn)
  // Dùng cho màn hình Saved Recipes, Planner
  // ==========================================================
  factory HouseholdRecipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HouseholdRecipe(
      localRecipeId: doc.id, // Lấy ID của document làm local_recipe_id
      householdId: data['household_id'],
      apiRecipeId: data['api_recipe_id'],
      title: data['title'],
      imageUrl: data['image_url'],
      readyInMinutes: data['ready_in_minutes'],
      calories: (data['calories'] as num?)?.toDouble(),
      difficulty: data['difficulty'],
      instructions: data['instructions'],
      addedByUid: data['added_by_uid'],
      addedAt: (data['added_at'] as Timestamp?)?.toDate(),
      // Dữ liệu trong kho đã lưu là dữ liệu tĩnh, mặc định count = 0 hoặc logic khác
      usedIngredientCount: 0, 
      missedIngredientCount: 0,
    );
  }

  // ==========================================================
  // 3. Method: Chuyển thành Map để lưu xuống Firestore
  // ==========================================================
  Map<String, dynamic> toFirestore() {
    return {
      'household_id': householdId,
      'api_recipe_id': apiRecipeId,
      'title': title,
      'image_url': imageUrl,
      'ready_in_minutes': readyInMinutes,
      'calories': calories,
      'difficulty': difficulty,
      'instructions': instructions,
      'added_by_uid': addedByUid,
      'added_at': addedAt != null ? Timestamp.fromDate(addedAt!) : FieldValue.serverTimestamp(),
    };
  }

  // --- Helper Functions ---

  // Helper: Lấy Calories từ JSON phức tạp của Spoonacular (nếu có)
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

  // Helper: Tự tính độ khó dựa trên thời gian nấu (vì API thường không trả về field này trực tiếp)
  static String _calculateDifficulty(int? minutes) {
    if (minutes == null) return 'Medium';
    if (minutes <= 30) return 'Easy';
    if (minutes <= 60) return 'Medium';
    return 'Hard';
  }
}