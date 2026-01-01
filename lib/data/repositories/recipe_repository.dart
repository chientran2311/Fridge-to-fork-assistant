import '../services/spoonacular_service.dart';
import '../services/gemini_service.dart';
import '../../models/household_recipe.dart';
import '../../models/RecipeFilter.dart';

class RecipeRepository {
  final SpoonacularService _spoonacularService = SpoonacularService();
  final GeminiService _geminiService = GeminiService();

  // --- [MỚI] CHIẾN LƯỢC 3: SMART RECOMMENDATION (AI + API) ---
  /// 1. Gemini phân tích Favorites/History -> Ra Filter
  /// 2. Spoonacular tìm kiếm thực tế dựa trên Filter đó
  Future<List<HouseholdRecipe>> getSmartRecommendations({
    required List<String> favoriteTitles,
    required List<String> historyTitles,
  }) async {
    try {
      // BƯỚC 1: Hỏi Gemini
      final suggestion = await _geminiService.analyzeUserTaste(
        favoriteTitles: favoriteTitles,
        historyTitles: historyTitles,
      );

      // Default fallback
      String query = "trending";
      RecipeFilter filter = RecipeFilter();

      // BƯỚC 2: Parse kết quả từ Gemini
      if (suggestion != null) {
        query = suggestion['query'] ?? "popular";
        
        filter = RecipeFilter(
          cuisine: suggestion['cuisine'],
          difficulty: suggestion['difficulty'],
          maxPrepTime: (suggestion['maxPrepTime'] as num?)?.toInt() ?? 60,
        );
      }

      print("✨ Repository: Tìm kiếm theo gợi ý AI -> Query: '$query', Cuisine: '${filter.cuisine}'");

      // BƯỚC 3: Gọi Spoonacular (dùng hàm searchRecipes có sẵn logic Filter)
      return await _spoonacularService.searchRecipes(
        query: query,
        filter: filter,
      );

    } catch (e) {
      print("❌ Lỗi Smart Recommendation: $e");
      // Fallback: Tìm món random popular
      return await _spoonacularService.searchRecipes(query: "healthy");
    }
  }

  // --- CHIẾN LƯỢC 1: TÌM BẰNG NGUYÊN LIỆU (Giữ nguyên logic cũ) ---
  Future<List<HouseholdRecipe>> getRecipesByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) return [];
    try {
      // Ưu tiên Gemini tạo công thức giả lập trước (tùy nhu cầu của bạn)
      // Hoặc gọi thẳng Spoonacular nếu muốn chính xác.
      // Ở đây giữ logic cũ của bạn:
      final recipes = await _geminiService.recommendRecipes(ingredients);
      if (recipes.isNotEmpty) return recipes;
      
      return await _spoonacularService.searchRecipes(ingredients: ingredients);
    } catch (e) {
      print("❌ Lỗi Gemini/API: $e");
      // Fallback cuối cùng
      return await _spoonacularService.searchRecipes(ingredients: ingredients);
    }
  }

  // --- CHIẾN LƯỢC 2: TÌM KIẾM TỔNG QUÁT ---
  Future<List<HouseholdRecipe>> searchRecipes({
    String? query, 
    List<String>? ingredients, 
    RecipeFilter? filter
  }) async {
    return await _spoonacularService.searchRecipes(
      query: query,
      ingredients: ingredients,
      filter: filter,
    );
  }
}