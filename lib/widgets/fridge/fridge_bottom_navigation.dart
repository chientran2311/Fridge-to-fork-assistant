import 'package:flutter/material.dart';

class FridgeBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const FridgeBottomNavigation({
    super.key,
    this.currentIndex = 0,  // Default value
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.kitchen_outlined,
                label: 'Fridge',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.restaurant_menu_outlined,
                label: 'Recipes',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.list_alt_outlined,
                label: 'Lists',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    
    return InkWell(
      onTap: onTap != null ? () => onTap!(index) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF2D5F4F) : const Color(0xFFB0B0B0),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF2D5F4F) : const Color(0xFFB0B0B0),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}