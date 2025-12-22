// lib/services/spoonacular_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/household_recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class SpoonacularService {
  static String get _apiKey => dotenv.env['SPOONACULAR_API_KEY'] ?? ''; // Thay Key của bạn vào đây
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';

  Future<List<HouseholdRecipe>> searchRecipes(String query) async {
    final url = Uri.parse(
      '$_baseUrl/complexSearch?query=$query&number=10&apiKey=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results']; // complexSearch trả về field 'results'
      return results.map((json) => HouseholdRecipe.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi tìm kiếm: ${response.statusCode}');
    }
  }
  // Hàm gọi API findByIngredients
  Future<List<HouseholdRecipe>> getRecipesByIngredients(List<String> ingredients) async {
    if (_apiKey.isEmpty) throw Exception('Chưa cấu hình API Key');

    final String ingredientsString = ingredients.join(',+');
    
    final url = Uri.parse(
      '$_baseUrl/findByIngredients?ingredients=$ingredientsString&number=10&ranking=1&ignorePantry=true&apiKey=$_apiKey',
    );

    // === THÊM DÒNG NÀY ĐỂ DEBUG ===
    print("🚀 Đang gọi API: $url"); 
    // ==============================

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      
      // === THÊM DÒNG NÀY ĐỂ XEM KẾT QUẢ TRẢ VỀ ===
      print("✅ Kết quả tìm thấy: ${data.length} công thức");
      // ===========================================
      
      return data.map((json) => HouseholdRecipe.fromSpoonacular(json)).toList();
    } else {
      print("❌ Lỗi API: ${response.body}"); // In lỗi nếu có
      throw Exception('Lỗi API (${response.statusCode}): ${response.body}');
    }
  
    
  }
}