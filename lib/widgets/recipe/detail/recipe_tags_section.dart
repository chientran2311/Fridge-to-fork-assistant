import 'package:flutter/material.dart';
import '../ai_recipe/info_chip.dart';

class RecipeTagsSection extends StatelessWidget {
  const RecipeTagsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36);
    final Color greenTagBg = const Color(0xFFE8F5E9);
    final Color orangeTagBg = const Color(0xFFFFF3E0);
    final Color blueTagBg = const Color(0xFFE3F2FD);

    return Row(
      children: [
        InfoChip(
          icon: Icons.access_time,
          text: "15 Mins",
          backgroundColor: greenTagBg,
          textColor: mainColor,
          iconColor: mainColor,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          iconSize: 16,
        ),
        const SizedBox(width: 12),
        InfoChip(
          icon: Icons.bolt,
          text: "Easy",
          backgroundColor: orangeTagBg,
          textColor: Colors.orange[800]!,
          iconColor: Colors.orange[800]!,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          iconSize: 16,
        ),
        const SizedBox(width: 12),
        InfoChip(
          icon: Icons.local_fire_department_outlined,
          text: "320 Kcal",
          backgroundColor: blueTagBg,
          textColor: Colors.blue[800]!,
          iconColor: Colors.blue[800]!,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          iconSize: 16,
        ),
      ],
    );
  }
}
