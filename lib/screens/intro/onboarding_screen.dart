import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import 3 screen con
import 'onboarding_screen_one.dart';
import 'onboarding_screen_two.dart';
import 'onboarding_screen_three.dart';

// Import router để cập nhật biến runtime
import '../../router/app_router.dart' show markOnboardingCompleted;

/// Key lưu trạng thái đã xem onboarding
const String kOnboardingCompletedKey = 'onboarding_completed';

/// Wrapper Screen chứa PageView cho 3 onboarding screens
/// Sử dụng PageController để quản lý slide và index
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller để điều khiển PageView
  final PageController _pageController = PageController();

  // Index hiện tại
  int _currentIndex = 0;

  // Màu sắc theme
  static const Color kPrimaryColor = Color(0xFF1B5E20);
  static const Color kBgColor = Color(0xFFF9F9F7);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Chuyển đến trang tiếp theo
  void _nextPage() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Quay lại trang trước
  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Bỏ qua onboarding và đi đến Login
  Future<void> _skipOnboarding() async {
    await _completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  /// Hoàn thành onboarding (từ screen 3)
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompletedKey, true);

    // [QUAN TRỌNG] Cập nhật biến runtime để redirect hoạt động đúng
    markOnboardingCompleted();
  }

  /// Bắt đầu sử dụng app (từ nút ở screen 3)
  Future<void> _startApp() async {
    await _completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header với nút Bỏ qua (căn phải)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: _currentIndex < 2
                    ? TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          "Bỏ qua",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kPrimaryColor,
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 48), // Giữ chiều cao để layout ổn định
              ),
            ),

            // PageView chứa 3 screens
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: const [
                  OnboardingContentOne(),
                  OnboardingContentTwo(),
                  OnboardingContentThree(),
                ],
              ),
            ),

            // Footer: Dots indicator + Nút tiếp tục/bắt đầu
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Pagination Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? kPrimaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Nút Tiếp tục / Bắt đầu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _currentIndex < 2 ? _nextPage : _startApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentIndex < 2 ? "Tiếp tục" : "Bắt đầu ngay",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HELPER: Kiểm tra đã xem onboarding chưa (dùng trong app_router)
// ============================================================
Future<bool> hasCompletedOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(kOnboardingCompletedKey) ?? false;
}
