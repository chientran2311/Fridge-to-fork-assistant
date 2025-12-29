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
    try {
      // BƯỚC 1: Thử gọi Gemini AI trước
      print("🤖 Đang hỏi đầu bếp AI (Gemini)...");
      final recipes = await _geminiService.recommendRecipes(ingredients);
      
      if (recipes.isNotEmpty) {
        return recipes;
      }
      
      // BƯỚC 2: Nếu Gemini trả về rỗng (hoặc lỗi), Fallback về Spoonacular
      // Lưu ý: Spoonacular có thể trả về rỗng nếu input là Tiếng Việt không dấu/có dấu
      print("⚠️ AI không trả lời, chuyển sang tìm kiếm Spoonacular...");
      return await _spoonacularService.getRecipesByIngredients(ingredients);

    } catch (e) {
      print("❌ Lỗi Repository: $e");
      // Nếu lỗi cả 2, ném lỗi ra ngoài cho Provider xử lý
      rethrow; 
    }
  }

  /// Tìm kiếm thông thường (Search Bar) thì dùng Spoonacular cho nhanh và chính xác
  Future<List<HouseholdRecipe>> searchRecipes(String query) async {
    return await _spoonacularService.searchRecipes(query);
  }
}