import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

// Import Localization
import '../../l10n/app_localizations.dart';

import '../../widgets/auth/common_auth_widgets.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/notification.dart';
import '../../widgets/profile_avatar_simple.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color mainColor = const Color(0xFF1B3B36);
  final Color secondaryColor = const Color(0xFFF0F1F1);

  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final s = AppLocalizations.of(context)!; // ✅ Lấy ngôn ngữ

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    // Validate
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPass.isEmpty) {
      CustomToast.show(context, s.registerErrorMissing,
          isError: true); // ✅ Updated
      return;
    }

    if (password != confirmPass) {
      CustomToast.show(context, s.registerErrorMatch,
          isError: true); // ✅ Updated
      return;
    }

    setState(() => _isLoading = true);

    String? errorMessage = await _authService.registerWithEmail(
      email: email,
      password: password,
      displayName: name, // [SỬA] Truyền tên vào để lưu Firestore
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorMessage == null) {
      // [DISABLED] Notification service removed
      // try {
      //   await NotificationService().saveTokenToDatabase();
      // } catch (e) {
      //   print("⚠️ Lỗi lưu token: $e");
      // }

      setState(() => _isLoading = false);
      CustomToast.show(context, s.registerSuccess);

      if (mounted) {
        // 3. Chuyển thẳng vào App hoặc về Login tùy luồng của bạn
        // Ở đây giữ logic cũ là pop về Login để người dùng tự đăng nhập lại (hoặc login auto)
        Navigator.pop(context);
      }
    } else {
      setState(() => _isLoading = false);
      CustomToast.show(context, errorMessage, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        mobileBody: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildRegisterContent(context),
            ),
          ),
        ),
        desktopBody: Container(
          color: secondaryColor,
          child: Center(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildRegisterContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterContent(BuildContext context) {
    final s = AppLocalizations.of(context)!; // ✅ Lấy ngôn ngữ

    return Column(
      children: [
        // Back Button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // Profile Avatar - Simple version
        const ProfileAvatar(
          size: 100,
        ),
        const SizedBox(height: 24),

        // Title Text
        Text(
          s.registerTitle, // ✅ Updated
          style: GoogleFonts.merriweather(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.registerSubtitle, // ✅ Updated
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // Input Fields
        CustomAuthField(
          label: s.fullNameLabel, // ✅ Updated
          hintText: s.fullNameHint, // ✅ Updated
          mainColor: mainColor,
          controller: _nameController,
        ),
        const SizedBox(height: 16),

        CustomAuthField(
          label: s.emailLabel, // ✅ Updated (Dùng chung với login)
          hintText: s.emailHint, // ✅ Updated
          mainColor: mainColor,
          controller: _emailController,
        ),
        const SizedBox(height: 16),

        CustomAuthField(
          label: s.passwordLabel, // ✅ Updated
          hintText: s.passwordHint, // ✅ Updated
          isPassword: true,
          isObscure: _isPasswordObscure,
          mainColor: mainColor,
          controller: _passwordController,
          onIconTap: () {
            setState(() {
              _isPasswordObscure = !_isPasswordObscure;
            });
          },
        ),
        const SizedBox(height: 16),

        CustomAuthField(
          label: s.confirmPasswordLabel, // ✅ Updated
          hintText: s.passwordHint, // ✅ Updated
          isPassword: true,
          isObscure: _isConfirmPasswordObscure,
          mainColor: mainColor,
          controller: _confirmPasswordController,
          onIconTap: () {
            setState(() {
              _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
            });
          },
        ),
        const SizedBox(height: 32),

        // Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: mainColor))
              : PrimaryButton(
                  text: s.signupButton, // ✅ Updated
                  color: mainColor,
                  onPressed: _handleRegister,
                ),
        ),

        const SizedBox(height: 24),

        // Footer Text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              s.alreadyHaveAccount, // ✅ Updated
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                s.loginLink, // ✅ Updated
                style: TextStyle(
                  color: mainColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
