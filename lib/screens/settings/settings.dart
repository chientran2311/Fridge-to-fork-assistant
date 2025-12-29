import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

// Import Providers & Localization
// ❌ Đã xóa import AuthService
import '../../providers/auth_provider.dart'; // ✅ Chỉ dùng Provider
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- MÀU SẮC UI ---
  final Color bgCream = const Color(0xFFF9F9F7);
  final Color mainColor = const Color(0xFF1B3B36);
  final Color redColor = const Color(0xFFE53935);

  bool _notificationsEnabled = true;

  // --- UI LOGIC: MỜI THÀNH VIÊN ---
  void _showInviteDialog(BuildContext context, AppLocalizations s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.inviteMember),
        content: const Text("QR Code & Email invitation feature coming soon."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // --- UI LOGIC: ĐĂNG XUẤT ---
  Future<void> _handleLogout(BuildContext context) async {
    // Gọi hàm logout từ Provider (Logic nằm bên Provider)
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    
    // Điều hướng UI
    if (context.mounted) {
      context.go('/login'); 
    }
  }

  // --- UI LOGIC: XÓA TÀI KHOẢN ---
  void _confirmDeleteAccount(BuildContext context, AppLocalizations s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteAccount, style: TextStyle(color: redColor)),
        content: Text(s.deleteAccountWarning),
        actions: [
          // Nút Hủy
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          // Nút Xác Nhận
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Đóng Dialog trước

              // Gọi Provider để xử lý logic xóa
              final authProvider = context.read<AuthProvider>();
              final String? error = await authProvider.deleteAccount();

              if (!context.mounted) return;

              // Xử lý kết quả trả về từ Provider để update UI
              if (error == null) {
                // Thành công
                context.go('/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account deleted successfully")),
                );
              } else {
                // Thất bại (VD: cần đăng nhập lại)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: redColor,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            child: Text(s.confirm, style: TextStyle(color: redColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    // Fallback an toàn
    if (s == null) return const SizedBox();

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
    // Lấy ngôn ngữ hiển thị từ Provider
    final currentLocale = context.watch<LocaleProvider>().locale;
    final String languageName = currentLocale.languageCode == 'vi' ? 'Tiếng Việt' : 'English';

    return Column(
      children: [
        // --- HEADER ---
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

        // --- SCROLLABLE BODY ---
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

                // SECTION 2: GIA ĐÌNH
                _buildSectionHeader(s.household),
                _buildSectionCard([
                  _buildListTile(
                    icon: Icons.person_add_alt_1,
                    title: s.inviteMember,
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: () => _showInviteDialog(context, s),
                  ),
                ]),
                const SizedBox(height: 24),

                // SECTION 3: TÀI KHOẢN
                _buildSectionHeader(s.account),
                _buildSectionCard([
                  // Nút Đăng Xuất
                  _buildListTile(
                    icon: Icons.logout,
                    title: s.logOut,
                    trailing: const SizedBox(),
                    onTap: () => _handleLogout(context), // ✅ Gọi logic Auth qua hàm wrapper
                  ),
                  _buildDivider(),
                  // Nút Xóa Tài Khoản
                  _buildListTile(
                    icon: Icons.delete_outline,
                    title: s.deleteAccount,
                    textColor: redColor, 
                    iconColor: redColor.withOpacity(0.1), 
                    iconColorTint: redColor, 
                    trailing: const SizedBox(),
                    onTap: () => _confirmDeleteAccount(context, s), // ✅ Gọi logic Auth qua hàm wrapper
                  ),
                ]),
                
                const SizedBox(height: 40),
                
                // Version Info
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

  // --- WIDGET HELPER METHODS (Giữ nguyên UI) ---

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
                  context.read<LocaleProvider>().setLocale(const Locale('vi'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                title: const Text("English"),
                onTap: () {
                  context.read<LocaleProvider>().setLocale(const Locale('en'));
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
    Color? textColor,
    Color? iconColor,
    Color? iconColorTint,
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
                  color: iconColor ?? const Color(0xFFE8F0EE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: iconColorTint ?? const Color(0xFF1B3B36), 
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
                    color: textColor ?? Colors.black87,
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