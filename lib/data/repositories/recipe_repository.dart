import '../services/spoonacular_service.dart';
import '../services/gemini_service.dart';
import '../../models/household_recipe.dart';

class RecipeRepository {
  // Dependency Injection: Khởi tạo các Service
  final SpoonacularService _spoonacularService = SpoonacularService();
  final GeminiService _geminiService = GeminiService();

  /// Chiến lược: Ưu tiên dùng Gemini AI để gợi ý vì nó hiểu Tiếng Việt
  /// và có thể "sáng tạo" món ăn từ nguyên liệu có sẵn.
  Future<List<HouseholdRecipe>> getRecipesByIngredients(List<String> ingredients) async {
    // Nếu không có nguyên liệu, trả về rỗng ngay
    if (ingredients.isEmpty) return [];

    try {
      // BƯỚC 1: Thử gọi Gemini AI trước
      print("🤖 Đang hỏi đầu bếp AI (Gemini)...");
      final recipes = await _geminiService.recommendRecipes(ingredients);
      
      if (recipes.isNotEmpty) {
        print("✅ Gemini đã tìm thấy ${recipes.length} món.");
        return recipes;
      }
      
      // BƯỚC 2: Nếu Gemini trả về rỗng, Fallback về Spoonacular
      print("⚠️ AI trả về rỗng, chuyển sang Spoonacular...");
      return await _spoonacularService.getRecipesByIngredients(ingredients);

    } catch (e) {
      print("❌ Lỗi Gemini trong Repo: $e");
      
      // BƯỚC 3: Dự phòng cuối cùng - Nếu Gemini lỗi (mạng, key...), gọi Spoonacular
      print("🔄 Đang thử lại với Spoonacular...");
      try {
        return await _spoonacularService.getRecipesByIngredients(ingredients);
      } catch (sError) {
        print("❌ Cả 2 service đều lỗi: $sError");
        rethrow; // Ném lỗi ra UI để hiện thông báo
      }
    }
  }

  /// Tìm kiếm thông thường (Search Bar)
  /// Có thể dùng Spoonacular cho nhanh, hoặc cũng dùng Gemini nếu muốn
  Future<List<HouseholdRecipe>> searchRecipes(String query) async {
    return await _spoonacularService.searchRecipes(query);
  }
}