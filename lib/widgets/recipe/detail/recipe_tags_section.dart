import 'package:flutter/material.dart';

class RecipeTagsSection extends StatelessWidget {
  final int readyInMinutes;
  final int servings;

  const RecipeTagsSection({
    super.key,
    this.readyInMinutes = 0,
    this.servings = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTag(Icons.timer_outlined, "$readyInMinutes mins"),
        const SizedBox(width: 16),
        _buildTag(Icons.people_outline, "$servings servings"),
        // Có thể thêm HealthScore hoặc Price nếu muốn
      ],
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}