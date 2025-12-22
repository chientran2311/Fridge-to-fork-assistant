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

  // --- HÀM 1: Tìm theo nguyên liệu (Đã sửa tên như bạn yêu cầu) ---
  Future<void> getRecipesByIngredients(List<String> ingredients) async {
    // Reset danh sách nếu input rỗng
    if (ingredients.isEmpty) {
      _recipes = [];
      _errorMessage = "Tủ lạnh đang trống, hãy thêm thực phẩm!";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Báo UI hiện loading

    try {
      // Gọi service
      _recipes = await _service.getRecipesByIngredients(ingredients);
      
      if (_recipes.isEmpty) {
        _errorMessage = "Không tìm thấy công thức nào phù hợp với nguyên liệu của bạn.";
      }
    } catch (e) {
      _errorMessage = "Lỗi tải dữ liệu: $e";
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // Báo UI tắt loading
    }
  }

  // --- HÀM 2: Tìm kiếm theo tên (Đã đưa ra ngoài, không bị lồng nữa) ---
  Future<void> searchRecipes(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _recipes = await _service.searchRecipes(query);
      if (_recipes.isEmpty) {
        _errorMessage = "Không tìm thấy món nào tên là '$query'";
      }
    } catch (e) {
      _errorMessage = "Lỗi tìm kiếm: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}