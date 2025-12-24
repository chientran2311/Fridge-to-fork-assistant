import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isHighlight;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double iconSize;

  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.isHighlight = false,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on provided values or isHighlight flag for backward compatibility
    final Color finalBackgroundColor = backgroundColor ??
        (isHighlight ? const Color(0xFFFFF4E5) : const Color(0xFFF5F5F5));
    final Color finalTextColor =
        textColor ?? (isHighlight ? const Color(0xFFD86D35) : Colors.black87);
    final Color finalIconColor = iconColor ??
        (isHighlight ? const Color(0xFFD86D35) : Colors.grey[700]!);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: finalBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: finalIconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: finalTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
