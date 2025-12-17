import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/screens/main_screen.dart';

// Import các Widgets UI
import 'package:fridge_to_fork_assistant/widgets/auth/common_auth_widgets.dart'; // Chứa CustomAuthField, PrimaryButton
import 'package:fridge_to_fork_assistant/widgets/auth/login_header.dart';
import 'package:fridge_to_fork_assistant/widgets/auth/login_footer.dart';
import 'package:fridge_to_fork_assistant/widgets/auth/social_buttons.dart';

// Import Service và Notification Widget
import '../../services/auth_service.dart'; // Đảm bảo đúng đường dẫn file AuthService
import '../../widgets/notification.dart';  // Đảm bảo đúng đường dẫn file CustomToast

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
  final AuthService _authService = AuthService(); // Khởi tạo Service
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true; // Ẩn hiện pass
  bool _isLoading = false; // Trạng thái loading

  // Giải phóng bộ nhớ
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ ĐĂNG NHẬP ---
  Future<void> _handleLogin() async {
    // 1. Lấy dữ liệu
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 2. Kiểm tra rỗng
    if (email.isEmpty || password.isEmpty) {
      CustomToast.show(context, "Vui lòng nhập đầy đủ Email và Mật khẩu", isError: true);
      return;
    }

    // 3. Bắt đầu Loading
    setState(() => _isLoading = true);

    // 4. Gọi Firebase qua Service
    String? errorMessage = await _authService.loginWithEmail(
      email: email, 
      password: password
    );

    // Kiểm tra widget còn tồn tại không (tránh lỗi async gap)
    if (!mounted) return;

    // 5. Kết thúc Loading
    setState(() => _isLoading = false);

    // 6. Xử lý kết quả
    if (errorMessage == null) {
      // --- THÀNH CÔNG ---
      CustomToast.show(context, "Đăng nhập thành công!");
      
      // Chuyển trang và xóa lịch sử để không back lại login được
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // --- THẤT BẠI ---
      CustomToast.show(context, errorMessage, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        // 1. Mobile
        mobileBody: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildLoginForm(context),
            ),
          ),
        ),

        // 2. Desktop/Web
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

  // --- FORM UI ---
  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LoginHeader(mainColor: mainColor),
        const SizedBox(height: 32),

        // 3. Email Field (Gắn Controller)
        CustomAuthField(
          label: "Email Address",
          hintText: "hello@example.com",
          mainColor: mainColor,
          controller: _emailController, // <--- Quan trọng
        ),
        const SizedBox(height: 20),

        // 4. Password Field (Gắn Controller)
        CustomAuthField(
          label: "Password",
          hintText: "........",
          isPassword: true,
          isObscure: _isObscure,
          onIconTap: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
          mainColor: mainColor,
          controller: _passwordController, // <--- Quan trọng
        ),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Thêm logic quên mật khẩu
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

        // 5. Login Button (Có Loading State)
        SizedBox(
          width: double.infinity,
          height: 56, // Giữ chiều cao cố định để không bị giật khi hiện loading
          child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: mainColor)) // Hiện vòng xoay
            : PrimaryButton( // Hiện nút bấm
                text: "Log In",
                onPressed: _handleLogin, // Gọi hàm logic
                // color: mainColor, // Nếu PrimaryButton có hỗ trợ đổi màu
              ),
        ),
        
        const SizedBox(height: 32),

        // 6. Social Buttons
        const SocialButtons(),
        const SizedBox(height: 40),

        // 8. Footer
        const SignupFooter(),
      ],
    );
  }
}