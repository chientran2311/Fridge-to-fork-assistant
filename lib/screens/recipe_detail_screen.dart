import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ingredients = [
      (name: "Pork", amount: "200 g", available: true),
      (name: "Pork", amount: "200 g", available: false),
      (name: "Pork", amount: "200 g", available: true),
      (name: "Pork", amount: "200 g", available: false),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image header with overlay back button
            Stack(
  children: [
    SizedBox(
      width: double.infinity,
      height: 360,
      child: Image.asset(
        "assets/images/photo-1546069901-ba9599a7e63c.jpg",
        fit: BoxFit.cover,
      ),
    ),

    // BACK BUTTON (Figma style)
    Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff214d34)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    ),

    // SAVE BUTTON (Bookmark)
    Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.bookmark_border, color: Color(0xff214d34)),
          onPressed: () {
            // TODO: Add save action
          },
        ),
      ),
    ),
  ],
),
            // Content card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F1F1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    "Chicken Soup",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff214d34),
                      fontFamily: 'Merriweather',
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: const [
                      Icon(Icons.timer, size: 20, color: Colors.black54),
                      SizedBox(width: 6),
                      Text("1h"),
                      SizedBox(width: 16),
                      Icon(Icons.bar_chart, size: 20, color: Colors.black54),
                      SizedBox(width: 6),
                      Text("Medium"),
                      SizedBox(width: 16),
                      Icon(Icons.local_fire_department, size: 20, color: Colors.black54),
                      SizedBox(width: 6),
                      Text("520 kcal"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Lorem Ipsum is simply dummy text of the printing and "
                    "typesetting industry. Lorem Ipsum has been the industry's "
                    "standard dummy text ever since the 1500s.",
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          "Ingredients",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff214d34),
                            fontFamily: 'Merriweather',
                          ),
                        ),
                      ),
                      Icon(Icons.add_circle_outline, color: Color(0xff214d34), size: 28),
                    ],
                  ),
                  const SizedBox(height: 6),

                  const Text(
                    "3 out of 6 ingredients available",
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 20),

                  ...ingredients.map(
                    (item) => buildIngredient(
                      name: item.name,
                      amount: item.amount,
                      available: item.available,
                      imagePath: "assets/images/photo-1546069901-ba9599a7e63c.jpg",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIngredient({
    required String name,
    required String amount,
    required bool available,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xff214d34),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Merriweather',
                ),
              ),
              Text(
                amount,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              available ? Icons.check_circle : Icons.add_circle_outline,
              color: const Color(0xff214d34),
              size: 26,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
