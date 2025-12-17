import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Đảm bảo import đúng đường dẫn file responsive_ui.dart của bạn
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'register.dart';
import '../main_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Màu chủ đạo (Dark Green)
  final Color mainColor = const Color(0xFF1B3B36);
  final Color secondaryColor = const Color(0xFFF0F1F1);

  bool _isObscure = true; // Trạng thái ẩn/hiện mật khẩu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        // 1. Giao diện Mobile: Full màn hình, cuộn dọc
        mobileBody: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildLoginForm(context),
            ),
          ),
        ),

        // 2. Giao diện Desktop/Web: Một Card nằm giữa màn hình
        desktopBody: Container(
          color: secondaryColor, // Nền xám nhẹ cho desktop
          child: Center(
            child: Container(
              width: 500, // Giới hạn chiều rộng
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

  // --- HÀM XÂY DỰNG FORM CHUNG (Dùng cho cả Mobile & Desktop) ---
  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Logo Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.1), // Màu xanh nhạt nền icon
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
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),

        // 3. Email Field
        _buildLabel("Email Address"),
        const SizedBox(height: 8),
        _buildTextField(
          hintText: "hello@example.com",
          icon: Icons.mail_outline,
        ),
        const SizedBox(height: 20),

        // 4. Password Field
        _buildLabel("Password"),
        const SizedBox(height: 8),
        _buildTextField(
          hintText: "........",
          icon: _isObscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          isPassword: true,
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
            onPressed: () {},
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

        // 5. Login Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Xử lý kiểm tra tài khoản mật khẩu ở đây...

              // Nếu thành công, chuyển sang MainScreen
              // Dùng pushReplacement để người dùng không bấm nút Back quay lại Login được
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // 6. Or continue with
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

        // 7. Social Buttons (Google & Apple)
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                text: "Google",
                icon: Icons
                    .g_mobiledata, // Thay bằng ảnh logo Google nếu có asset
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSocialButton(
                text: "Apple",
                icon: Icons.apple,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // 8. Footer: Create Account
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "New here? ",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                // Điều hướng sang trang đăng ký
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: Text(
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

  // --- Widget Label ---
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // --- Widget TextField Tùy biến ---
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onIconTap,
  }) {
    return TextField(
      obscureText: isPassword ? _isObscure : false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        suffixIcon: IconButton(
          icon: Icon(icon, color: Colors.grey[600]),
          onPressed: onIconTap,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: mainColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // --- Widget Social Button ---
  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
