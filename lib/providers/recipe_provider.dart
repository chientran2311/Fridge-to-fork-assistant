import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/household_recipe.dart';
import '../data/repositories/recipe_repository.dart'; // [Thay đổi] Dùng Repo
import '../data/services/spoonacular_service.dart'; // ✅ Add for direct API call
import '../models/RecipeFilter.dart';

class RecipeProvider extends ChangeNotifier {
  // [Thay đổi] Sử dụng Repository thay vì Service trực tiếp
  final RecipeRepository _recipeRepository = RecipeRepository();

  // --- STATE ---
  List<HouseholdRecipe> _recipes = [];
  List<HouseholdRecipe> _favoriteRecipes = [];
  List<HouseholdRecipe> _recommendedRecipes = []; // [Mới] List gợi ý thông minh

  RecipeFilter _currentFilter = RecipeFilter();
  List<String> _currentIngredients = [];
  String _currentQuery = "";

  bool _isLoading = false;
  String _errorMessage = "";

  // --- GETTERS ---
  List<HouseholdRecipe> get recipes => _recipes;
  List<HouseholdRecipe> get favoriteRecipes => _favoriteRecipes;
  List<HouseholdRecipe> get recommendedRecipes => _recommendedRecipes; // [Mới]

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage.isNotEmpty ? _errorMessage : null;
  RecipeFilter get currentFilter => _currentFilter;

  // --- 1. LOGIC TÌM KIẾM (Search & Filter) ---

  Future<void> searchRecipes({List<String>? ingredients, String? query}) async {
    if (ingredients != null) _currentIngredients = ingredients;
    if (query != null) _currentQuery = query;

    if (_currentIngredients.isEmpty && _currentQuery.isEmpty) return;

    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      print("🔍 Provider: Searching via Repository...");

      // Gọi qua Repository
      final results = await _recipeRepository.searchRecipes(
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
        ingredients:
            _currentIngredients.isNotEmpty ? _currentIngredients : null,
        filter: _currentFilter,
      );

      _recipes = results;
    } catch (e) {
      _errorMessage = e.toString();
      _recipes = [];
      print("❌ Error fetching recipes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFilter(RecipeFilter newFilter) {
    _currentFilter = newFilter;
    notifyListeners();
    searchRecipes();
  }

  // --- [MỚI] 2. LOGIC GỢI Ý THÔNG MINH (Fetch History -> AI) ---
  Future<void> fetchSmartRecommendations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Không set isLoading toàn cục để tránh xoay cả màn hình nếu đang xem tab khác
    // Hoặc set loading cục bộ nếu cần thiết. Ở đây tôi set nhẹ để UI biết.
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Lấy Household ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final householdId = userDoc.data()?['current_household_id'];

      if (householdId == null) throw Exception("Chưa tham gia Household");

      // 2. Chuẩn bị dữ liệu Favorites (Lấy top 10 món mới nhất)
      final favTitles = _favoriteRecipes.take(10).map((e) => e.title).toList();

      // 3. Chuẩn bị dữ liệu Cooking History (Fetch từ Firestore)
      // Giả sử bảng cooking_history nằm trong household
      final historySnapshot = await FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('cooking_history')
          .orderBy('cooked_at', descending: true)
          .limit(10)
          .get();

      final historyTitles = historySnapshot.docs
          .map((doc) => doc.data()['title'] as String? ?? "")
          .where((t) => t.isNotEmpty)
          .toList();

      // 4. Gọi Repository xử lý (AI + Search)
      _recommendedRecipes = await _recipeRepository.getSmartRecommendations(
        favoriteTitles: favTitles,
        historyTitles: historyTitles,
      );
    } catch (e) {
      print("❌ Lỗi fetchSmartRecommendations: $e");
      // Không gán vào _errorMessage chính để tránh hiện lỗi đỏ lòm khi chỉ là tính năng gợi ý
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 3. LOGIC YÊU THÍCH (FIRESTORE) ---
  // (Giữ nguyên code cũ của bạn)
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
    return _favoriteRecipes
        .any((element) => element.apiRecipeId == apiRecipeId);
  }

  Future<void> toggleFavorite(
      HouseholdRecipe recipe, BuildContext context) async {
    // (Giữ nguyên logic cũ của bạn)
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Vui lòng đăng nhập!")));
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final householdId = userDoc.data()?['current_household_id'];
      if (householdId == null) return;

      final collectionRef = FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('favorite_recipes');

      final existingDocs = await collectionRef
          .where('api_recipe_id', isEqualTo: recipe.apiRecipeId)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        for (var doc in existingDocs.docs) {
          await doc.reference.delete();
        }
        
        // ✅ Remove from local _recipes list
        _recipes.removeWhere((r) => r.apiRecipeId == recipe.apiRecipeId);
        notifyListeners();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Đã xóa khỏi danh sách yêu thích"),
                duration: Duration(seconds: 1)),
          );
        }
      } else {
        // ✅ Fetch full recipe details from API before saving
        HouseholdRecipe recipeToSave = recipe;

        if (recipe.instructions == null ||
            recipe.ingredients == null ||
            recipe.instructions!.isEmpty ||
            recipe.ingredients!.isEmpty) {
          debugPrint(
              '🌐 Fetching full recipe details from API for favorite: ${recipe.apiRecipeId}');

          try {
            final spoonacularService = SpoonacularService();
            final fullData = await spoonacularService
                .getRecipeInformation(recipe.apiRecipeId);

            if (fullData != null) {
              List<Map<String, dynamic>> fullIngredients = [];
              String fullInstructions = '';

              // Parse ingredients
              if (fullData['extendedIngredients'] != null) {
                final List<dynamic> rawIngs = fullData['extendedIngredients'];
                fullIngredients = rawIngs.map((ing) {
                  return {
                    'name': ing['name'] ?? '',
                    'amount': (ing['amount'] as num?)?.toDouble() ?? 0.0,
                    'unit': ing['unit'] ?? '',
                    'original': ing['original'] ?? '',
                  };
                }).toList();
                debugPrint(
                    '   ✅ Loaded ${fullIngredients.length} ingredients for favorite');
              }

              // Parse instructions
              if (fullData['analyzedInstructions'] != null &&
                  (fullData['analyzedInstructions'] as List).isNotEmpty) {
                final List steps = fullData['analyzedInstructions'][0]['steps'];
                fullInstructions = steps
                    .map<String>((step) => step['step'].toString())
                    .join('\n');
                debugPrint('   ✅ Loaded instructions for favorite');
              } else if (fullData['instructions'] != null) {
                fullInstructions = fullData['instructions'].toString();
                debugPrint('   ✅ Loaded raw instructions for favorite');
              }

              // Create new recipe with full data
              recipeToSave = HouseholdRecipe(
                localRecipeId: recipe.localRecipeId,
                householdId: householdId,
                apiRecipeId: recipe.apiRecipeId,
                title: recipe.title,
                imageUrl: recipe.imageUrl,
                readyInMinutes: recipe.readyInMinutes,
                servings: recipe.servings,
                calories: recipe.calories,
                difficulty: recipe.difficulty,
                instructions: fullInstructions,
                ingredients: fullIngredients,
                addedByUid: user.uid,
                usedIngredientCount: recipe.usedIngredientCount,
                missedIngredientCount: recipe.missedIngredientCount,
              );
            }
          } catch (e) {
            debugPrint(
                '⚠️ Error fetching full recipe details for favorite: $e');
            // Continue with original recipe data
          }
        }

        final recipeData = {
          ...recipeToSave.toFirestore(),
          'added_by_uid': user.uid,
          'added_at': FieldValue.serverTimestamp(),
          'is_favorite': true,
        };

        await collectionRef.add(recipeData);

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }
}
