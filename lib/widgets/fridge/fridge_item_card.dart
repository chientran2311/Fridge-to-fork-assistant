import 'package:flutter/material.dart';
import '../../models/inventory_item.dart'; // Import Model mới

class FridgeItemCard extends StatelessWidget {
  final InventoryItem item;
  final bool isSelected;
  final bool isMultiSelectMode;
  final bool showAddButton; // Giữ lại biến này nếu muốn dùng cho màn hình Search sau này
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onAdd;

  const FridgeItemCard({
    super.key,
    required this.item,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    this.showAddButton = false,
    this.onTap,
    this.onLongPress,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // Logic xác định màu hạn sử dụng
    final int days = item.daysLeft;
    Color expiryColor = const Color(0xFF28A745); // Xanh (An toàn)
    String expiryText = '$days days';

    if (days < 0) {
      expiryColor = const Color(0xFFDC3545); // Đỏ (Hết hạn)
      expiryText = 'Expired';
    } else if (days <= 2) {
      expiryColor = const Color(0xFFFFC107); // Vàng (Sắp hết)
      expiryText = '$days days left';
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: const Color(0xFF2D5F4F), width: 2.5)
                  : Border.all(color: Colors.transparent, width: 0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER: Ảnh & Tag ngày hết hạn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh món ăn
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _buildItemImage(),
                      ),
                      
                      // Badge hạn sử dụng (Chỉ hiện khi không phải mode select)
                      if (!isMultiSelectMode && item.expiryDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: expiryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            expiryText,
                            style: TextStyle(
                              color: expiryColor == const Color(0xFFFFC107) 
                                  ? Colors.orange[800] 
                                  : expiryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // 2. INFO: Tên & Số lượng
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Tag category (ví dụ Meat, Dairy...)
                      if (item.quickTag != null && item.quickTag!.isNotEmpty) ...[
                         Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.quickTag!.toUpperCase(),
                            style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600),
                          ),
                         ),
                         const SizedBox(width: 6),
                      ],
                      Text(
                        '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.unit}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF868E96),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Icon checkmark khi chọn Multi-select
          if (isMultiSelectMode)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2D5F4F) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2D5F4F) : const Color(0xFFDEE2E6),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            
           // Nút Add (Dùng cho màn hình Search/Suggest sau này)
           if (showAddButton && !isMultiSelectMode)
            Positioned(
              bottom: 8,
              right: 8,
              child: InkWell(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5F4F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemImage() {
    // Ưu tiên hiển thị ảnh từ URL
    if (item.imageUrl != null && item.imageUrl!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          item.imageUrl!,
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 24, color: Colors.grey),
        ),
      );
    }
    
    // Nếu không có ảnh URL, hiển thị Icon dựa trên QuickTag
    IconData icon = Icons.fastfood;
    Color color = Colors.grey;

    final tag = item.quickTag?.toLowerCase() ?? '';
    if (tag.contains('meat') || tag.contains('thịt')) {
      icon = Icons.kebab_dining;
      color = Colors.red.shade300;
    } else if (tag.contains('veg') || tag.contains('rau')) {
      icon = Icons.eco;
      color = Colors.green.shade300;
    } else if (tag.contains('dairy') || tag.contains('sữa') || tag.contains('trứng')) {
      icon = Icons.egg;
      color = Colors.orange.shade300;
    } else if (tag.contains('fruit') || tag.contains('quả')) {
      icon = Icons.apple;
      color = Colors.pink.shade300;
    }

    return Icon(icon, size: 24, color: color);
  }
}