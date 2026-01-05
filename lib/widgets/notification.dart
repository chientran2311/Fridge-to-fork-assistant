import 'package:flutter/material.dart';
// 1. Import file responsive của bạn (Sửa đường dẫn nếu cần)
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final bool isError;

  const CustomToast({
    super.key,
    required this.message,
    this.isError = false,
  });
//// new
  static const Color successColor = Color(0xFF1B3B36);
  static const Color errorColor = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Thêm constraint để đảm bảo trên desktop nội dung không bị quá bé hoặc quá to
      constraints: BoxConstraints(
        minWidth: 120, // Chiều rộng tối thiểu cho đẹp
        maxWidth: context.isMobile ? double.infinity : 400, // Desktop giới hạn 400px
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError ? errorColor : successColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Quan trọng: Co giãn theo nội dung
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung bên trong
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 2),
            ),
            child: Icon(
              isError ? Icons.close : Icons.check,
              color: const Color.fromARGB(255, 255, 255, 255),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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

    // 2. Sử dụng Extension từ responsive_ui.dart để kiểm tra màn hình
    final bool isDesktopOrTablet = context.isDesktop || context.isTablet;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomToast(message: message, isError: isError),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        
        // --- LOGIC RESPONSIVE VỊ TRÍ ---
        
        // A. Nếu là Desktop/Tablet: Dùng 'width' để cố định kích thước ở giữa
        width: isDesktopOrTablet ? 400 : null, 
        
        // B. Nếu là Mobile: Dùng 'margin' để căn lề trái phải
        // Lưu ý: Nếu đã set 'width' thì 'margin' chỉ tác dụng theo chiều dọc (bottom)
        margin: isDesktopOrTablet 
            ? const EdgeInsets.only(bottom: 30) // Desktop: Cách đáy 30px, tự căn giữa
            : const EdgeInsets.only(bottom: 20, left: 24, right: 24), // Mobile: Cách đáy 20px, cách bên 24px
      ),
    );
  }
}