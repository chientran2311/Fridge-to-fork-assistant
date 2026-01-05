import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../profile_avatar.dart';

class FridgeHeader extends StatelessWidget {
  final bool isMultiSelectMode;
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onSettings;

  const FridgeHeader({
    super.key,
    required this.isMultiSelectMode,
    this.selectedCount = 0,
    required this.onCancel,
    required this.onSave,
    required this.onSettings,
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

          // Tiêu đề hoặc Avatar + Greeting
          if (isMultiSelectMode)
            // Khi đang chọn nhiều: Hiện số lượng items đã chọn
            Text(
              s?.language == 'vi' ? '$selectedCount đã chọn' : '$selectedCount selected',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            )
          else
            // Khi bình thường: Hiện Avatar + Greeting
            Row(
              children: [
                const ProfileAvatar(
                  size: 48,
                  showEditIcon: true,
                ),
                const SizedBox(width: 12),
                // Greeting text với display name từ Firestore
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final name = authProvider.displayName;
                    return Text(
                      s?.helloGreeting(name) ?? 'Xin chào, $name',
                      style: GoogleFonts.merriweather(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    );
                  },
                ),
              ],
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
    );
  }
}
