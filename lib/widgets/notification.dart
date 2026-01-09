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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isError ? errorColor : successColor,
        borderRadius: BorderRadius.circular(30),
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
              border: Border.all(color: iconColor, width: 2),
            ),
            child: Icon(
              isError ? Icons.close : Icons.check,
              color: iconColor,
              size: 14,
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
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM TĨNH HIỂN THỊ TOAST ---
  /// Hiển thị thông báo toast floating ở góc trái dưới màn hình
  /// [context] - BuildContext hiện tại
  /// [message] - Nội dung thông báo
  /// [isError] - true nếu là thông báo lỗi (màu đỏ)
  static void show(BuildContext context, String message, {bool isError = false}) {
    // Ẩn snackbar cũ nếu có
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktopOrTablet = context.isDesktop || context.isTablet;
    
    // Bottom margin: Thẳng hàng với FAB, sát BottomNav
    const double mobileBottom = 5.0;
    const double desktopBottom = 30.0;

    // Toast width cố định để không bị full width
    const double toastMaxWidth = 300.0;
    
    // Margin phải = screen width - toast width - margin trái - padding FAB
    // Để toast nằm bên trái, margin phải phải lớn
    final double rightMargin = isDesktopOrTablet 
        ? screenWidth - toastMaxWidth - 40  // Desktop: để toast bên trái
        : screenWidth - toastMaxWidth - 12; // Mobile: để toast bên trái, chừa FAB

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomToast(message: message, isError: isError),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
        
        // Margin để đẩy toast sang góc trái dưới
        margin: EdgeInsets.only(
          bottom: isDesktopOrTablet ? desktopBottom : mobileBottom,
          left: isDesktopOrTablet ? 40 : 12, // Mobile: 12px từ left
          right: rightMargin.clamp(80.0, double.infinity), // Đảm bảo chừa chỗ FAB
        ),
      ),
    );
  }
}