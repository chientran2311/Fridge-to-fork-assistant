import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Color cardColor = const Color(0xFFE7EEE9);
  final Color textColor = const Color(0xFF214130);

  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =============================
            // HEADER IMAGE + ACTION BUTTONS
            // =============================
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12), // sửa từ 30 → 12
                  ),
                  child: Image.asset(
                    'assets/images/Suggested.png',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),

                // Top buttons
                Positioned(
                  top: 40,
                  left: 15,
                  right: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _rectangleBtn(Icons.arrow_back, textColor),
                      Row(
                        children: [
                          _rectangleBtn(Icons.bookmark_border, textColor),
                          const SizedBox(width: 10),
                          _rectangleBtn(Icons.more_horiz, textColor),
                        ],
                      )
                    ],
                  ),
                ),

                // Drag indicator (giữ rectangular nhưng radius 12)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 45,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(12), // sửa 20 → 12
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // =============================
            // CONTENT CARD
            // =============================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Braised pork",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info Row
                  Row(
                    children: [
                      _infoIcon(Icons.timer, "3h"),
                      const SizedBox(width: 20),
                      _infoIcon(Icons.star, "Hard"),
                      const SizedBox(width: 20),
                      _infoIcon(Icons.local_fire_department, "512 kcal"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    "Lorem Ipsum is simply dummy text of the printing "
                    "and typesetting industry. Lorem Ipsum has been the "
                    "industry's standard dummy text ever since the 1500s",
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Ingredients title
                  Text(
                    "Ingredients",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ingredient Items
                  _ingredientItem(
                    image: "assets/images/pork.png",
                    name: "Pork",
                    amount: "300 g",
                    iconColor: textColor,
                  ),
                  const SizedBox(height: 12),

                  _ingredientItem(
                    image: "assets/images/giavithitkho.png",
                    name: "Knor pack",
                    amount: "100 g",
                    iconColor: textColor,
                  ),
                  const SizedBox(height: 12),

                  _ingredientItem(
                    image: "assets/images/trungga.png",
                    name: "Eggs",
                    amount: "3 eggs",
                    iconColor: textColor,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // WIDGET: Circle Button on Image
  // ==========================================================
 Widget _rectangleBtn(IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12), // nút vuông bo góc 12
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Icon(
      icon,
      color: color,
      size: 22,
    ),
  );
}


  // ==========================================================
  // WIDGET: Info icon row (timer - hard - kcal)
  // ==========================================================
  Widget _infoIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _ingredientItem({
    required String image,
    required String name,
    required String amount,
    required Color iconColor,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            image,
            width: 55,
            height: 55,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle, color: iconColor, size: 24),
      ],
    );
  }
}
