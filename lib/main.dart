import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import màn hình AddRecipeScreen để demo
import 'screens/meal&plan/tabs/weekly_plan/add_recipe_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo AddRecipeScreen',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF214130),
          primary: const Color(0xFF214130),
        ),
        fontFamily: 'Merriweather',
      ),
      home: const DemoAddRecipeScreen(),
    );
  }
}

// Widget demo với dữ liệu mẫu
class DemoAddRecipeScreen extends StatefulWidget {
  const DemoAddRecipeScreen({super.key});

  @override
  State<DemoAddRecipeScreen> createState() => _DemoAddRecipeScreenState();
}

class _DemoAddRecipeScreenState extends State<DemoAddRecipeScreen> {
  // Dữ liệu mẫu cho demo
  final List<Map<String, dynamic>> demoRecipes = [
    {
      'id': 'recipe1',
      'title': 'Phở Bò Truyền Thống',
      'image': 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
      'calories': 450,
      'isFavorite': true,
      'isFromApi': false,
    },
    {
      'id': 'recipe2',
      'title': 'Cơm Tấm Sườn Nướng',
      'image': 'https://images.unsplash.com/photo-1626804475297-41608ea09aeb?w=400',
      'calories': 620,
      'isFavorite': true,
      'isFromApi': false,
    },
    {
      'id': 'recipe3',
      'title': 'Bún Chả Hà Nội',
      'image': 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400',
      'calories': 520,
      'isFavorite': false,
      'isFromApi': true,
    },
    {
      'id': 'recipe4',
      'title': 'Bánh Mì Thịt Nguội',
      'image': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400',
      'calories': 380,
      'isFavorite': true,
      'isFromApi': false,
    },
    {
      'id': 'recipe5',
      'title': 'Gỏi Cuốn Tôm Thịt',
      'image': 'https://images.unsplash.com/photo-1594756202469-9ff9799b2e4e?w=400',
      'calories': 180,
      'isFavorite': false,
      'isFromApi': true,
    },
    {
      'id': 'recipe6',
      'title': 'Bún Bò Huế',
      'image': 'https://images.unsplash.com/photo-1604908815328-59e50946db99?w=400',
      'calories': 550,
      'isFavorite': true,
      'isFromApi': false,
    },
    {
      'id': 'recipe7',
      'title': 'Cá Kho Tộ',
      'image': 'https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=400',
      'calories': 320,
      'isFavorite': false,
      'isFromApi': true,
    },
    {
      'id': 'recipe8',
      'title': 'Thịt Kho Trứng',
      'image': 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400',
      'calories': 480,
      'isFavorite': true,
      'isFromApi': false,
    },
  ];

  // Danh sách kế hoạch đã thêm (để hiển thị khi thành công)
  final List<Map<String, dynamic>> addedMealPlans = [];

  void _handleAddMealPlan(
    DateTime date,
    String recipeId,
    String mealType,
    int servings,
  ) async {
    // Tìm recipe từ ID
    final recipe = demoRecipes.firstWhere((r) => r['id'] == recipeId);
    
    // Thêm vào danh sách kế hoạch
    setState(() {
      addedMealPlans.add({
        'date': date,
        'recipeTitle': recipe['title'],
        'mealType': mealType,
        'servings': servings,
      });
    });

    // Hiển thị thông báo thành công
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Đã thêm "${recipe['title']}" vào kế hoạch!',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF214130),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo - Thêm Công Thức'),
        backgroundColor: const Color(0xFF214130),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Hiển thị danh sách đã thêm
          if (addedMealPlans.isNotEmpty)
            Container(
              color: const Color(0xFF214130).withOpacity(0.05),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Kế hoạch đã thêm:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...addedMealPlans.map((plan) {
                    final mealTypeVi = {
                      'breakfast': 'Bữa sáng',
                      'lunch': 'Bữa trưa',
                      'dinner': 'Bữa tối',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${plan['recipeTitle']} - ${mealTypeVi[plan['mealType']]} '
                        '(${plan['servings']} phần) - ${plan['date'].day}/${plan['date'].month}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          // Màn hình AddRecipeScreen
          Expanded(
            child: AddRecipeScreen(
              selectedDate: DateTime.now(),
              recipes: demoRecipes,
              onAddMealPlan: _handleAddMealPlan,
            ),
          ),
        ],
      ),
    );
  }
}

