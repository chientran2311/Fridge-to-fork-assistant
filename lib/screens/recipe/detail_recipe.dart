import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/widgets/common/primary_button.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/detail/ingredients_section.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/detail/instructions_section.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/detail/recipe_detail_app_bar.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/detail/recipe_tags_section.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/detail/recipe_title_section.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // Màu sắc chủ đạo
  final Color mainColor = const Color(0xFF1B3B36);

  // Dữ liệu mẫu (Hardcode theo ảnh)
  final List<Map<String, dynamic>> ingredients = [
    {"name": "2 ripe Avocados", "inFridge": true},
    {"name": "200g Spinach", "inFridge": false},
    {"name": "500g Pasta", "inFridge": false},
    {"name": "1 Lemon", "inFridge": true},
    {"name": "3 Garlic Cloves", "inFridge": false},
  ];

  final List<String> instructions = [
    "Boil the pasta in salted water according to the package instructions until al dente. Reserve 1/2 cup of pasta water before draining.",
    "While pasta cooks, combine avocado, spinach, lemon juice, garlic, and olive oil in a blender. Blend until smooth and creamy.",
    "Drain the pasta and return it to the pot. Pour the green sauce over the pasta. Add the reserved pasta water a little at a time to loosen the sauce if needed.",
    "Toss gently until well coated. Season with salt and pepper to taste. Serve immediately topped with optional parmesan or pine nuts."
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: PrimaryButton(
          text: "Add to calendar",
          icon: Icons.calendar_today_outlined,
          onPressed: () { /* Add to calendar logic */ },
          backgroundColor: mainColor,
        ),
      ),
      body: ResponsiveLayout(
        // --- MOBILE LAYOUT ---
        mobileBody: _buildContent(),

        // --- WEB/DESKTOP LAYOUT ---
        desktopBody: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        const RecipeDetailAppBar(
          imageUrl:
              "https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=600&auto=format&fit=crop",
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            transform: Matrix4.translationValues(0, -30, 0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecipeTitleSection(
                  title: "Creamy Avocado & Spinach Pesto Pasta",
                  author: "By GreenChef • Italian Inspired",
                  mainColor: mainColor,
                ),
                const RecipeTagsSection(),
                const SizedBox(height: 32),
                IngredientsSection(
                  ingredients: ingredients,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 32),
                InstructionsSection(
                  instructions: instructions,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )
      ],
    );
  }
}
