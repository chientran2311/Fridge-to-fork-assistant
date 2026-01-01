import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import '../../utils/database_seeder.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

// Widgets
import 'package:fridge_to_fork_assistant/widgets/auth/common_auth_widgets.dart';
import 'package:fridge_to_fork_assistant/widgets/auth/login_header.dart';
import 'package:fridge_to_fork_assistant/widgets/auth/login_footer.dart';
import 'package:fridge_to_fork_assistant/widgets/auth/social_buttons.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/notification.dart';

// [NEW] Import Notification Service
import '../../data/services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // UI Config
  final Color mainColor = const Color(0xFF1B3B36);
  final Color secondaryColor = const Color(0xFFF0F1F1);

  // Logic Auth
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
    final s = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomToast.show(context, s.loginErrorMissing, isError: true);
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
      CustomToast.show(context, s.loginSuccess);
      
      // [NEW] LƯU FCM TOKEN VÀO FIRESTORE NGAY KHI LOGIN THÀNH CÔNG
      // Backend cần cái này để gửi thông báo hết hạn
      try {
        await NotificationService().saveTokenToDatabase();
        print("✅ Đã lưu FCM Token sau khi login");
      } catch (e) {
        print("⚠️ Lỗi lưu token: $e");
      }

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
    final s = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LoginHeader(mainColor: mainColor),
        const SizedBox(height: 32),

        CustomAuthField(
          label: s.emailLabel,
          hintText: s.emailHint,
          mainColor: mainColor,
          controller: _emailController,
        ),
        const SizedBox(height: 20),

        CustomAuthField(
          label: s.passwordLabel,
          hintText: s.passwordHint,
          isPassword: true,
          isObscure: _isObscure,
          onIconTap: () => setState(() => _isObscure = !_isObscure),
          mainColor: mainColor,
          controller: _passwordController,
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Logic quên mật khẩu
            },
            child: Text(
              s.forgotPassword,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: mainColor))
            : PrimaryButton(
                text: s.loginButton,
                onPressed: _handleLogin,
              ),
        ),
        
        const SizedBox(height: 32),
        const SocialButtons(),
        const SizedBox(height: 40),
        const SignupFooter(),
        const SizedBox(height: 50),

        // DEV AREA
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                s.devAreaTitle,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              TextButton.icon(
                icon: const Icon(Icons.cloud_upload, color: Colors.red),
                label: Text(s.devSeedDatabase, style: const TextStyle(color: Colors.red)),
                onPressed: () async {
                  CustomToast.show(context, s.devSeeding);
                  await DatabaseSeeder().seedDatabase();
                  if (context.mounted) {
                     CustomToast.show(context, s.devSeedSuccess);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}