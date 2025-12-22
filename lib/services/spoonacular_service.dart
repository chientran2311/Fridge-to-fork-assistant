// lib/services/spoonacular_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/household_recipe.dart';

class SpoonacularService {
  static const String apiKey = '5b212a3628bd4cec9fc5db21baa7f5a0'; // Thay Key của bạn vào đây
  static const String baseUrl = 'https://api.spoonacular.com/recipes';

  // Hàm gọi API findByIngredients
  Future<List<HouseholdRecipe>> getRecipesByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) return [];

    // Biến đổi list ["thit", "trung"] thành chuỗi "thit,trung"
    final ingredientsString = ingredients.join(',').toLowerCase();

    // ignorePantry=true: Bỏ qua các gia vị cơ bản (muối, đường, nước)
    final url = Uri.parse(
      '$baseUrl/findByIngredients?apiKey=$apiKey&ingredients=$ingredientsString&number=10&ranking=1&ignorePantry=true'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => HouseholdRecipe.fromSpoonacular(json)).toList();
      } else {
        throw Exception('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}