import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/recipe/search_bar.dart';
import '../../widgets/recipe/recipe_card.dart';
import '../../widgets/recipe/section_title.dart';
import '../../widgets/recipe/bottom_nav.dart';

class AiRecipeScreen extends StatefulWidget {
  const AiRecipeScreen({super.key});

  @override
  State<AiRecipeScreen> createState() => _AiRecipeScreenState();
}

class _AiRecipeScreenState extends State<AiRecipeScreen> {
  
  // 🔥 Controller để đọc text người dùng nhập
  final TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF0F1F1);
    const Color textColor = Color(0xFF214130);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🟢 Search bar cần controller — đã truyền vào
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

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: RecipeCard(),
            ),

            const Spacer(),

            BottomNav(textColor: textColor),
          ],
        ),
      ),
    );
  }
}
