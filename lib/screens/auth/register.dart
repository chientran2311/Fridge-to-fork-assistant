import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/screens/main_screen.dart'; // Import màn hình chính

// Import widgets và service
import '../../widgets/auth/common_auth_widgets.dart'; 
import '../../services/auth_service/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color mainColor = const Color(0xFF1B3B36);
  final Color secondaryColor = const Color(0xFFF0F1F1);

  // 1. Khởi tạo Service
  final AuthService _authService = AuthService();

  // 2. Controllers để lấy dữ liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 3. Trạng thái UI
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _isLoading = false; // Trạng thái loading

  // Giải phóng bộ nhớ
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ ĐĂNG KÝ ---
  Future<void> _handleRegister() async {
    // A. Lấy dữ liệu
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    // B. Kiểm tra dữ liệu (Validate)
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    if (password != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp")),
      );
      return;
    }

    // C. Bắt đầu Loading
    setState(() => _isLoading = true);

    // D. Gọi Service đăng ký
    String? errorMessage = await _authService.registerWithEmail(
      email: email, 
      password: password
    );

    // Kiểm tra widget còn tồn tại
    if (!mounted) return;

    // E. Kết thúc Loading
    setState(() => _isLoading = false);

    // F. Xử lý kết quả
    if (errorMessage == null) {
      // Thành công: Chuyển vào màn hình chính
      // (Lưu ý: Có thể thêm logic cập nhật tên user tại đây nếu cần)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false, // Xóa hết lịch sử quay lại trang Login/Register
      );
    } else {
      // Thất bại: Hiện lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage), 
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        // --- Mobile ---
        mobileBody: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildRegisterContent(context),
            ),
          ),
        ),

        // --- Desktop ---
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

  // Nội dung Form
  Widget _buildRegisterContent(BuildContext context) {
    return Column(
      children: [
        // 1. Back Button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // 2. Avatar Widget
        const AvatarDisplay(
          imageUrl: "https://i.pravatar.cc/300",
          size: 100,
        ),
        const SizedBox(height: 24),

        // 3. Title Text
        Text(
          "Create Account",
          style: GoogleFonts.merriweather(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Start saving food today",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // 4. Các trường nhập liệu (Gắn Controller vào đây)
        // LƯU Ý: Bạn cần đảm bảo CustomAuthField có tham số 'controller'
        CustomAuthField(
          label: "Full Name",
          hintText: "Jane Doe",
          mainColor: mainColor,
          controller: _nameController, // <--- Controller
        ),
        const SizedBox(height: 16),
        
        CustomAuthField(
          label: "Email Address",
          hintText: "jane@example.com",
          mainColor: mainColor,
          controller: _emailController, // <--- Controller
        ),
        const SizedBox(height: 16),
        
        CustomAuthField(
          label: "Password",
          hintText: "........",
          isPassword: true,
          isObscure: _isPasswordObscure,
          mainColor: mainColor,
          controller: _passwordController, // <--- Controller
          onIconTap: () {
            setState(() {
              _isPasswordObscure = !_isPasswordObscure;
            });
          },
        ),
        const SizedBox(height: 16),
        
        CustomAuthField(
          label: "Confirm Password",
          hintText: "........",
          isPassword: true,
          isObscure: _isConfirmPasswordObscure,
          mainColor: mainColor,
          controller: _confirmPasswordController, // <--- Controller
          onIconTap: () {
            setState(() {
              _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
            });
          },
        ),
        const SizedBox(height: 32),

        // 5. Nút đăng ký (Gắn logic _handleRegister)
        // Chúng ta có thể cần sửa PrimaryButton để hỗ trợ loading state
        // Hoặc dùng ElevatedButton trực tiếp nếu PrimaryButton chưa hỗ trợ
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister, // Disable khi loading
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        
        const SizedBox(height: 24),

        // 6. Footer Text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                "Log in",
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