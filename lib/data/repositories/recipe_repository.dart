/// ============================================
/// RECIPE REPOSITORY - DATA ACCESS LAYER
/// ============================================
/// 
/// Repository pattern for recipe data operations.
/// 
/// Services Used:
/// - SpoonacularService: External recipe API
/// - GeminiService: AI-powered recommendations (optional)
/// 
/// Methods:
/// - searchRecipes: Search recipes by ingredients/query
/// - getSmartRecommendations: AI-powered recipe suggestions
/// 
/// ============================================

import '../services/spoonacular_service.dart';
import '../../models/household_recipe.dart';
import '../../models/RecipeFilter.dart';

/// Repository class for recipe data operations
class RecipeRepository {
  final SpoonacularService _spoonacularService = SpoonacularService();

  /// Get smart recommendations based on user preferences
  /// Uses AI analysis of favorites and cooking history
  Future<List<HouseholdRecipe>> getSmartRecommendations({
    required List<String> favoriteTitles,
    required List<String> historyTitles,
  }) async {
    try {
      // Default search parameters
      String query = "popular";
      RecipeFilter filter = RecipeFilter();

      print("✨ Repository: Searching for recommendations -> Query: '$query'");

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
