import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet => MediaQuery.of(this).size.width >= 600 && MediaQuery.of(this).size.width < 1024;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1024;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktopBody != null) {
      return desktopBody!;
    }
    if (context.isTablet && tabletBody != null) {
      return tabletBody!;
    }
    return mobileBody;
  }
}
