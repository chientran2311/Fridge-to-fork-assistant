// lib/screens/auth/login.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/auth/rotate_logo.dart';
import '../../widgets/auth/big_title.dart';
import '../../widgets/auth/custom_input.dart';
import '../../widgets/auth/primary_button.dart';
import 'register.dart';
import '../fridge/fridge_home.dart';
import '../../utils/responsive_layout.dart'; // Import file responsive
import '../../widgets/recipe/bottom_nav.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF214130);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        // LayoutBuilder giúp ta lấy chiều cao thực tế của màn hình
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                // Đảm bảo nội dung luôn có chiều cao tối thiểu bằng màn hình
                // Điều này giúp Spacer() hoạt động được trong SingleChildScrollView
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  // Dùng Container này để giới hạn chiều rộng trên Web/Desktop
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                        maxWidth:
                            450), // ⭐ CHỈNH SỬA QUAN TRỌNG: Max width cho form
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          const RotatedLogo(),
                          // Dùng khoảng cách linh hoạt thay vì cố định 120
                          SizedBox(
                              height: ResponsiveLayout.isMobile(context)
                                  ? 60
                                  : 100),
                          const BigTitle(),
                          const SizedBox(height: 30),
                          const CustomInput(
                            hint: "Email",
                            obscure: false,
                          ),
                          const SizedBox(height: 16),
                          const CustomInput(
                            hint: "Password",
                            obscure: true,
                          ),
                          const SizedBox(height: 30),
                          PrimaryButton(
                            text: "Explore the app",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // ❌ SAI: Đừng gọi trực tiếp FridgeHomeScreen
                                  // builder: (context) => const FridgeHomeScreen(),

                                  // ✅ ĐÚNG: Hãy gọi BottomNav.
                                  // BottomNav sẽ tự động hiển thị FridgeHomeScreen là màn hình đầu tiên (index 0).
                                  builder: (context) => const BottomNav(),
                                ),
                              );
                            },
                          ),

                          // Spacer sẽ đẩy phần dưới xuống đáy màn hình
                          const Spacer(),

                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Registerscreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Don’t have account? Register",
                              style: GoogleFonts.merriweather(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
