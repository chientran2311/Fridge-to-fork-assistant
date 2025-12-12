import 'package:flutter/material.dart';

class IngredientListItem extends StatelessWidget {
  final String name;
  final Color mainColor;
  final VoidCallback onAddPressed;

  const IngredientListItem({
    super.key,
    required this.name,
    required this.mainColor,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Large rounded image placeholder
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(width: 16),

          // Name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          // Plus button
          SizedBox(
            width: 40,
            height: 40,
            child: TextButton(
              onPressed: onAddPressed,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFFE7EAE9),
              ),
              child: Icon(
                Icons.add,
                size: 20,
                color: mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}