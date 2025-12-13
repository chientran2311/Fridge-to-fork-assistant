import 'package:flutter/material.dart';
import 'detail_recipe.dart';
import '../../widgets/recipe/search_bar.dart';
import '../../widgets/recipe/recipe_card.dart';
import '../../widgets/recipe/section_title.dart';
import '../../widgets/recipe/bottom_nav.dart';
// Import file responsive layout nếu cần check logic mobile/tablet
import '../../utils/responsive_layout.dart'; 

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
    const Color textColor = Color(0xFF214130);

    return Scaffold(
      backgroundColor: bgColor,
      // 1. Dùng SafeArea bọc ngoài cùng
      body: SafeArea(
        // 2. Căn giữa màn hình cho giao diện Web/Tablet
        child: Center(
          // 3. Giới hạn chiều rộng (600px là đẹp cho dạng List)
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Stack(
              children: [
                // --- LỚP 1: NỘI DUNG CUỘN ---
                Positioned.fill(
                  child: SingleChildScrollView(
                    // Thêm padding đáy để nội dung cuối không bị BottomNav che mất
                    padding: const EdgeInsets.only(bottom: 100), 
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
                        
                        // Bạn có thể thêm nhiều RecipeCard ở đây để test scroll
                        const SizedBox(height: 16),
                        const Padding(
                           padding: EdgeInsets.symmetric(horizontal: 16),
                           child: RecipeCard(), // Test cái thứ 2
                        ),
                      ],
                    ),
                  ),
                ),

                // --- LỚP 2: THANH ĐIỀU HƯỚNG (Ghim đáy) ---
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomNav(textColor: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}