import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/household_recipe.dart';
import '../data/services/spoonacular_service.dart';
import '../models/RecipeFilter.dart';

class RecipeProvider extends ChangeNotifier {
  // Nên dùng Repository nếu có, nhưng ở đây tôi giữ nguyên Service theo code của bạn
  final SpoonacularService _spoonacularService = SpoonacularService();

  // --- STATE ---
  List<HouseholdRecipe> _recipes = [];
  List<HouseholdRecipe> _favoriteRecipes = [];
  
  RecipeFilter _currentFilter = RecipeFilter();
  List<String> _currentIngredients = [];
  String _currentQuery = ""; // Lưu lại từ khóa tìm kiếm nếu có

  bool _isLoading = false;
  String _errorMessage = "";

  // --- GETTERS ---
  List<HouseholdRecipe> get recipes => _recipes;
  List<HouseholdRecipe> get favoriteRecipes => _favoriteRecipes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage.isNotEmpty ? _errorMessage : null;
  RecipeFilter get currentFilter => _currentFilter;

  // --- 1. LOGIC TÌM KIẾM (API) ---

  /// Hàm tìm kiếm trung tâm: Gọi API dựa trên Nguyên liệu, Filter và Tên món
  Future<void> searchRecipes({List<String>? ingredients, String? query}) async {
    // Cập nhật state nội bộ nếu có tham số truyền vào
    if (ingredients != null) {
      _currentIngredients = ingredients;
    }
    if (query != null) {
      _currentQuery = query;
    }

    // Nếu không có nguyên liệu và không có từ khóa tìm kiếm thì không chạy (tránh tốn quota API)
    if (_currentIngredients.isEmpty && _currentQuery.isEmpty) return;

    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      print("🔍 Provider đang tìm kiếm: Ingredients=${_currentIngredients.length}, Query=$_currentQuery, Filter=${_currentFilter.cuisine}");
      
      // [QUAN TRỌNG] Gọi hàm searchRecipes mới đã cập nhật ở bước trước
      final results = await _spoonacularService.searchRecipes(
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
        ingredients: _currentIngredients.isNotEmpty ? _currentIngredients : null,
        filter: _currentFilter,
      );

      _recipes = results;

    } catch (e) {
      _errorMessage = e.toString();
      _recipes = []; // Xóa danh sách cũ nếu lỗi
      print("❌ Error fetching recipes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật Filter và tự động tìm kiếm lại
  void updateFilter(RecipeFilter newFilter) {
    _currentFilter = newFilter;
    notifyListeners();
    
    // Gọi lại hàm tìm kiếm với filter mới
    searchRecipes(); 
  }

  // --- 2. LOGIC YÊU THÍCH (FIRESTORE) ---

  // Lắng nghe realtime từ bảng 'favorite_recipes'
  void listenToFavorites() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((userSnapshot) {
      final householdId = userSnapshot.data()?['current_household_id'];

      if (householdId != null) {
        FirebaseFirestore.instance
            .collection('households')
            .doc(householdId)
            .collection('favorite_recipes')
            .orderBy('added_at', descending: true)
            .snapshots()
            .listen((snapshot) {
          _favoriteRecipes = snapshot.docs
              .map((doc) => HouseholdRecipe.fromFirestore(doc))
              .toList();
          notifyListeners();
        }, onError: (e) => print("Lỗi listen Favorites: $e"));
      }
    });
  }

  bool isFavorite(int apiRecipeId) {
    return _favoriteRecipes.any((element) => element.apiRecipeId == apiRecipeId);
  }

  // Thêm/Xóa vào bảng 'favorite_recipes'
  Future<void> toggleFavorite(HouseholdRecipe recipe, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng đăng nhập!")));
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final householdId = userDoc.data()?['current_household_id'];
      if (householdId == null) return;

      final collectionRef = FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('favorite_recipes');

      // Kiểm tra tồn tại
      final existingDocs = await collectionRef
          .where('api_recipe_id', isEqualTo: recipe.apiRecipeId)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        // --- XÓA ---
        for (var doc in existingDocs.docs) {
          await doc.reference.delete();
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã xóa khỏi danh sách yêu thích"), duration: Duration(seconds: 1)),
          );
        }
      } else {
        // --- THÊM MỚI ---
        final recipeToSave = {
          ...recipe.toFirestore(),
          'added_by_uid': user.uid,
          'added_at': FieldValue.serverTimestamp(),
          'is_favorite': true,
        };

        await collectionRef.add(recipeToSave);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã thêm vào yêu thích ❤️"),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xFF1B3B36),
            ),
          );
        }
      }
    } catch (e) {
      print("Lỗi toggle favorite: $e");
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }
}