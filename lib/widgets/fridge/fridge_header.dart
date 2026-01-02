import 'package:flutter/material.dart';
// ⚠️ Hãy đảm bảo đường dẫn import này đúng với cấu trúc thư mục của bạn
import '../../l10n/app_localizations.dart';

class FridgeHeader extends StatelessWidget {
  final bool isMultiSelectMode;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onSettings;
  final VoidCallback onSeed;

  const FridgeHeader({
    super.key,
    required this.isMultiSelectMode,
    required this.onCancel,
    required this.onSave,
    required this.onSettings,
    required this.onSeed,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Lấy dữ liệu ngôn ngữ (Safe Mode)
    final s = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: const Color(0xFFF8F9FA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút Cancel (Hủy)
          if (isMultiSelectMode)
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                s?.cancel ?? 'Cancel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFDC3545),
                ),
              ),
            ),
          
          // Tiêu đề (Fridge / Tủ lạnh)
          Text(
            // Nếu đang chọn nhiều thì hiện "Đã chọn...", nếu không thì hiện tên Tab
            isMultiSelectMode 
                ? (s?.language == 'vi' ? 'Đã chọn' : 'Selected') 
                : (s?.fridgeTab ?? 'My Fridge'), // ✅ Đa ngôn ngữ
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          
          // Nút Save (Lưu) hoặc Settings
          if (isMultiSelectMode)
            TextButton(
              onPressed: onSave,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                s?.save ?? 'Save', // ✅ Đa ngôn ngữ
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF28A745),
                ),
              ),
            )
          else
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.download_outlined, size: 20),
                    onPressed: onSeed,
                    color: const Color(0xFF2D5F4F),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    onPressed: onSettings,
                    color: const Color(0xFF1A1A1A),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}