import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Đảm bảo import đúng đường dẫn Model
import '../../models/household_recipe.dart'; 
import '../../models/RecipeFilter.dart';
class SpoonacularService {
  // Lấy API Key từ file .env
  static String get _apiKey => dotenv.env['SPOONACULAR_API_KEY'] ?? ''; 
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';
  static const String _authority = 'api.spoonacular.com';
  static const String _path = '/recipes/complexSearch';
  // --- 1. Tìm kiếm món ăn theo tên (Search) ---
 // Trong file spoonacular_service.dart

Future<List<HouseholdRecipe>> searchRecipes({
    String? query,
    List<String>? ingredients,
    RecipeFilter? filter,
  }) async {
    if (_apiKey.isEmpty) throw Exception('Chưa cấu hình API Key');

    // 1. Các tham số cơ bản
    final Map<String, String> queryParameters = {
      'apiKey': _apiKey,
      'number': '10',
      'addRecipeInformation': 'true',
      'fillIngredients': 'true',
      'instructionsRequired': 'true',
    };

    // 2. Xử lý Query (Search Text)
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }

    // 3. Xử lý Nguyên liệu
    if (ingredients != null && ingredients.isNotEmpty) {
      queryParameters['includeIngredients'] = ingredients.join(',');
      queryParameters['sort'] = 'min-missing-ingredients';
    }

    // 4. Xử lý Filter (Logic mới cập nhật)
    if (filter != null) {
      // -- Cuisine & Diet Mapping --
      // [LOGIC QUAN TRỌNG]: UI nhóm 'Vegan' vào Cuisine, nhưng API cần tách ra 'diet'
      if (filter.cuisine != null && filter.cuisine!.isNotEmpty) {
        if (filter.cuisine == 'Vegan') {
          queryParameters['diet'] = 'vegan'; // Chuyển sang tham số diet
        } else {
          queryParameters['cuisine'] = filter.cuisine!; // Giữ nguyên cuisine (Italian, Asian...)
        }
      }

      // -- Meal Type --
      if (filter.mealType != null && filter.mealType!.isNotEmpty) {
        queryParameters['type'] = filter.mealType!;
      }

      int? calculatedMaxTime;

      // Logic Mapping:
      if (filter.difficulty == 'Easy') {
        calculatedMaxTime = 30; // Dễ = dưới 30 phút
      } else if (filter.difficulty == 'Medium') {
        calculatedMaxTime = 60; // Vừa = dưới 60 phút
      }
      // -- Max Prep Time --
      // Chỉ gửi tham số nếu user đã chọn thời gian < 120 (max mặc định)
     if (filter.maxPrepTime < 120) {
        if (calculatedMaxTime != null) {
           // Lấy min của 2 giá trị
           calculatedMaxTime = (filter.maxPrepTime < calculatedMaxTime) 
              ? filter.maxPrepTime 
              : calculatedMaxTime;
        } else {
           calculatedMaxTime = filter.maxPrepTime;
        }
      }
      if (calculatedMaxTime != null) {
        queryParameters['maxReadyTime'] = calculatedMaxTime.toString();
      }
    }

    final uri = Uri.https(_authority, _path, queryParameters);
    print("🚀 Spoonacular API Call: $uri");

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        // 1. Map sang Model
        var recipes = results.map((json) => HouseholdRecipe.fromSpoonacular(json)).toList();

        // [FIX] 2. Lọc chỉ lấy món đáp ứng >= 80% nguyên liệu
        // Công thức: (Số lượng có) / (Số lượng có + Số lượng thiếu) >= 0.8
        if (ingredients != null && ingredients.isNotEmpty) {
           recipes = recipes.where((recipe) {
              int total = recipe.usedIngredientCount + recipe.missedIngredientCount;
              if (total == 0) return true; // Giữ lại nếu không có thông tin (tránh chia cho 0)
              
              double matchPercentage = recipe.usedIngredientCount / total;
              print("📊 ${recipe.title}: ${(matchPercentage * 100).toStringAsFixed(0)}% match (${recipe.usedIngredientCount}/${total})");
              return matchPercentage >= 0.3; // Chỉ lấy nếu khớp >= 80%
           }).toList();
           
           print("✅ Sau khi lọc >= 30%: ${recipes.length} công thức");
        }

        return recipes;
      } else {
        throw Exception('Lỗi API (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print("❌ Exception: $e");
      rethrow;
    }
  }

  // --- 2. Tìm theo nguyên liệu (Find by Ingredients) ---
  Future<List<HouseholdRecipe>> getRecipesByIngredients(List<String> ingredients) async {
    if (_apiKey.isEmpty) throw Exception('Chưa cấu hình API Key');

    final String ingredientsString = ingredients.join(',+');
    
    final url = Uri.parse(
      '$_baseUrl/findByIngredients?ingredients=$ingredientsString&number=10&ranking=1&ignorePantry=true&apiKey=$_apiKey',
    );

    print("🚀 Spoonacular API (Find): $url"); 

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

  // --- [MỚI] 3. Lấy chi tiết công thức (Get Recipe Information) ---
  // Hàm này dùng cho màn hình RecipeDetailScreen
  Future<Map<String, dynamic>?> getRecipeInformation(int id) async {
    if (_apiKey.isEmpty) return null;

    // Endpoint lấy thông tin chi tiết (bao gồm cả nutrition nếu cần)
    final url = Uri.parse(
      '$_baseUrl/$id/information?includeNutrition=false&apiKey=$_apiKey',
    );

    print("🚀 Spoonacular API (Detail): $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Trả về Map JSON thô để UI tự xử lý (instruction, ingredients...)
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print("❌ Lỗi lấy chi tiết (${response.statusCode}): ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception Spoonacular: $e");
      return null;
    }
  }
}