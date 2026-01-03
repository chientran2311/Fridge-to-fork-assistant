import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/household_recipe.dart';

class GeminiService {
  GenerativeModel? _model;

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print("❌ Lỗi: Chưa có API Key trong file .env");
      return;
    }
    // Sử dụng flash cho tốc độ nhanh và chi phí thấp cho việc phân tích
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', 
      apiKey: apiKey,
    );
  }

  // --- [MỚI] HÀM 3: PHÂN TÍCH SỞ THÍCH NGƯỜI DÙNG ---
  /// Input: Danh sách tên món yêu thích & lịch sử nấu
  /// Output: Map JSON chứa tham số tìm kiếm (Query + Filter)
  Future<Map<String, dynamic>?> analyzeUserTaste({
    required List<String> favoriteTitles,
    required List<String> historyTitles,
  }) async {
    if (_model == null) _initModel();
    if (_model == null) return null;

    final prompt = '''
      Bạn là chuyên gia ẩm thực AI. Hãy phân tích dữ liệu người dùng:
      - Yêu thích: ${favoriteTitles.join(', ')}
      - Lịch sử nấu: ${historyTitles.join(', ')}

      Nhiệm vụ: Đề xuất MỘT ý tưởng tìm kiếm món ăn mới phù hợp gu của họ (tránh trùng món cũ).
      Yêu cầu: Trả về JSON thuần túy (không markdown) với cấu trúc để gọi API:
      {
        "query": "tên món hoặc từ khóa tiếng Anh ngắn gọn (ví dụ: 'Pasta' hoặc 'Spicy Chicken')",
        "cuisine": "một trong: Italian, Mexican, Asian, Mediterranean, Vegan (hoặc null)",
        "difficulty": "Easy, Medium hoặc Hard",
        "maxPrepTime": số phút (int)
      }
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      if (response.text != null) {
        String rawText = _cleanJson(response.text!);
        final Map<String, dynamic> result = jsonDecode(rawText);
        print("🤖 Gemini Phân tích xong: $result");
        return result;
      }
    } catch (e) {
      print("❌ Lỗi Analyze Taste: $e");
    }
    return null;
  }

  // --- HÀM 1: Gợi ý món ăn (Logic cũ - fallback) ---
  Future<List<HouseholdRecipe>> recommendRecipes(List<String> ingredients) async {
    if (_model == null) _initModel();
    if (_model == null) return [];

    final String ingredientsString = ingredients.join(", ");
    final String prompt = '''
      Gợi ý 5 món ăn từ: $ingredientsString.
      Yêu cầu: Trả về JSON Array thuần túy, không Markdown.
      Cấu trúc: [{"title": "Tên món", "readyInMinutes": 30, "difficulty": "Easy", "calories": 500.0}]
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      if (response.text != null) {
        String rawText = _cleanJson(response.text!);
        final List<dynamic> jsonList = jsonDecode(rawText);

        return jsonList.map<HouseholdRecipe>((data) {
          int fakeId = -(DateTime.now().microsecondsSinceEpoch + (data.hashCode));
          return HouseholdRecipe(
            apiRecipeId: fakeId,
            title: data['title'] ?? "Món AI gợi ý",
            imageUrl: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80",
            readyInMinutes: data['readyInMinutes'] ?? 30,
            difficulty: data['difficulty'] ?? "Medium",
            calories: (data['calories'] as num?)?.toDouble(),
            usedIngredientCount: ingredients.length,
            missedIngredientCount: 0,
          );
        }).toList();
      }
    } catch (e) {
      print("❌ Lỗi Recommend: $e");
    }
    return [];
  }

  // --- HÀM 2: Lấy chi tiết ---
  Future<Map<String, dynamic>?> getRecipeDetail(String recipeTitle) async {
    if (_model == null) _initModel();
    if (_model == null) return null;

    final String prompt = '''
      Viết công thức cho món: "$recipeTitle".
      Yêu cầu: Trả về JSON thuần (không markdown).
      Format:
      {
        "description": "Mô tả ngắn...",
        "readyInMinutes": 45,
        "difficulty": "Medium",
        "servings": 2, 
        "ingredients": ["500g nguyên liệu A"],
        "instructions": ["Bước 1...", "Bước 2..."]
      }
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      if (response.text != null) {
        String rawText = _cleanJson(response.text!);
        return jsonDecode(rawText);
      }
    } catch (e) {
      print("❌ Lỗi Detail: $e");
    }
    return null;
  }

  String _cleanJson(String raw) {
    return raw.replaceAll(RegExp(r'^```json'), '')
              .replaceAll(RegExp(r'^```'), '')
              .replaceAll('```', '')
              .trim();
  }
}