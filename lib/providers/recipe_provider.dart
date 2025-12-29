import 'package:flutter/material.dart';
import '../models/household_recipe.dart';
// Import Repository thay vì Service
import '../data/repositories/recipe_repository.dart'; 

class RecipeProvider extends ChangeNotifier {
  // Gọi qua Repository
  final RecipeRepository _repository = RecipeRepository();
  
  List<HouseholdRecipe> _recipes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<HouseholdRecipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // --- HÀM 1: Gợi ý món ăn thông minh (AI) ---
  Future<void> getRecipesByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      _recipes = [];
      _errorMessage = "Tủ lạnh đang trống, hãy thêm thực phẩm!";
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      // Provider không cần biết là đang dùng Gemini hay Spoonacular, chỉ cần biết là lấy được recipes
      _recipes = await _repository.getRecipesByIngredients(ingredients);
      
      if (_recipes.isEmpty) {
        _errorMessage = "Không tìm thấy công thức phù hợp. Thử thêm nguyên liệu khác xem?";
      }
    } catch (e) {
      _errorMessage = "Có lỗi xảy ra: $e";
      _recipes = [];
    } finally {
      _setLoading(false);
    }
  }

  // --- HÀM 2: Tìm kiếm món ăn (Search Bar) ---
  Future<void> searchRecipes(String query) async {
    if (query.isEmpty) return;

    _setLoading(true);

    try {
      _recipes = await _repository.searchRecipes(query);
      if (_recipes.isEmpty) {
        _errorMessage = "Không tìm thấy món nào tên là '$query'";
      }
    } catch (e) {
      _errorMessage = "Lỗi tìm kiếm: $e";
    } finally {
      _setLoading(false);
    }
  }

  // Hàm phụ trợ để set loading và reset lỗi
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = ''; // Reset lỗi khi bắt đầu tải mới
    notifyListeners();
  }
}