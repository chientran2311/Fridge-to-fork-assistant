import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/screens/main_screen.dart';
import 'package:fridge_to_fork_assistant/screens/auth/register.dart';

// Import Service và Widgets
import '../../services/auth_service/auth_service.dart'; // Đảm bảo đường dẫn đúng tới file AuthService
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/button_log_reg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- KHAI BÁO BIẾN ---
  final Color mainColor = const Color(0xFF1B3B36);
  final Color secondaryColor = const Color(0xFFF0F1F1);

  // 1. Controllers để lấy dữ liệu nhập vào
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Khởi tạo AuthService
  final AuthService _authService = AuthService();

  // 3. Trạng thái giao diện
  bool _isObscure = true;
  bool _isLoading = false; // Biến để hiện vòng xoay loading

  // --- HÀM LOGIC ---

  // Hàm giải phóng bộ nhớ khi tắt màn hình
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý Đăng nhập
  Future<void> _handleLogin() async {
    // 1. Validate dữ liệu
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ Email và Mật khẩu")),
      );
      return;
    }

    // 2. Bắt đầu trạng thái loading
    setState(() => _isLoading = true);

    // 3. Gọi AuthService
    // Hàm này trả về null nếu thành công, trả về chuỗi lỗi nếu thất bại
    String? errorMessage = await _authService.loginWithEmail(
      email: email, 
      password: password
    );

    // Kiểm tra widget còn tồn tại không trước khi dùng context (tránh lỗi async gap)
    if (!mounted) return;

    // 4. Kết thúc loading
    setState(() => _isLoading = false);

    // 5. Xử lý kết quả
    if (errorMessage == null) {
      // Thành công -> Chuyển sang màn hình chính
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Thất bại -> Hiện thông báo lỗi từ Service trả về
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        // Mobile
        mobileBody: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildLoginForm(context),
            ),
          ),
        ),
        // Desktop/Web
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.kitchen, size: 40, color: mainColor),
        ),
        const SizedBox(height: 24),

        // 2. Welcome Text
        Text(
          "Welcome Back!",
          style: GoogleFonts.merriweather(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's get cooking with what you have.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // 3. Email Field (Đã gắn Controller)
        AuthTextField(
          label: "Email Address",
          hintText: "hello@example.com",
          icon: Icons.mail_outline,
          controller: _emailController, // <-- Gắn controller vào đây
        ),
        const SizedBox(height: 20),

        // 4. Password Field (Đã gắn Controller)
        AuthTextField(
          label: "Password",
          hintText: "........",
          icon: Icons.lock_outline,
          isPassword: true,
          isObscure: _isObscure,
          controller: _passwordController, // <-- Gắn controller vào đây
          onIconTap: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Thêm logic quên mật khẩu sau
            },
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 5. Login Button (Có Loading)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            // Nếu đang loading thì disable nút (null) để tránh bấm nhiều lần
            onPressed: _isLoading ? null : _handleLogin, 
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: _isLoading 
              // Hiển thị vòng xoay nếu đang xử lý
              ? const SizedBox(
                  width: 24, 
                  height: 24, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
              // Hiển thị chữ nếu bình thường
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
          ),
        ),
        const SizedBox(height: 32),

        // 6. Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Or continue with",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 32),

        // 7. Google Button
        Row(
          children: [
            Expanded(
              child: ButtonLogReg(
                text: "Google",
                icon: Icons.g_mobiledata,
                iconColor: Colors.red,
                onTap: () {
                  // TODO: Gọi hàm Google Login từ AuthService sau
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // 8. Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "New here? ",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text(
                "Create an account",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}