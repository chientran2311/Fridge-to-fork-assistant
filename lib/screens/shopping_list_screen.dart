import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xfff4f5f2),

      body: Stack(
        children: [
          // ---------- MAIN CONTENT ----------
          Padding(
            // leave space for status bar + back button + a bit before title
            padding: EdgeInsets.only(
              top: topPadding + 12,
            ),
            child: Column(
              children: [
                // Title
                const Text(
                  "Shopping list",
                  style: TextStyle(
                    color: Color(0xff214d34),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Merriweather',
                  ),
                ),
                const SizedBox(height: 4),

                // Date
                const Text(
                  "9, September 2025",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontFamily: 'Merriweather',
                  ),
                ),
                const SizedBox(height: 16),

                // Cards
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      buildCard(
                        context,
                        "Braised pork",
                        "3 ingredients left",
                        navigateToDetail: true,
                      ),
                      buildCard(
                        context,
                        "Banh mi",
                        "5 ingredients left",
                        navigateToDetail: true,
                      ),
                      buildCard(
                        context,
                        "Chicken soup",
                        "3 ingredients left",
                        navigateToDetail: true,
                      ),
                      buildCard(
                        context,
                        "Extra",
                        "2 ingredients left",
                        navigateToDetail: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---------- FIGMA-STYLE BACK BUTTON ----------
          Positioned(
            top: topPadding + 12, // just under the status bar, like screenshot
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
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // CARD BUILDER
  // ----------------------------------------------------------
  Widget buildCard(
    BuildContext context,
    String title,
    String subtitle, {
    bool navigateToDetail = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (navigateToDetail) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecipeDetailScreen(),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE7EAE9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_box_outline_blank,
              color: Color(0xff214d34),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xff214d34),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Merriweather',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontFamily: 'Merriweather',
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.delete_outline,
              color: Color(0xff214d34),
            ),
          ],
        ),
      ),
    );
  }
}
