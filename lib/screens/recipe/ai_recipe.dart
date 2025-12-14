import 'package:flutter/material.dart';
import 'detail_recipe.dart';
import '../../widgets/recipe/search_bar.dart';
import '../../widgets/recipe/recipe_card.dart';
import '../../widgets/recipe/section_title.dart';
// import '../../widgets/recipe/bottom_nav.dart'; // ❌ BỎ DÒNG NÀY (Tránh vòng lặp)

class AiRecipeScreen extends StatefulWidget {
  const AiRecipeScreen({super.key});

  @override
  State<AiRecipeScreen> createState() => _AiRecipeScreenState();
}

class _AiRecipeScreenState extends State<AiRecipeScreen> {
  final TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF0F1F1);
    // const Color textColor = Color(0xFF214130); // Không cần dùng biến này nữa

    return Scaffold(
      backgroundColor: bgColor,
      // 1. Dùng SafeArea bọc ngoài cùng
      body: SafeArea(
        // 2. Căn giữa màn hình cho giao diện Web/Tablet
        child: Center(
          // 3. Giới hạn chiều rộng
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            // ⭐ QUAN TRỌNG: Bỏ Stack và BottomNav đi.
            // Vì màn hình này sẽ được nhúng vào trong BottomNav.dart,
            // nên nó không cần tự vẽ thanh điều hướng nữa.
            child: SingleChildScrollView(
              // Thêm padding đáy lớn (100px) để nội dung cuối cùng 
              // không bị thanh menu của màn hình cha che mất.
              padding: const EdgeInsets.only(bottom: 120), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SearchBarWidget(controller: searchCtrl),
                  ),

                  const SizedBox(height: 10),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SectionTitle(title: "Suggested Recipes"),
                  ),

                  const SizedBox(height: 10),

                  // Danh sách Recipes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecipeDetailScreen(),
                          ),
                        );
                      },
                      child: const RecipeCard(),
                    ),
                  ),
                  
                  // Test thêm thẻ thứ 2 để cuộn
                  const SizedBox(height: 16),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: RecipeCard(), 
                  ),
                   const SizedBox(height: 16),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: RecipeCard(), 
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}