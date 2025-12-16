import 'package:flutter/material.dart';

import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import '../../widgets/recipe/ai_recipe/ai_recipe_header.dart';
import '../../widgets/recipe/ai_recipe/recipe_card.dart';


class AIRecipeScreen extends StatefulWidget {
  const AIRecipeScreen({super.key});

  @override
  State<AIRecipeScreen> createState() => _AIRecipeScreenState();
}

class _AIRecipeScreenState extends State<AIRecipeScreen> {
  // Dữ liệu mẫu y hệt trong ảnh
  final List<Map<String, dynamic>> recipes = [
    {
      "image":
          "https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=600&auto=format&fit=crop", // Ảnh Pasta Bơ
      "matchTag": "100% Match",
      "tagIcon": Icons.check_circle_outline,
      "title": "Creamy Avocado & Spinach Pesto Pasta",
      "desc":
          "A quick, protein-packed breakfast perfectly using your leftover sourdough.",
      "time": "15 min",
      "kcal": "320 kcal",
      "missing": 0,
      "isUrgent": false,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1626844131082-256783844137?q=80&w=600&auto=format&fit=crop", // Ảnh Pasta Lemon Basil
      "matchTag": "Use Basil Soon",
      "tagIcon": Icons.access_time,
      "title": "Zesty Lemon Basil Pasta",
      "desc": "Fresh and light dinner. Use up that basil before it wilts!",
      "time": "25 min",
      "kcal": "500 kcal",
      "missing": 1,
      "isUrgent": true, // Để đổi màu badge
    },
    {
      "image":
          "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=600&auto=format&fit=crop", // Ảnh Rau củ xào
      "matchTag": "100% Match",
      "tagIcon": Icons.check_circle_outline,
      "title": "Zero-Waste Veggie Stir-fry",
      "desc": "Delicious way to clear out the fridge veggies in one go.",
      "time": "20 min",
      "kcal": "410 kcal",
      "missing": 0,
      "isUrgent": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // Để bottom nav nổi đẹp như thiết kế trước
      body: SafeArea(
        bottom: false, // Để nội dung tràn xuống dưới bottom nav
        child: ResponsiveLayout(
          // --- MOBILE: Dạng list dọc ---
          mobileBody: _buildContent(isGrid: false),

          // --- TABLET/WEB: Dạng lưới 2 cột ---
          desktopBody: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: _buildContent(isGrid: true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required bool isGrid}) {
    // Header + Banner + List
    return CustomScrollView(
      slivers: [
        // 1. Header & Banner
        const SliverToBoxAdapter(
          child: AIRecipeHeader(),
        ),

        // 2. Recipe List (Grid hoặc List)
        isGrid
            ? SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cột cho Desktop/Tablet
                    childAspectRatio: 0.85, // Tỷ lệ khung hình
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RecipeCard(data: recipes[index]),
                    childCount: recipes.length,
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                    child: RecipeCard(data: recipes[index]),
                  ),
                  childCount: recipes.length,
                ),
              ),

        // Khoảng trống dưới cùng để không bị BottomNav che mất nội dung cuối
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
