import 'package:flutter/material.dart';

/// Responsive breakpoint constants and utilities for consistent responsive behavior
/// across the basketball training app.
/// 
/// Provides breakpoint detection, responsive padding, and font scaling
/// to ensure optimal layout on different screen sizes, especially mobile devices.
class ResponsiveBreakpoints {
  // Breakpoint constants based on mobile-first design
  static const double mobileMaxWidth = 800;
  static const double smallHeightThreshold = 600;
  static const double desktopMinWidth = 801;

  /// Returns true if the current screen is considered mobile (width <= 800px)
  static bool isMobile(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth <= mobileMaxWidth;
  }

  /// Returns true if the current screen has small height (< 600px)
  /// Used for adjusting padding and layout on constrained vertical space
  static bool isSmallHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight < smallHeightThreshold;
  }

  /// Returns true if the current screen is considered desktop (width > 800px)
  static bool isDesktop(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > mobileMaxWidth;
  }

  /// Returns true if the screen is in landscape mode
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  /// Returns true if the screen is in portrait mode
  static bool isPortrait(BuildContext context) {
    return !isLandscape(context);
  }
}

/// Utility functions for responsive design calculations
class ResponsiveUtils {
  /// Returns appropriate content padding based on screen size
  /// - Small screens (height < 600px): 10px padding
  /// - Normal screens: 20px padding
  static EdgeInsets getContentPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isSmallHeight(context)) {
      return const EdgeInsets.all(10);
    }
    return const EdgeInsets.all(20);
  }

  /// Returns font scale factor for timer displays based on screen size
  /// Used to ensure distance-readable timers across different devices
  static double getTimerFontScale(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Base scale for mobile devices
    double scale = 1.0;
    
    // Adjust scale based on screen dimensions
    if (ResponsiveBreakpoints.isDesktop(context)) {
      // Larger scale for desktop/tablet screens
      scale = 1.5;
    } else if (ResponsiveBreakpoints.isSmallHeight(context)) {
      // Slightly smaller scale for very constrained screens
      scale = 0.9;
    }
    
    // Additional scaling based on actual screen dimensions
    final baseWidth = 400.0; // Reference mobile width
    final widthScale = screenWidth / baseWidth;
    
    // Clamp the scale to reasonable bounds
    scale *= widthScale.clamp(0.8, 2.0);
    
    return scale;
  }

  /// Returns minimum font size for timer display based on screen size
  /// Ensures 150px minimum for distance readability
  static double getTimerMinFontSize(BuildContext context) {
    const baseMinSize = 150.0;
    final scale = getTimerFontScale(context);
    return baseMinSize * scale;
  }

  /// Returns appropriate control bar height based on screen constraints
  static double getControlBarHeight(BuildContext context) {
    if (ResponsiveBreakpoints.isSmallHeight(context)) {
      return 60.0; // Slightly smaller on very constrained screens
    }
    return 70.0; // Standard height
  }

  /// Returns appropriate button size for touch targets
  /// Ensures minimum 44px touch targets on all devices
  static double getMinTouchTarget(BuildContext context) {
    return 44.0; // iOS and Android accessibility guideline
  }

  /// Returns spacing between elements based on screen size
  static double getVerticalSpacing(BuildContext context) {
    if (ResponsiveBreakpoints.isSmallHeight(context)) {
      return 8.0; // Reduced spacing on small screens
    }
    return 16.0; // Standard spacing
  }
} 