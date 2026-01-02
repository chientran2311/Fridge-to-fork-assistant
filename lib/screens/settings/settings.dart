import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/services/household_service.dart';
import 'package:fridge_to_fork_assistant/widgets/settings/create_household_dialog.dart';
import 'package:fridge_to_fork_assistant/widgets/settings/join_household_dialog.dart';
import 'package:fridge_to_fork_assistant/widgets/settings/manage_households_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Services
  final HouseholdService _householdService = HouseholdService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State
  bool _notificationsEnabled = true;
  Map<String, dynamic>? _currentHousehold;
  bool _isLoadingHousehold = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentHousehold();
  }

  Future<void> _loadCurrentHousehold() async {
    setState(() => _isLoadingHousehold = true);
    final household = await _householdService.getCurrentUserHousehold();
    if (mounted) {
      setState(() {
        _currentHousehold = household;
        _isLoadingHousehold = false;
      });
    }
  }

  void _showCreateHouseholdDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateHouseholdDialog(
        onCreateHousehold: _handleCreateHousehold,
      ),
    );
  }

  void _showJoinHouseholdDialog() {
    showDialog(
      context: context,
      builder: (context) => JoinHouseholdDialog(
        onJoinHousehold: _handleJoinHousehold,
      ),
    );
  }

  Future<void> _handleCreateHousehold(String name) async {
    final householdId = await _householdService.createHousehold(name);
    
    if (householdId != null) {
      final success = await _householdService.switchHousehold(householdId);
      
      if (success) {
        await _loadCurrentHousehold();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created and switched to "$name"'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create fridge. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleJoinHousehold(String code) async {
    final result = await _householdService.joinHousehold(code);
    
    if (mounted) {
      if (result == 'invalid_code') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid invite code. Please check and try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (result == 'already_member') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are already a member of this fridge.'),
            backgroundColor: Colors.blue,
          ),
        );
      } else if (result != null) {
        final success = await _householdService.switchHousehold(result);
        if (success) {
          await _loadCurrentHousehold();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully joined fridge!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to join fridge. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showManageHouseholdsSheet() async {
    final households = await _householdService.getUserHouseholds();
    final currentHouseholdId = await _householdService.getCurrentHouseholdId();
    final currentUserId = _auth.currentUser?.uid;

    final enrichedHouseholds = households.map((h) {
      return {...h, 'current_user_id': currentUserId};
    }).toList();

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ManageHouseholdsBottomSheet(
          households: enrichedHouseholds,
          currentHouseholdId: currentHouseholdId,
          onSwitchHousehold: _handleSwitchHousehold,
          onLeaveHousehold: _handleLeaveHousehold,
          onRegenerateCode: _handleRegenerateCode,
        ),
      );
    }
  }

  Future<void> _handleSwitchHousehold(String householdId) async {
    final success = await _householdService.switchHousehold(householdId);
    
    if (success) {
      await _loadCurrentHousehold();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Switched fridge successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleLeaveHousehold(String householdId) async {
    final success = await _householdService.leaveHousehold(householdId);
    
    if (success) {
      await _loadCurrentHousehold();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Left fridge successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleRegenerateCode(String householdId) async {
    final newCode = await _householdService.regenerateInviteCode(householdId);
    
    if (newCode != null) {
      await _loadCurrentHousehold();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('New Invite Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your new invite code is:'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        newCode,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: newCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

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

                // --- SECTION: FRIDGE MANAGEMENT ---
                _buildSectionHeader("FRIDGE MANAGEMENT"),
                
                // Current Fridge Card
                if (_isLoadingHousehold)
                  const Center(child: CircularProgressIndicator())
                else if (_currentHousehold != null)
                  _buildCurrentFridgeCard(),

                const SizedBox(height: 12),
                
                // Create & Join Buttons
                _buildSectionCard([
                  _buildListTile(
                    icon: Icons.add_circle_outline,
                    title: "Create New Fridge",
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: _showCreateHouseholdDialog,
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.login,
                    title: "Join Fridge",
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: _showJoinHouseholdDialog,
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.switch_account,
                    title: "My Fridges",
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: _showManageHouseholdsSheet,
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
                    onTap: () {
                      if (_currentHousehold != null) {
                        final inviteCode = _currentHousehold!['invite_code']?.toString() ?? 'N/A';
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Invite Code'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Share this code with others to invite them:'),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        inviteCode,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: inviteCode));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Code copied!')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
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

  // --- Widget Helper: Current Fridge Card ---
  Widget _buildCurrentFridgeCard() {
    final name = _currentHousehold?['name'] ?? 'My Fridge';
    final inviteCode = _currentHousehold?['invite_code']?.toString() ?? 'N/A';
    final ownerId = _currentHousehold?['owner_id'];
    final currentUserId = _auth.currentUser?.uid;
    final isOwner = ownerId == currentUserId;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainColor, mainColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.kitchen,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Fridge',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.vpn_key, color: Colors.white.withOpacity(0.8), size: 18),
              const SizedBox(width: 8),
              Text(
                'Invite Code: ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Text(
                inviteCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invite code copied!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(Icons.copy, color: Colors.white.withOpacity(0.9), size: 20),
                tooltip: 'Copy invite code',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isOwner ? Icons.star : Icons.person,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isOwner ? 'You are the owner' : 'You are a member',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
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