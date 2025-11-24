import 'package:flutter/material.dart';

class Responsive {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600 && screenWidth(context) < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= 1200;
  }

  // Responsive padding
  static EdgeInsets padding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0);
    } else {
      return EdgeInsets.symmetric(
        horizontal: screenWidth(context) * 0.05,
        vertical: 10.0,
      );
    }
  }

  // Responsive font sizes
  static double fontSize(BuildContext context, double mobileSize) {
    if (isDesktop(context)) {
      return mobileSize * 1.3;
    } else if (isTablet(context)) {
      return mobileSize * 1.15;
    }
    return mobileSize;
  }

  // Responsive spacing
  static double spacing(BuildContext context, double baseSpacing) {
    if (isDesktop(context)) {
      return baseSpacing * 1.5;
    } else if (isTablet(context)) {
      return baseSpacing * 1.2;
    }
    return baseSpacing;
  }

  // Responsive grid columns
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    }
    return 2;
  }

  // Responsive card aspect ratio
  static double cardAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 0.75;
    } else if (isTablet(context)) {
      return 0.72;
    }
    return 0.7;
  }

  // Responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) {
      return baseSize * 1.3;
    } else if (isTablet(context)) {
      return baseSize * 1.15;
    }
    return baseSize;
  }

  // Responsive banner height
  static double bannerHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 250;
    } else if (isTablet(context)) {
      return 220;
    }
    return 180;
  }

  // Responsive category height
  static double categoryHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 55;
    } else if (isTablet(context)) {
      return 50;
    }
    return 45;
  }
}

