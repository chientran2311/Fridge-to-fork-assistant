import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeService {
  final String apiKey = 'YOUR_SPOONACULAR_API_KEY'; // Thay key của bạn vào đây
  final String baseUrl = 'https://api.spoonacular.com/recipes';

  // FR2.1 & FR2.2: Tìm công thức dựa trên nguyên liệu
  Future<List<dynamic>> searchRecipesByIngredients(List<String> ingredients) async {
    // Chuyển list nguyên liệu thành chuỗi: "apple,+flour,+sugar"
    String ingredientsString = ingredients.join(',+');

    final url = Uri.parse(
      '$baseUrl/findByIngredients?ingredients=$ingredientsString&number=10&ranking=2&ignorePantry=true&apiKey=$apiKey'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body); 
        // Kết quả trả về sẽ có sẵn:
        // - usedIngredientCount (số lượng có sẵn)
        // - missedIngredientCount (số lượng còn thiếu -> FR2.2)
        // - missedIngredients (chi tiết món thiếu)
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  // FR2.4: Lấy chi tiết công thức (Bước làm, Video, Dinh dưỡng...)
  Future<Map<String, dynamic>> getRecipeInformation(int id) async {
    final url = Uri.parse(
      '$baseUrl/$id/information?includeNutrition=false&apiKey=$apiKey'
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
  
  // FR2.3: Tìm kiếm phức tạp (Lọc theo thời gian, loại bữa, ẩm thực)
  // Lưu ý: API Spoonacular tách riêng endpoint "complexSearch" cho việc lọc kỹ này
  Future<List<dynamic>> complexSearch({
    required String query, // Tên món (nếu có)
    List<String>? includeIngredients, // Nguyên liệu phải có
    String? type, // breakfast, main course...
    String? cuisine, // asian, italian...
    int? maxReadyTime, // Thời gian nấu tối đa
  }) async {
    // Xây dựng URL với các tham số query...
    // ...
    return [];
  }
}