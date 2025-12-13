import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../screens/fridge/fridge_home.dart';
import '../../screens/meal&plan/plan_shopping_plan.dart';
import '../../screens/recipe/ai_recipe.dart';
import '../../utils/responsive_layout.dart'; // Import file Responsive

class BottomNav extends StatefulWidget {
  final int initialIndex;
  final Color activeColor;

  const BottomNav({
    super.key,
    this.initialIndex = 0,
    this.activeColor = const Color(0xFF214130),
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const FridgeHomeScreen(),
      const AiRecipeScreen(),
      const ShoppingPlanScreen(),
    ];
    _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1).toInt();
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Gọi ResponsiveLayout ở đây
    return ResponsiveLayout(
      mobileBody: _buildScaffold(isMobile: true),
      tabletBody: _buildScaffold(isMobile: false),
      desktopBody: _buildScaffold(isMobile: false),
    );
  }

  // Tách Scaffold ra thành hàm riêng để tái sử dụng
  Widget _buildScaffold({required bool isMobile}) {
    final Color inactiveColor = widget.activeColor.withOpacity(0.5);

    const navItems = <_NavItem>[
      _NavItem(Icons.kitchen, 'Fridge'),
      _NavItem(Icons.menu_book_rounded, 'AI Recipe'),
      _NavItem(Icons.shopping_bag_outlined, 'Plan&Shop'),
    ];

    // Scaffold chính
    var scaffold = Scaffold(
      extendBody: true,
      // Body là các màn hình con
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
        child: Container(
          // Nếu là Desktop/Tablet thì giới hạn chiều rộng thanh điều hướng
          // để nó không bị kéo dài hết màn hình 1920px
          constraints: const BoxConstraints(maxWidth: 500), 
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(navItems.length, (index) {
              final isActive = index == _currentIndex;
              final item = navItems[index];
              return AnimatedNavButton(
                icon: item.icon,
                label: item.label,
                isActive: isActive,
                activeColor: widget.activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _onItemTapped(index),
              );
            }),
          ),
        ),
      ),
    );

    // LOGIC WRAPPER:
    // Nếu là Mobile: Trả về Scaffold full màn hình.
    if (isMobile) {
      return scaffold;
    } 
    
    // Nếu là Tablet/Desktop: 
    // Bọc Scaffold trong Center + ConstrainedBox để tạo giao diện dạng "Mobile App on Web"
    return Scaffold(
      backgroundColor: Colors.grey[200], // Màu nền xám nhẹ cho phần thừa ra 2 bên
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500), // Giới hạn chiều rộng App
          child: scaffold, // Nhúng App vào giữa
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}

class AnimatedNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const AnimatedNavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  State<AnimatedNavButton> createState() => _AnimatedNavButtonState();
}

class _AnimatedNavButtonState extends State<AnimatedNavButton> {
  double scale = 1.0;

  Future<void> _animate() async {
    setState(() => scale = 0.85);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => scale = 1.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final Color color =
        widget.isActive ? widget.activeColor : widget.inactiveColor;

    return GestureDetector(
      onTap: _animate,
      behavior: HitTestBehavior.translucent,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 28,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: GoogleFonts.merriweather(
                fontSize: 11,
                fontWeight:
                    widget.isActive ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}