import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/models/fridge_item.dart';

class FridgeItemCard extends StatelessWidget {
  final FridgeItem item;
  final bool isSelected;
  final bool isMultiSelectMode;
  final bool showAddButton;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FridgeItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isMultiSelectMode,
    this.showAddButton = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D5F4F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần 1: Ảnh và Badge (Stack)
            Expanded(
              child: Stack(
                children: [
                  // Container ảnh với gradient background - Full width height
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getGradientColors(),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.imageUrl,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                  
                  // Badge "X DAYS"
                  if (item.expiryDays != null && !isSelected)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _getExpiryBadgeBackgroundColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.expiryDays} DAY${item.expiryDays! > 1 ? 'S' : ''}',
                          style: TextStyle(
                            color: _getExpiryBadgeTextColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  
                  // Selection Checkbox Overlay - REMOVED
                  // Không cần checkbox nữa
                  
                  // Add Button (only for Peppers)
                  if (showAddButton && !isMultiSelectMode)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D5F4F),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D5F4F).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Phần 2: Nội dung chữ
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSubtitle(),
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.8)
                          : (item.expiryDays != null 
                              ? const Color(0xFFE63946) 
                              : const Color(0xFF6B7280)),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle() {
    if (item.expiryDays != null) {
      return item.expiryDays! <= 1 ? 'Expiring soon' : 'Plan a meal';
    }
    return '${item.quantity}${item.unit}';
  }

  List<Color> _getGradientColors() {
    // Màu gradient dựa theo category và expiry status
    if (item.expiryDays != null) {
      // Eat Me First items - darker green tones
      return [
        const Color(0xFF2F5043),
        const Color(0xFF1E3A2F),
      ];
    }
    
    // In Stock items
    if (item.name.contains('Avocados')) {
      return [
        const Color(0xFF3D5A4F),
        const Color(0xFF2A4538),
      ];
    } else if (item.name.contains('Eg')) {
      return [
        const Color(0xFF4A5568),
        const Color(0xFF2D3748),
      ];
    } else if (item.name.contains('Cheddar')) {
      return [
        const Color(0xFF2F5F4F),
        const Color(0xFF1F4538),
      ];
    } else if (item.name.contains('Tomatoes')) {
      return [
        const Color(0xFF4A4A4A),
        const Color(0xFF2A2A2A),
      ];
    } else if (item.name.contains('Strawb')) {
      return [
        const Color(0xFFB0B0B0),
        const Color(0xFF858585),
      ];
    } else if (item.name.contains('Peppers')) {
      return [
        const Color(0xFF1A3A2A),
        const Color(0xFF0F2518),
      ];
    }
    
    return [
      const Color(0xFF3D5F4F),
      const Color(0xFF2D4538),
    ];
  }

  Color _getExpiryBadgeBackgroundColor() {
    if (item.expiryDays == null) return const Color(0xFFE0E0E0);
    if (item.expiryDays! <= 1) return const Color(0xFFFFDBDD);
    if (item.expiryDays! <= 3) return const Color(0xFFFFE8CC);
    return const Color(0xFFD4EDDA);
  }

  Color _getExpiryBadgeTextColor() {
    if (item.expiryDays == null) return const Color(0xFF757575);
    if (item.expiryDays! <= 1) return const Color(0xFFD32F2F);
    if (item.expiryDays! <= 3) return const Color(0xFFF57C00);
    return const Color(0xFF388E3C);
  }
}