import 'package:flutter/material.dart';

/// A layout widget that provides a split priority design with fixed control bars
/// and a flexible content area. Used for always-visible controls in workout screens.
///
/// The layout consists of three main sections:
/// - Primary Action Bar (top, fixed height)
/// - Content Area (middle, flexible/expandable)  
/// - Secondary Control Bar (bottom, fixed height)
///
/// This layout ensures critical controls are always visible while maximizing
/// space for drill content and maintaining responsive behavior.
class SplitPriorityLayout extends StatelessWidget {
  /// Widget to display in the primary action bar (top section)
  final Widget primaryActionBar;
  
  /// Widget to display in the main content area (middle section)
  final Widget content;
  
  /// Widget to display in the secondary control bar (bottom section)
  final Widget secondaryControlBar;
  
  /// Whether to show the progress indicator between content and secondary bar
  final bool showProgressIndicator;
  
  /// Progress value for the progress indicator (0.0 to 1.0)
  final double progress;

  const SplitPriorityLayout({
    super.key,
    required this.primaryActionBar,
    required this.content,
    required this.secondaryControlBar,
    this.showProgressIndicator = true,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final safeHeight = screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Column(
          children: [
            // Primary Action Bar (Fixed Height)
            SizedBox(
              height: 70,
              width: double.infinity,
              child: primaryActionBar,
            ),
            
            // Content Area (Flexible)
            Expanded(
              child: content,
            ),
            
            // Progress Indicator (if enabled)
            if (showProgressIndicator) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF1f2937),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3b82f6)),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
            ],
            
            // Secondary Control Bar (Fixed Height)
            SizedBox(
              height: 70,
              width: double.infinity,
              child: secondaryControlBar,
            ),
          ],
        ),
      ),
    );
  }
} 