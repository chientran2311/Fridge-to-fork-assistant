import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IngredientsSection extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  final Color mainColor;

  const IngredientsSection({
    super.key,
    required this.ingredients,
    required this.mainColor,
  });

  @override
  State<IngredientsSection> createState() => _IngredientsSectionState();
}

class _IngredientsSectionState extends State<IngredientsSection> {
  late List<bool> _ingredientChecks;
  int _servings = 2; // Initial servings

  @override
  void initState() {
    super.initState();
    // Initialize checks based on the hardcoded values in the original file
    _ingredientChecks = [true, false, false, true, false];
  }

  @override
  Widget build(BuildContext context) {
    final Color greenTagBg = const Color(0xFFE8F5E9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ingredients",
              style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.mainColor),
            ),
            _ServingCounter(
              servings: _servings,
              onRemove: () =>
                  setState(() => _servings > 1 ? _servings-- : null),
              onAdd: () => setState(() => _servings++),
            )
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(widget.ingredients.length, (index) {
          final item = widget.ingredients[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CheckboxListTile(
              activeColor: Colors.green,
              checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              title: Text(
                item['name'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  decoration: _ingredientChecks[index]
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: Colors.grey,
                ),
              ),
              secondary: item['inFridge'] == true
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: greenTagBg,
                          borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.kitchen,
                              size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          const Text("In Fridge",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : null,
              value: _ingredientChecks[index],
              onChanged: (val) {
                setState(() {
                  _ingredientChecks[index] = val!;
                });
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              controlAffinity:
                  ListTileControlAffinity.leading, // Checkbox on the left
            ),
          );
        }),
      ],
    );
  }
}

class _ServingCounter extends StatelessWidget {
  final int servings;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _ServingCounter(
      {required this.servings, required this.onRemove, required this.onAdd});

  Widget _buildServingBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildServingBtn(Icons.remove, onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text("$servings Servings",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          _buildServingBtn(Icons.add, onAdd),
        ],
      ),
    );
  }
}
