import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

// Import Providers & Localization
import '../../providers/auth_provider.dart'; 
import '../../providers/locale_provider.dart';
import '../../providers/household_provider.dart';
import '../../l10n/app_localizations.dart';

// [MỚI] Import Database Seeder để gọi hàm tạo dữ liệu
import '../../utils/database_seeder.dart'; 

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
  bool _isTogglingNotification = false; // Loading state cho switch

  @override
  void initState() {
    super.initState();
    // Load household data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HouseholdProvider>().loadCurrentHousehold();
    });
    // Load notification setting
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    // Bước 1: Cập nhật UI NGAY LẬP TỨC để responsive
    setState(() {
      _isTogglingNotification = true;
      _notificationsEnabled = value;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', value);
      
      if (value) {
        // BẬT thông báo
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        // Subscribe topic và lưu lại token
        await FirebaseMessaging.instance.subscribeToTopic('general');
        // Lưu lại FCM token vào Firestore
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _saveFcmToken(token);
        }
      } else {
        // TẮT thông báo
        await FirebaseMessaging.instance.unsubscribeFromTopic('general');
        // Xóa FCM token khỏi Firestore để backend không gửi nữa
        await _removeFcmToken();
      }
    } catch (e) {
      // Nếu lỗi, revert lại trạng thái cũ
      if (mounted) {
        setState(() {
          _notificationsEnabled = !value;
        });
      }
      debugPrint('❌ Lỗi toggle notification: $e');
    } finally {
      if (mounted) {
        setState(() => _isTogglingNotification = false);
      }
    }
  }

  // Helper: Lưu FCM token vào Firestore
  Future<void> _saveFcmToken(String token) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcm_token': token,
      'notifications_enabled': true,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Helper: Xóa FCM token khỏi Firestore
  Future<void> _removeFcmToken() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcm_token': FieldValue.delete(),
      'notifications_enabled': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // --- UI LOGIC: MỜI THÀNH VIÊN ---
  void _showInviteDialog(BuildContext context, AppLocalizations s) {
    final householdProvider = context.read<HouseholdProvider>();
    final inviteCode = householdProvider.inviteCode ?? 'N/A';
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.inviteMember),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.shareCodeToInvite),
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
                        SnackBar(content: Text(s.codeCopied)),
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.close),
          )
        ],
      ),
    );
  }

  // --- UI LOGIC: TẠO NHÀ MỚI ---
  void _showCreateHouseholdDialog(BuildContext context, AppLocalizations s) async {
    final provider = context.read<HouseholdProvider>();
    
    // Check if user already owns a household
    final alreadyOwns = await provider.checkIfUserOwnsHousehold();
    if (alreadyOwns) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.alreadyOwnFridge),
            backgroundColor: redColor,
          ),
        );
      }
      return;
    }
    
    final nameController = TextEditingController();
    
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.createNewFridge),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: s.fridgeName,
            hintText: s.fridgeNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              
              final success = await provider.createHousehold(nameController.text.trim());
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? s.fridgeCreated : s.cannotCreate),
                    backgroundColor: success ? mainColor : redColor,
                  ),
                );
              }
            },
            child: Text(s.create, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- UI LOGIC: THAM GIA NHÀ ---
  void _showJoinHouseholdDialog(BuildContext context, AppLocalizations s) {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.joinFridge),
        content: TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: s.inviteCode,
            hintText: s.enterInviteCode,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (codeController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              
              final provider = context.read<HouseholdProvider>();
              final result = await provider.joinHousehold(codeController.text.trim());
              
              if (context.mounted) {
                String message;
                bool isError = false;
                switch (result) {
                  case 'success':
                    message = s.joinedSuccess;
                    break;
                  case 'invalid_code':
                    message = s.invalidCode;
                    isError = true;
                    break;
                  case 'already_member':
                    message = s.alreadyMember;
                    isError = true;
                    break;
                  default:
                    message = s.cannotJoin;
                    isError = true;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: isError ? redColor : mainColor,
                  ),
                );
              }
            },
            child: Text(s.join, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- UI LOGIC: QUẢN LÝ DANH SÁCH NHÀ ---
  void _showManageHouseholdsSheet(BuildContext context, AppLocalizations s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<HouseholdProvider>(
          builder: (context, provider, _) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.fridgeList,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (provider.userHouseholds.isEmpty)
                    Center(child: Text(s.noFridgesYet))
                  else
                    ...provider.userHouseholds.map((household) {
                      final isCurrentHouse = household['household_id'] == provider.currentHouseholdId;
                      return ListTile(
                        leading: Icon(
                          Icons.kitchen,
                          color: isCurrentHouse ? mainColor : Colors.grey,
                        ),
                        title: Text(household['name'] ?? 'Unknown'),
                        trailing: isCurrentHouse
                            ? Icon(Icons.check_circle, color: mainColor)
                            : TextButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await provider.switchHousehold(household['household_id']);
                                },
                                child: Text(s.switchFridge),
                              ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- UI LOGIC: XEM THÀNH VIÊN ---
  void _showMembersSheet(BuildContext context, AppLocalizations s) {
    final householdProvider = context.read<HouseholdProvider>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: householdProvider.getMembers(),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.members,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.data?.isEmpty ?? true)
                    const Center(child: Text("No members"))
                  else
                    ...snapshot.data!.map((member) {
                      final isOwner = member['is_owner'] == true;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOwner ? mainColor : Colors.grey[300],
                          child: Text(
                            (member['display_name'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: isOwner ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                        title: Text(member['display_name'] ?? 'User'),
                        subtitle: Text(member['email'] ?? ''),
                        trailing: isOwner 
                            ? Chip(
                                label: Text(s.owner, style: const TextStyle(fontSize: 11)),
                                backgroundColor: mainColor.withOpacity(0.1),
                              )
                            : householdProvider.isOwner // Chỉ owner mới xóa được thành viên
                                ? TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      final success = await householdProvider.removeMember(member['uid']);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(success ? s.memberRemoved : s.cannotRemoveMember),
                                            backgroundColor: success ? mainColor : redColor,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(s.removeMember, style: TextStyle(color: redColor)),
                                  )
                                : Chip(
                                    label: Text(s.member, style: const TextStyle(fontSize: 11)),
                                    backgroundColor: Colors.grey[200],
                                  ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- UI LOGIC: XÁC NHẬN RỜI KHỎI TỦ LẠNH ---
  void _confirmLeaveFridge(BuildContext context, AppLocalizations s) {
    final householdProvider = context.read<HouseholdProvider>();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.leaveFridge),
        content: Text(s.leaveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final currentHouseholdId = householdProvider.currentHouseholdId;
              if (currentHouseholdId != null) {
                final success = await householdProvider.leaveHousehold(currentHouseholdId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? s.leftFridge : s.ownerCannotLeave),
                      backgroundColor: success ? mainColor : redColor,
                    ),
                  );
                }
              }
            },
            child: Text(s.confirm, style: TextStyle(color: redColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- UI LOGIC: ĐĂNG XUẤT ---
  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); 
              final authProvider = context.read<AuthProvider>();
              final String? error = await authProvider.deleteAccount();

              if (!context.mounted) return;

              if (error == null) {
                context.go('/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.accountDeleted)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error), backgroundColor: redColor),
                );
              }
            },
            child: Text(s.confirm, style: TextStyle(color: redColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- [MỚI] UI LOGIC: SEED DATABASE ---
  Future<void> _handleSeedDatabase(BuildContext context, AppLocalizations s) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.creatingData),
        duration: const Duration(seconds: 2),
      ),
    );

    await DatabaseSeeder().seedDatabase();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.dataCreatedSuccess),
          backgroundColor: mainColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
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
    final currentLocale = context.watch<LocaleProvider>().locale;
    final String languageName = currentLocale.languageCode == 'vi' ? 'Tiếng Việt' : 'English';
    final householdProvider = context.watch<HouseholdProvider>();

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
                    trailing: _isTogglingNotification
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: mainColor,
                            ),
                          )
                        : Switch.adaptive(
                            value: _notificationsEnabled,
                            activeColor: mainColor,
                            onChanged: _toggleNotifications,
                          ),
                  ),
                ]),
                const SizedBox(height: 24),

                // SECTION 2: QUẢN LÝ TỦ LẠNH (Household Management)
                _buildSectionHeader(s.fridgeManagement),
                
                // Current Fridge Card
                if (householdProvider.isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ))
                else if (householdProvider.currentHousehold != null)
                  _buildCurrentFridgeCard(householdProvider, s),
                
                const SizedBox(height: 12),
                
                _buildSectionCard([
                  _buildListTile(
                    icon: Icons.add_circle_outline,
                    title: s.createNewFridge,
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: () => _showCreateHouseholdDialog(context, s),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.login,
                    title: s.joinFridge,
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: () => _showJoinHouseholdDialog(context, s),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.switch_account,
                    title: s.fridgeList,
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: () => _showManageHouseholdsSheet(context, s),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.people_outline,
                    title: s.viewMembers,
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: () => _showMembersSheet(context, s),
                  ),
                  // Hiển thị nút rời khỏi nếu không phải owner
                  if (!householdProvider.isOwner) ...[
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.exit_to_app,
                      title: s.leaveFridge,
                      textColor: redColor,
                      iconColor: redColor.withOpacity(0.1),
                      iconColorTint: redColor,
                      trailing: const SizedBox(),
                      onTap: () => _confirmLeaveFridge(context, s),
                    ),
                  ],
                ]),
                const SizedBox(height: 24),

                // SECTION 3: TÀI KHOẢN
                _buildSectionHeader(s.account),
                _buildSectionCard([
                  _buildListTile(
                    icon: Icons.logout,
                    title: s.logOut,
                    trailing: const SizedBox(),
                    onTap: () => _handleLogout(context),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.delete_outline,
                    title: s.deleteAccount,
                    textColor: redColor, 
                    iconColor: redColor.withOpacity(0.1), 
                    iconColorTint: redColor, 
                    trailing: const SizedBox(),
                    onTap: () => _confirmDeleteAccount(context, s),
                  ),
                ]),
                
                const SizedBox(height: 24),

                // SECTION 5: DEVELOPER TOOLS
                _buildSectionHeader(s.developerTools),
                _buildSectionCard([
                  _buildListTile(
                    icon: Icons.cloud_upload_outlined,
                    title: s.seedDatabase,
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    onTap: () => _handleSeedDatabase(context, s),
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

  // --- WIDGET HELPER: Current Fridge Card ---
  Widget _buildCurrentFridgeCard(HouseholdProvider provider, AppLocalizations s) {
    final name = provider.currentHouseholdName ?? 'My Fridge';
    final inviteCode = provider.inviteCode ?? 'N/A';
    final isOwner = provider.isOwner;
    
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
                child: const Icon(Icons.kitchen, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.currentFridge,
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
                '${s.inviteCode}: ',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
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
                    SnackBar(content: Text(s.inviteCodeCopied), duration: const Duration(seconds: 2)),
                  );
                },
                icon: Icon(Icons.copy, color: Colors.white.withOpacity(0.9), size: 20),
                tooltip: s.inviteCode,
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
                isOwner ? s.youAreOwner : s.youAreMember,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  void _showLanguageBottomSheet(BuildContext context) {
    final s = AppLocalizations.of(context)!;
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
              Text(s.selectLanguage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text("🇻🇳", style: TextStyle(fontSize: 24)),
                title: Text(s.vietnamese),
                onTap: () {
                  context.read<LocaleProvider>().setLocale(const Locale('vi'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                title: Text(s.english),
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
