import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Đảm bảo import đúng đường dẫn Model
import '../../models/household_recipe.dart'; 

class SpoonacularService {
  static String get _apiKey => dotenv.env['SPOONACULAR_API_KEY'] ?? ''; 
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';

  // Chức năng: Tìm kiếm món ăn theo tên (Search)
  Future<List<HouseholdRecipe>> searchRecipes(String query) async {
    final url = Uri.parse(
      '$_baseUrl/complexSearch?query=$query&number=10&addRecipeInformation=true&apiKey=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => HouseholdRecipe.fromSpoonacular(json)).toList();
    } else {
      throw Exception('Lỗi tìm kiếm: ${response.statusCode}');
    }
  }

  // Chức năng: Tìm theo nguyên liệu (Dự phòng cho Gemini)
  Future<List<HouseholdRecipe>> getRecipesByIngredients(List<String> ingredients) async {
    if (_apiKey.isEmpty) throw Exception('Chưa cấu hình API Key');

    final String ingredientsString = ingredients.join(',+');
    
    final url = Uri.parse(
      '$_baseUrl/findByIngredients?ingredients=$ingredientsString&number=10&ranking=1&ignorePantry=true&apiKey=$_apiKey',
    );

    print("🚀 Spoonacular API: $url"); 

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("✅ Spoonacular tìm thấy: ${data.length} công thức");
      return data.map((json) => HouseholdRecipe.fromSpoonacular(json)).toList();
    } else {
      print("❌ Lỗi API: ${response.body}"); 
      throw Exception('Lỗi API (${response.statusCode}): ${response.body}');
    }
  }
}