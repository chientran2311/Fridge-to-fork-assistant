import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/household_recipe.dart';

class GeminiService {
  GenerativeModel? _model;

  // Khởi tạo Model
  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print("❌ Lỗi: Chưa có API Key trong file .env");
      return;
    }

    // --- ĐIỂM QUAN TRỌNG: CHỌN ĐÚNG MODEL ---
    // Theo bài viết bạn gửi, chúng ta cần dùng model dòng 1.5
    // 'gemini-1.5-flash': Nhanh, miễn phí, ổn định nhất hiện nay.
    // Nếu vẫn lỗi, bạn có thể thử đổi thành 'gemini-1.5-pro'
    print("🔑 Đang khởi tạo SDK với model: gemini-1.5-flash");
    
    _model = GenerativeModel(
      model: 'gemini-flash-latest', 
      apiKey: apiKey,
    );
  }

  // --- HÀM TEST KẾT NỐI (DEBUG) ---
  Future<void> testConnection() async {
    if (_model == null) _initModel();
    if (_model == null) return;

    print("--------------------------------------------------");
    print("📡 ĐANG GỌI TEST KẾT NỐI ĐẾN GOOGLE...");
    
    try {
      final content = [Content.text('Trả lời ngắn gọn: "Kết nối thành công! Mạng tốt."')];
      final response = await _model!.generateContent(content);

      print("✅ KẾT QUẢ TỪ GEMINI:");
      print("👇👇👇");
      print(response.text);
      print("👆👆👆");
    } catch (e) {
      print("🔥 LỖI KHI GỌI GEMINI:");
      print(e);
      // Gợi ý sửa lỗi dựa trên mã lỗi
      if (e.toString().contains("404")) {
        print("👉 Gợi ý: Lỗi 404 nghĩa là model này không tồn tại với Key của bạn.");
        print("👉 Hãy thử đổi tên model trong hàm _initModel thành 'gemini-pro' hoặc 'gemini-1.0-pro'");
      } else if (e.toString().contains("API key not valid")) {
        print("👉 Gợi ý: Key sai. Hãy tạo Key mới tại aistudio.google.com");
      }
    }
    print("--------------------------------------------------");
  }

  // --- HÀM 1: Gợi ý món ăn (UI gọi hàm này) ---
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
            imageUrl: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80", // Ảnh placeholder
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

  // --- HÀM 2: Lấy chi tiết (UI gọi hàm này) ---
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