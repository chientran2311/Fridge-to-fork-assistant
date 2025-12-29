import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Import Router
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

// Import Service & Provider & Localization
import '../../data/services/auth_service.dart'; // ✅ Import AuthService
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color bgCream = const Color(0xFFF9F9F7);
  final Color mainColor = const Color(0xFF1B3B36);
  final Color redColor = const Color(0xFFE53935);

  final AuthService _authService = AuthService(); // ✅ Khởi tạo Service
  bool _notificationsEnabled = true;

  // --- LOGIC: MỜI THÀNH VIÊN ---
  void _showInviteDialog(BuildContext context) {
    // Demo UI: Sau này bạn có thể làm form nhập email để gửi lời mời
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Invite Member"),
        content: const Text("Tính năng chia sẻ QR Code hoặc gửi Email đang được phát triển."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  // --- LOGIC: ĐĂNG XUẤT ---
  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      // Xóa hết các màn hình cũ và về trang Login
      context.go('/login'); 
    }
  }

  // --- LOGIC: XÓA TÀI KHOẢN ---
  void _confirmDeleteAccount(BuildContext context, AppLocalizations s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteAccount, style: TextStyle(color: redColor)),
        content: Text(s.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              // Gọi hàm xóa user (cần viết thêm trong AuthService)
              // await _authService.deleteAccount();
              Navigator.pop(ctx);
              _handleLogout(); // Tạm thời logout sau khi xóa
            },
            child: Text(s.confirm, style: TextStyle(color: redColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: bgCream,
      body: ResponsiveLayout(
        mobileBody: SafeArea(child: _buildContent(context, s, isMobile: true)),
        desktopBody: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: bgCream,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildContent(context, s, isMobile: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations s, {required bool isMobile}) {
    final currentLocale = Provider.of<LocaleProvider>(context).locale;
    final String languageName = currentLocale.languageCode == 'vi' ? 'Tiếng Việt' : 'English';

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: mainColor,
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  s.settingsTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    fontSize: 20, fontWeight: FontWeight.w900, color: mainColor,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: CÀI ĐẶT CHUNG
                _buildSectionHeader(s.general), 
                _buildSectionCard([
                  _buildListTile(
                    icon: Icons.language,
                    title: s.language,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(languageName, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                    onTap: () => _showLanguageBottomSheet(context),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.notifications_none,
                    title: s.notifications,
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      activeColor: mainColor,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // SECTION 2: GIA ĐÌNH (MỚI)
              
                _buildSectionCard([
                  // Đăng xuất
                  _buildListTile(
                    icon: Icons.logout,
                    title: s.logOut,
                    trailing: const SizedBox(),
                    onTap: _handleLogout, // Gọi hàm đăng xuất
                  ),
                  _buildDivider(),
                  // Xóa tài khoản (Màu đỏ)
                  _buildListTile(
                    icon: Icons.delete_outline,
                    title: s.deleteAccount,
                    textColor: redColor, // Chữ đỏ
                    iconColor: redColor.withOpacity(0.1), // Nền icon đỏ nhạt
                    iconColorTint: redColor, // Icon đỏ
                    trailing: const SizedBox(),
                    onTap: () => _confirmDeleteAccount(context, s),
                  ),
                ]),
                
                const SizedBox(height: 40),
                
                // Version info
                Center(
                  child: Text(
                    "Version 1.0.0",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Widgets Helper ---

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Language", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text("🇻🇳", style: TextStyle(fontSize: 24)),
                title: const Text("Tiếng Việt"),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('vi'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                title: const Text("English"),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 56,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
    Color? textColor, // ✅ Thêm tham số màu chữ
    Color? iconColor, // ✅ Thêm tham số màu nền icon
    Color? iconColorTint, // ✅ Thêm tham số màu icon
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: iconColor ?? const Color(0xFFE8F0EE), // Mặc định hoặc custom
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: iconColorTint ?? const Color(0xFF1B3B36), // Mặc định hoặc custom
                  size: 18
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15, 
                    fontWeight: FontWeight.w600, 
                    color: textColor ?? Colors.black87, // Mặc định hoặc custom
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}