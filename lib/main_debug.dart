import 'package:flutter/material.dart';
import 'screens/meal&plan/tabs/weekly_plan/add_recipe_screen.dart';

void main() {
  runApp(const MyDebugApp());
}

class MyDebugApp extends StatelessWidget {
  const MyDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Add Recipe Screen Debug',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0FBD3B),
          primary: const Color(0xFF0FBD3B),
          secondary: const Color(0xFFFF9F1C),
          surface: Colors.white,
        ),
        fontFamily: 'Merriweather',
      ),
      home: AddRecipeScreen(
        selectedDate: DateTime.now(),
        recipes: _getSampleRecipes(),
        onAddMealPlan: (date, recipeId, mealType, servings) async {
          debugPrint('✅ Added meal plan:');
          debugPrint('  Date: $date');
          debugPrint('  Recipe ID: $recipeId');
          debugPrint('  Meal Type: $mealType');
          debugPrint('  Servings: $servings');
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getSampleRecipes() {
    return [
      {
        'id': 'recipe_1',
        'title': 'Phở Bò Truyền Thống',
        'image': 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
        'calories': 450,
        'isFavorite': true,
        'isFromApi': false,
      },
      {
        'id': 'recipe_2',
        'title': 'Bún Chả Hà Nội',
        'image': 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400',
        'calories': 520,
        'isFavorite': true,
        'isFromApi': false,
      },
      {
        'id': 'recipe_3',
        'title': 'Gỏi Cuốn Tôm Thịt',
        'image': 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400',
        'calories': 280,
        'isFavorite': false,
        'isFromApi': true,
      },
      {
        'id': 'recipe_4',
        'title': 'Cơm Tấm Sườn Bì',
        'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
        'calories': 680,
        'isFavorite': false,
        'isFromApi': true,
      },
      {
        'id': 'recipe_5',
        'title': 'Bánh Mì Thịt Nướng',
        'image': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400',
        'calories': 420,
        'isFavorite': true,
        'isFromApi': false,
      },
      {
        'id': 'recipe_6',
        'title': 'Canh Chua Cá Lóc',
        'image': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
        'calories': 320,
        'isFavorite': false,
        'isFromApi': true,
      },
      {
        'id': 'recipe_7',
        'title': 'Bò Lúc Lắc',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        'calories': 580,
        'isFavorite': false,
        'isFromApi': false,
      },
      {
        'id': 'recipe_8',
        'title': 'Mì Quảng',
        'image': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
        'calories': 490,
        'isFavorite': true,
        'isFromApi': false,
      },
    ];
  }
}
