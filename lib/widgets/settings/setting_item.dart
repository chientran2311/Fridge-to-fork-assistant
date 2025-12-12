import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color textColor;
  final VoidCallback onTap;
  final bool isBold;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.textColor,
    required this.onTap,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 26),
            const SizedBox(width: 20), // Khoảng cách giữa Icon và Text
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}