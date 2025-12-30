import '../services/spoonacular_service.dart';
import '../services/gemini_service.dart';
import '../../models/household_recipe.dart';
import '../../models/RecipeFilter.dart'; // Đừng quên import Filter

class RecipeRepository {
  // Dependency Injection: Khởi tạo các Service
  final SpoonacularService _spoonacularService = SpoonacularService();
  final GeminiService _geminiService = GeminiService();

  /// --- CHIẾN LƯỢC 1: TÌM BẰNG NGUYÊN LIỆU (AI TRƯỚC -> API SAU) ---
  /// Ưu tiên dùng Gemini AI để gợi ý món ăn sáng tạo.
  /// Nếu AI thất bại hoặc trả về rỗng, dùng Spoonacular.
  Future<List<HouseholdRecipe>> getRecipesByIngredients(
      List<String> ingredients) async {
    // Nếu không có nguyên liệu, trả về rỗng ngay
    if (ingredients.isEmpty) return [];

    try {
      // BƯỚC 1: Thử gọi Gemini AI trước
      print("🤖 Repository: Đang hỏi đầu bếp AI (Gemini)...");
      final recipes = await _geminiService.recommendRecipes(ingredients);

      if (recipes.isNotEmpty) {
        print("✅ Gemini đã tìm thấy ${recipes.length} món.");
        return recipes;
      }

      // BƯỚC 2: Nếu Gemini trả về rỗng, Fallback về Spoonacular
      print("⚠️ AI trả về rỗng, chuyển sang Spoonacular...");
      // Gọi hàm searchRecipes của Service (chỉ truyền ingredients)
      return await _spoonacularService.searchRecipes(ingredients: ingredients);
    } catch (e) {
      print("❌ Lỗi Gemini trong Repo: $e");

      // BƯỚC 3: Dự phòng cuối cùng - Nếu Gemini lỗi (mạng, key...), gọi Spoonacular
      print("🔄 Đang thử lại với Spoonacular...");
      try {
        return await _spoonacularService.searchRecipes(
            ingredients: ingredients);
      } catch (sError) {
        print("❌ Cả 2 service đều lỗi: $sError");
        rethrow; // Ném lỗi ra Provider/UI để hiện thông báo
      }
    }
  }

  /// --- CHIẾN LƯỢC 2: TÌM KIẾM TỔNG QUÁT (SEARCH BAR + FILTER) ---
  /// Dùng trực tiếp Spoonacular vì API này mạnh về tìm kiếm theo từ khóa và bộ lọc chuẩn.
  Future<List<HouseholdRecipe>> searchRecipes(
      {String? query, List<String>? ingredients, RecipeFilter? filter}) async {
    try {
      // Gọi sang Service với các tham số có tên (named arguments)
      return await _spoonacularService.searchRecipes(
        query: query,
        ingredients: ingredients,
        filter: filter,
      );
    } catch (e) {
      print("❌ Lỗi tìm kiếm trong Repo: $e");
      rethrow;
    }
  }
}
