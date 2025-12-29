import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/household_recipe.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is missing in .env');
    }
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  Future<List<HouseholdRecipe>> recommendRecipes(List<String> ingredients) async {
    final prompt = '''
      Tôi có các nguyên liệu sau trong tủ lạnh: ${ingredients.join(', ')}.
      Hãy đóng vai một đầu bếp chuyên nghiệp, gợi ý cho tôi 3 món ăn Việt Nam ngon, dễ nấu từ các nguyên liệu trên.
      Có thể cần mua thêm gia vị cơ bản.
      
      TRẢ VỀ KẾT QUẢ DƯỚI DẠNG JSON ARRAY (Không Markdown, chỉ JSON thuần) với cấu trúc sau:
      [
        {
          "id": 123 (random int),
          "title": "Tên món ăn",
          "image": "https://source.unsplash.com/800x600/?vietnamese_food",
          "readyInMinutes": 30,
          "missedIngredientCount": 2, 
          "usedIngredientCount": 3,
          "calories": 500.0,
          "difficulty": "Easy",
          "instructions": "Hướng dẫn ngắn gọn..."
        }
      ]
    ''';

    final content = [Content.text(prompt)];
    
    try {
      final response = await _model.generateContent(content);
      final responseText = response.text;
      
      if (responseText == null) return [];

      // Clean Markdown nếu Gemini trả về ```json ... ```
      final jsonString = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((e) => HouseholdRecipe.fromSpoonacular(e)).toList();
    } catch (e) {
      print("Gemini Error: $e");
      return [];
    }
  }
}