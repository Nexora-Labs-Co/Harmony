import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;
  final double breakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
    this.breakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return desktopBody;
        } else {
          return mobileBody;
        }
      },
    );
  }
}

bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= 1024;
}

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 1024;
}
