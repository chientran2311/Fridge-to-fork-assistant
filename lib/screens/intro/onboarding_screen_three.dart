import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/responsive_ui.dart';

/// Widget nội dung cho trang onboarding 3 (dùng trong PageView)
/// Không có Scaffold, SafeArea, top bar hay pagination dots
class OnboardingContentThree extends StatelessWidget {
  const OnboardingContentThree({super.key});

  // --- MÀU SẮC THEME ---
  static const Color kPrimaryColor = Color(0xFF1B5E20);
  static const Color kTextColor = Color(0xFF1B3B36);
  static const Color kRedAlert = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // HERO SECTION: NOTIFICATION & RIPPLE
          Expanded(
            flex: 8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Hiệu ứng vòng tròn lan tỏa (Ripple Background)
                _buildRippleCircle(280, 0.03),
                _buildRippleCircle(220, 0.05),
                _buildRippleCircle(160, 0.08),

                // Thẻ Cảnh báo (Notification Card)
                Container(
                  width: context.percentWidth(75),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Chuông
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kRedAlert.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active,
                            color: kRedAlert, size: 24),
                      ),
                      const SizedBox(width: 12),

                      // Nội dung thông báo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "CẢNH BÁO HẾT HẠN",
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[500],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                // Chấm đỏ nhỏ báo chưa đọc
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      color: kRedAlert, shape: BoxShape.circle),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Sữa tươi",
                              style: GoogleFonts.merriweather(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    height: 1.4),
                                children: [
                                  const TextSpan(text: "Hết hạn trong "),
                                  TextSpan(
                                    text: "2 ngày",
                                    style: GoogleFonts.inter(
                                      color: kRedAlert,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ".\nHãy sử dụng ngay!"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge Tiết kiệm (Piggy Bank)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.savings,
                            color: kPrimaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "+ 50k VNĐ",
                          style: GoogleFonts.inter(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TEXT SECTION
          Text(
            "Tạm Biệt\nLãng Phí",
            textAlign: TextAlign.center,
            style: GoogleFonts.merriweather(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kTextColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: context.percentWidth(90),
            child: Text(
              "Nhận cảnh báo trước khi thực phẩm hỏng.\nTiết kiệm tiền và bảo vệ môi trường.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper vẽ vòng tròn background
  Widget _buildRippleCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kPrimaryColor.withOpacity(opacity),
      ),
    );
  }
}
