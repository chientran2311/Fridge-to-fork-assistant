import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/screens/main_screen.dart'; // Import màn hình chính

// Import widgets, service và toast
import '../../widgets/auth/common_auth_widgets.dart'; 
import '../../services/auth_service.dart';
import '../../widgets/notification.dart'; // Import CustomToast

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- CẤU HÌNH UI ---
  final Color mainColor = const Color(0xFF1B3B36);
  final Color secondaryColor = const Color(0xFFF0F1F1);

  // --- LOGIC AUTH ---
  final AuthService _authService = AuthService();
  
  // 1. Khai báo các Controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 2. Các biến trạng thái
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

    // B. Validate (Kiểm tra lỗi)
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPass.isEmpty) {
      CustomToast.show(context, "Vui lòng điền đầy đủ thông tin", isError: true);
      return;
    }

    if (password != confirmPass) {
      CustomToast.show(context, "Mật khẩu xác nhận không khớp", isError: true);
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
      // --- THÀNH CÔNG ---
      CustomToast.show(context, "Tạo tài khoản thành công! Vui lòng đăng nhập.");
      
      // SỬA Ở ĐÂY:
      // pop(context) sẽ đóng màn hình đăng ký và quay lại màn hình trước đó (là Login)
      if (mounted) {
        Navigator.pop(context); 
      }
      
      // Hoặc nếu bạn muốn chắc chắn chuyển sang Login (trong trường hợp không phải pop):
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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

        // 4. Các trường nhập liệu (GẮN CONTROLLER VÀO ĐÂY)
        CustomAuthField(
          label: "Full Name",
          hintText: "Jane Doe",
          mainColor: mainColor,
          controller: _nameController, // <--- Controller Tên
        ),
        const SizedBox(height: 16),
        
        CustomAuthField(
          label: "Email Address",
          hintText: "jane@example.com",
          mainColor: mainColor,
          controller: _emailController, // <--- Controller Email
        ),
        const SizedBox(height: 16),
        
        CustomAuthField(
          label: "Password",
          hintText: "........",
          isPassword: true,
          isObscure: _isPasswordObscure,
          mainColor: mainColor,
          controller: _passwordController, // <--- Controller Pass
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
          controller: _confirmPasswordController, // <--- Controller Confirm Pass
          onIconTap: () {
            setState(() {
              _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
            });
          },
        ),
        const SizedBox(height: 32),

        // 5. Nút đăng ký (Có Loading State)
        SizedBox(
          width: double.infinity,
          height: 56, // Chiều cao cố định
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: mainColor)) // Vòng xoay khi loading
              : PrimaryButton(
                  text: "Sign Up",
                  color: mainColor,
                  onPressed: _handleRegister, // Gọi hàm xử lý đăng ký
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