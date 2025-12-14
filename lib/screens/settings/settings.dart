import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Màu sắc chủ đạo
  final Color bgCream = const Color(0xFFF9F9F7);
  final Color mainColor = const Color(0xFF1B3B36);
  final Color redColor = const Color(0xFFE53935);

  // State giả lập
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      body: ResponsiveLayout(
        // --- MOBILE LAYOUT ---
        mobileBody: SafeArea(
          child: _buildContent(context, isMobile: true),
        ),

        // --- WEB/DESKTOP LAYOUT ---
        desktopBody: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600), // Giới hạn chiều rộng
            margin: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: bgCream,
              borderRadius: BorderRadius.circular(24),
              // Thêm bóng đổ nhẹ cho web để nổi bật
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildContent(context, isMobile: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isMobile}) {
    return Column(
      children: [
        // 1. Header (Back Button & Title)
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
                  "Settings",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: mainColor,
                  ),
                ),
              ),
              // Placeholder để cân đối tiêu đề vào giữa
              const SizedBox(width: 40), 
            ],
          ),
        ),

        // 2. Scrollable Settings List
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- SECTION: GENERAL ---
                _buildSectionHeader("GENERAL"),
                _buildSectionCard([
                  _buildListTile(
                    icon: Icons.language,
                    title: "Language",
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("English", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.notifications_none,
                    title: "Notifications",
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      activeColor: mainColor,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // --- SECTION: ACCOUNT ---
                _buildSectionHeader("ACCOUNT"),
                _buildSectionCard([
                  _buildListTile(
                    icon: Icons.person_add_alt_1_outlined,
                    title: "Invite to Family",
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: () {},
                  ),
                  _buildDivider(),
                
                ]),

                const SizedBox(height: 40),

                // --- LOG OUT BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Logic logout
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                  Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Show confirmation dialog
                    },
                    icon: Icon(Icons.delete_outline, color: redColor, size: 20),
                    label: Text(
                      "Delete account",
                      style: TextStyle(
                        color: redColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                

                // Version Info
                Center(
                  child: Text(
                    "Version 1.0.2",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
                // --- DELETE ACCOUNT ---
            
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget Helper: Tiêu đề Section (GENERAL, ACCOUNT) ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // --- Widget Helper: Card chứa các setting ---
  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Shadow nhẹ giúp tách biệt khỏi nền
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

  // --- Widget Helper: Dòng kẻ phân cách ---
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 56, // Thụt vào khớp với text, bỏ qua icon
    );
  }

  // --- Widget Helper: Từng dòng Setting ---
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
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
              // Icon nền tròn xanh nhạt
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0EE), // Xanh rất nhạt
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: mainColor, size: 18),
              ),
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              // Trailing (Mũi tên, Switch, Text...)
              trailing,
            ],
          ),
        ),
      ),
    );
  }
} 