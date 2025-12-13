import 'package:flutter/material.dart';
import 'plan_add_ingredients.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final List<_Ingredient> _ingredients = [
    _Ingredient(name: "Pork", amount: "200 g", isChecked: true),
    _Ingredient(name: "Garlic", amount: "20 g", isChecked: true),
    _Ingredient(name: "Green onion", amount: "1 bunch"),
    _Ingredient(name: "Carrot", amount: "2 pcs", isChecked: true),
  ];

  void _toggleIngredient(int index) {
    setState(() {
      _ingredients[index].isChecked = !_ingredients[index].isChecked;
    });
  }

  void _showAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FridgeAddIngredients(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F1),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 360,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/photo-1546069901-ba9599a7e63c.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: topPadding + 16,
                        left: 16,
                        child: _floatingButton(
                          icon: Icons.arrow_back,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        top: topPadding + 16,
                        right: 16,
                        child: _floatingButton(
                          icon: Icons.bookmark_border,
                          onPressed: () {
                            // TODO: Add save action
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F1F1),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                      Text(
                        "Chicken Soup",
                        style: GoogleFonts.merriweather(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff214d34),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 20, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text("1h", style: GoogleFonts.merriweather()),
                          const SizedBox(width: 16),
                          const Icon(Icons.bar_chart, size: 20, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text("Medium", style: GoogleFonts.merriweather()),
                          const SizedBox(width: 16),
                          const Icon(Icons.local_fire_department, size: 20, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text("520 kcal", style: GoogleFonts.merriweather()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Lorem Ipsum is simply dummy text of the printing and "
                        "typesetting industry. Lorem Ipsum has been the industry's "
                        "standard dummy text ever since the 1500s.",
                        style: GoogleFonts.merriweather(fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Ingredients",
                              style: GoogleFonts.merriweather(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff214d34),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showAdd,
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xff214d34)),
                            label: Text(
                              "Add",
                              style: GoogleFonts.merriweather(
                                color: const Color(0xff214d34),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${_ingredients.where((item) => item.isChecked).length} out of ${_ingredients.length} ingredients available",
                        style: GoogleFonts.merriweather(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: List.generate(
                          _ingredients.length,
                          (index) {
                            final ingredient = _ingredients[index];
                            return _buildIngredientRow(ingredient, index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(_Ingredient ingredient, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage("assets/images/photo-1546069901-ba9599a7e63c.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ingredient.name,
                style: GoogleFonts.merriweather(
                  color: const Color(0xff214d34),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ingredient.amount,
                style: GoogleFonts.merriweather(color: Colors.black54),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _toggleIngredient(index),
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ingredient.isChecked ? const Color(0xff214d34) : Colors.transparent,
                border: Border.all(
                  color: const Color(0xff214d34),
                  width: 2,
                ),
              ),
              child: ingredient.isChecked
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAE9),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xff214d34)),
        onPressed: onPressed,
      ),
    );
  }
}

class _Ingredient {
  final String name;
  final String amount;
  bool isChecked;

  _Ingredient({
    required this.name,
    required this.amount,
    this.isChecked = false,
  });
}
