import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/format_duration.dart';

/// Large timer display widget optimized for distance readability during basketball training.
///
/// This widget provides:
/// - Minimum 150px font size for distance readability (6+ feet away)
/// - Responsive font scaling based on screen size
/// - FittedBox integration for proper text scaling
/// - Title and subtitle support with overflow protection
/// - Consistent dark theme styling
///
/// Font size calculation:
/// - Base: max(150px, screenWidth * 0.35)
/// - Constraint: min(calculated, availableHeight * 0.6)
/// - This ensures readable text that fits within layout constraints
class LargeTimerDisplay extends StatelessWidget {
  /// The time in seconds to display
  final int seconds;
  
  /// Color for the timer text
  final Color textColor;
  
  /// Optional title to display above the timer (will be uppercased)
  final String? title;
  
  /// Optional subtitle to display below the timer with overflow protection
  final String? subtitle;

  const LargeTimerDisplay({
    Key? key,
    required this.seconds,
    required this.textColor,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final availableHeight = mediaQuery.size.height * 0.4; // Max 40% of screen height
    
    // Calculate responsive font size with minimum 150px for distance readability
    double fontSize = math.max(150.0, screenWidth * 0.35);
    // Don't exceed 60% of available height to prevent layout overflow
    fontSize = math.min(fontSize, availableHeight * 0.6);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title section (if provided)
        if (title != null) ...[
          Text(
            title!.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFf9fafb),
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
        
        // Main timer display with responsive scaling
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatDuration(seconds),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: textColor,
              height: 1.0, // Tight line height for better fitting
            ),
          ),
        ),
        
        // Subtitle section (if provided) with overflow protection
        if (subtitle != null) ...[
          const SizedBox(height: 20),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF9ca3af),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
} 