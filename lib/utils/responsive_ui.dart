/// ============================================
/// RESPONSIVE UI - ADAPTIVE LAYOUT UTILITIES
/// ============================================
/// 
/// Provides responsive design utilities for multi-platform support.
/// 
/// Breakpoints:
/// - Mobile: < 600px
/// - Tablet: 600px - 1100px
/// - Desktop: > 1100px
/// 
/// Components:
/// - ResponsiveBreakpoints: Constant breakpoint values
/// - ResponsiveLayout: Widget that renders different layouts per screen size
/// - BuildContext extensions: Quick device type checks
/// 
/// Usage Examples:
///   ResponsiveLayout(
///     mobileBody: MobileView(),
///     tabletBody: TabletView(),
///     desktopBody: DesktopView(),
///   )
/// 
///   if (context.isMobile) { ... }
///   if (context.isDesktop) { ... }
/// 
/// ============================================

import 'package:flutter/material.dart';

/// Breakpoint configuration for responsive design
class ResponsiveBreakpoints {
  static const int mobile = 600;
  static const int tablet = 1100;
  // Màn hình > 1100 sẽ được tính là Desktop
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody; // Optional: Nếu không có sẽ dùng mobile hoặc desktop tùy logic
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    required this.desktopBody,
  });

  // --- HÀM TIỆN ÍCH KIỂM TRA MÀN HÌNH (STATIC) ---
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.mobile &&
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          return desktopBody;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobile) {
          // Nếu có tabletBody thì trả về, không thì trả về desktopBody (hoặc mobileBody tùy thiết kế)
          // Ở đây tôi ưu tiên trả về mobileBody nếu chưa thiết kế tablet riêng, 
          // hoặc bạn có thể trả về desktopBody nếu giao diện tablet giống desktop hơn.
          return tabletBody ?? mobileBody; 
        } else {
          return mobileBody;
        }
      },
    );
  }
}

// --- EXTENSION TIỆN ÍCH (Giúp code ngắn gọn hơn) ---
extension ResponsiveExtension on BuildContext {
  // Lấy chiều rộng màn hình
  double get screenWidth => MediaQuery.of(this).size.width;
  
  // Lấy chiều cao màn hình
  double get screenHeight => MediaQuery.of(this).size.height;

  // Lấy phần trăm chiều rộng (Ví dụ: context.percentWidth(50) = 50% màn hình)
  double percentWidth(double percent) => screenWidth * (percent / 100);
  
  // Lấy phần trăm chiều cao
  double percentHeight(double percent) => screenHeight * (percent / 100);

  // Kiểm tra nhanh loại màn hình
  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);
}