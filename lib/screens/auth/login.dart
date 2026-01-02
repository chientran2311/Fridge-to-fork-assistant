import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import '../../utils/database_seeder.dart';
import 'package:go_router/go_router.dart';
// Import Localization
import '../../l10n/app_localizations.dart';

// Import các Widgets UI
import 'package:fridge_to_fork_assistant/widgets/auth/common_auth_widgets.dart';
import 'package:fridge_to_fork_assistant/widgets/auth/login_header.dart';
import 'package:fridge_to_fork_assistant/widgets/auth/login_footer.dart';
import 'package:fridge_to_fork_assistant/widgets/auth/social_buttons.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/notification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- CẤU HÌNH UI ---
  final Color mainColor = const Color(0xFF1B3B36);
  final Color secondaryColor = const Color(0xFFF0F1F1);

  // --- LOGIC AUTH ---
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Lấy instance ngôn ngữ để dùng trong hàm async
    final s = AppLocalizations.of(context)!;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomToast.show(context, s.loginErrorMissing, isError: true); // ✅ Updated
      return;
    }

    setState(() => _isLoading = true);

    String? errorMessage = await _authService.loginWithEmail(
      email: email, 
      password: password
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (errorMessage == null) {
      CustomToast.show(context, s.loginSuccess); // ✅ Updated
      if (mounted) {
        context.go('/fridge'); 
      }
    } else {
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
              child: _buildLoginForm(context),
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
              child: _buildLoginForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final s = AppLocalizations.of(context)!; // ✅ Lấy ngôn ngữ

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LoginHeader(mainColor: mainColor),
        const SizedBox(height: 32),

        // Email Field
        CustomAuthField(
          label: s.emailLabel, // ✅ Updated
          hintText: s.emailHint, // ✅ Updated
          mainColor: mainColor,
          controller: _emailController,
        ),
        const SizedBox(height: 20),

        // Password Field
        CustomAuthField(
          label: s.passwordLabel, // ✅ Updated
          hintText: s.passwordHint, // ✅ Updated
          isPassword: true,
          isObscure: _isObscure,
          onIconTap: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
          mainColor: mainColor,
          controller: _passwordController,
        ),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Logic quên mật khẩu
            },
            child: Text(
              s.forgotPassword, // ✅ Updated
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Login Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: mainColor))
            : PrimaryButton(
                text: s.loginButton, // ✅ Updated
                onPressed: _handleLogin,
              ),
        ),
        
        const SizedBox(height: 32),
        const SocialButtons(),
        const SizedBox(height: 40),
        const SignupFooter(),
        const SizedBox(height: 50),

        // --- DEV AREA ---
        // --- REMOVED: Seeder moved to Settings/Debug Tools screen ---
      ],
    );
  }
}