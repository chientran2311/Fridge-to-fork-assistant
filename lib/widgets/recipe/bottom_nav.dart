import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNav extends StatelessWidget {
  final Color textColor;

  const BottomNav({super.key, required this.textColor});

  @override
  Widget build(BuildContext context) {
    const Color navigatorColor = Color(0xFFE7EAE9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: navigatorColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AnimatedNavButton(
            icon: Icons.kitchen,
            label: "Fridge",
            color: textColor,
            onTap: () => print("Fridge tapped"),
          ),
          AnimatedNavButton(
            icon: Icons.menu_book_rounded,
            label: "AI Recipe",
            color: textColor,
            onTap: () => print("AI Recipe tapped"),
          ),
          AnimatedNavButton(
            icon: Icons.shopping_bag_outlined,
            label: "Plan&Shop",
            color: textColor,
            onTap: () => print("Plan&Shop tapped"),
          ),
        ],
      ),
    );
  }
}

class AnimatedNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const AnimatedNavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<AnimatedNavButton> createState() => _AnimatedNavButtonState();
}

class _AnimatedNavButtonState extends State<AnimatedNavButton> {
  double scale = 1.0;

  void _animate() async {
    setState(() => scale = 0.88);
    await Future.delayed(const Duration(milliseconds: 80));
    setState(() => scale = 1.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animate,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 26, color: widget.color),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: GoogleFonts.merriweather(
                fontSize: 12,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
