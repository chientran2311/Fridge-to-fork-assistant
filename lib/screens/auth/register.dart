import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Đảm bảo import đúng đường dẫn file responsive_ui.dart
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Màu chủ đạo
  final Color mainColor = const Color(0xFF1B3B36);
  final Color secondaryColor = const Color(0xFFF0F1F1);

  // Trạng thái ẩn/hiện mật khẩu riêng biệt cho 2 ô
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        // --- 1. Giao diện Mobile ---
        mobileBody: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildRegisterForm(context),
            ),
          ),
        ),

        // --- 2. Giao diện Desktop/Web ---
        desktopBody: Container(
          color: secondaryColor,
          child: Center(
            child: Container(
              width: 500, // Card cố định ở giữa màn hình
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
              child: _buildRegisterForm(context),
            ),
          ),
        ),
      ),
    );
  }

  // --- FORM LOGIC CHUNG ---
  Widget _buildRegisterForm(BuildContext context) {
    return Column(
      children: [
        // 1. Back Button (Căn trái)
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context), // Quay lại Login
          ),
        ),
        
        // 2. Avatar Image
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            // Bạn có thể thay bằng NetworkImage hoặc AssetImage
            image: const DecorationImage(
              image: NetworkImage("https://i.pravatar.cc/300"), 
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 3. Title & Subtitle
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
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),

        // 4. Form Fields
        _buildLabel("Full Name"),
        const SizedBox(height: 8),
        _buildTextField(hintText: "Jane Doe"),
        
        const SizedBox(height: 16),
        
        _buildLabel("Email Address"),
        const SizedBox(height: 8),
        _buildTextField(hintText: "jane@example.com"),
        
        const SizedBox(height: 16),

        _buildLabel("Password"),
        const SizedBox(height: 8),
        _buildTextField(
          hintText: "........",
          isPassword: true,
          isObscure: _isPasswordObscure,
          onIconTap: () {
            setState(() {
              _isPasswordObscure = !_isPasswordObscure;
            });
          },
        ),

        const SizedBox(height: 16),

        _buildLabel("Confirm Password"),
        const SizedBox(height: 8),
        _buildTextField(
          hintText: "........",
          isPassword: true,
          isObscure: _isConfirmPasswordObscure,
          onIconTap: () {
            setState(() {
              _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
            });
          },
        ),

        const SizedBox(height: 32),

        // 5. Sign Up Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Logic đăng ký
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
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

        // 6. Footer (Back to Login)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Quay lại Login
              },
              child: Text(
                "Log in",
                style: TextStyle(
                  color: mainColor, // Dùng màu xanh chủ đạo cho đẹp
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

  // --- Widget Helper: Label ---
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold, // Semi-bold giống ảnh
          color: Colors.black87,
        ),
      ),
    );
  }

  // --- Widget Helper: TextField ---
  Widget _buildTextField({
    required String hintText,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onIconTap,
  }) {
    return TextField(
      obscureText: isPassword ? isObscure : false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        // Chỉ hiện icon mắt nếu là trường password
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[500],
                ),
                onPressed: onIconTap,
              )
            : null,
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
}