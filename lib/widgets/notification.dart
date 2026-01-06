import 'package:flutter/material.dart';
// Import file responsive của bạn
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final bool isError;

  const CustomToast({
    super.key,
    required this.message,
    this.isError = false,
  });

  // Màu nền xanh đậm (Giống ảnh 1)
  static const Color successColor = Color(0xFF1B3B36);
  // Màu đỏ cho lỗi
  static const Color errorColor = Color(0xFFD32F2F);
  // [MỚI] Màu xanh sáng cho Icon & Viền (Giống ảnh 1)
  static const Color successAccentColor = Color(0xFF6EF0A2); 

  @override
  Widget build(BuildContext context) {
    // Xác định màu icon dựa trên trạng thái lỗi hay thành công
    final Color iconColor = isError ? Colors.white : successAccentColor;

    return Container(
      constraints: BoxConstraints(
        minWidth: 120,
        maxWidth: context.isMobile ? double.infinity : 400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Tăng padding dọc chút cho dày dặn
      decoration: BoxDecoration(
        color: isError ? errorColor : successColor,
        borderRadius: BorderRadius.circular(30), // Bo tròn hình viên thuốc
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon tròn
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Viền màu xanh sáng (accent) thay vì trắng
              border: Border.all(
                color: iconColor, 
                width: 2
              ),
            ),
            child: Icon(
              isError ? Icons.close : Icons.check,
              // Icon màu xanh sáng
              color: iconColor,
              size: 14, // Kích thước nhỏ gọn giống ảnh
            ),
          ),
          const SizedBox(width: 12),
          // Nội dung text
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold, // Đậm hơn chút giống ảnh
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM TĨNH HIỂN THỊ RESPONSIVE ---
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final bool isDesktopOrTablet = context.isDesktop || context.isTablet;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomToast(message: message, isError: isError),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        
        // --- LOGIC RESPONSIVE VỊ TRÍ ---
        
        // Desktop: Cố định chiều rộng
        width: isDesktopOrTablet ? 400 : null, 
        
        // Mobile & Tablet: Căn lề
        margin: isDesktopOrTablet 
            ? const EdgeInsets.only(bottom: 30) 
            // [QUAN TRỌNG] Thay đổi margin đáy cho Mobile giống Ảnh 2
            // Bottom = 90 để nằm TRÊN thanh BottomNavigationBar (thường cao ~60-80px)
            : const EdgeInsets.only(bottom: 90, left: 24, right: 24), 
      ),
    );
  }
}