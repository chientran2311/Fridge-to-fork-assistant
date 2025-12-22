// lib/providers/recipe_provider.dart
import 'package:flutter/material.dart';
import '../models/household_recipe.dart';
import '../services/spoonacular_service.dart';

class RecipeProvider extends ChangeNotifier {
  final SpoonacularService _service = SpoonacularService();
  
  List<HouseholdRecipe> _recipes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<HouseholdRecipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Hàm chính: Gọi API dựa trên danh sách nguyên liệu đầu vào
  Future<void> fetchRecipesBasedOnInventory(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      _errorMessage = "Tủ lạnh đang trống!";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Báo UI hiện loading

    try {
      _recipes = await _service.getRecipesByIngredients(ingredients);
      if (_recipes.isEmpty) {
        _errorMessage = "Không tìm thấy công thức phù hợp.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Báo UI tắt loading & hiện dữ liệu
    }
  }
}