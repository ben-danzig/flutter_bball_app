import 'package:flutter/material.dart';
import '../../utils/widgets/pause_resume_button.dart';

/// Secondary control bar that provides universal workout controls at the bottom of the split priority layout.
///
/// This widget provides consistent access to:
/// - Previous drill (tap) / Reset current drill (long press)
/// - Pause/Resume toggle using existing PauseResumeButton  
/// - End workout with confirmation dialog
/// - Skip to next drill
///
/// All controls maintain 44px minimum touch targets for accessibility
/// and use consistent styling matching the app's dark theme.
class SecondaryControlBar extends StatelessWidget {
  /// Whether the workout is currently paused
  final bool isPaused;
  
  /// Callback for toggling pause/resume state
  final VoidCallback onTogglePause;
  
  /// Callback for navigating to previous drill
  final VoidCallback onPreviousDrill;
  
  /// Callback for skipping to next drill  
  final VoidCallback onNextDrill;
  
  /// Callback for ending the workout (will show confirmation dialog)
  final VoidCallback onEndWorkout;
  
  /// Callback for resetting the current drill (triggered by long press on PREV)
  final VoidCallback onResetCurrentDrill;

  const SecondaryControlBar({
    Key? key,
    required this.isPaused,
    required this.onTogglePause,
    required this.onPreviousDrill,
    required this.onNextDrill,
    required this.onEndWorkout,
    required this.onResetCurrentDrill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous/Reset button with tap and long-press functionality
          Tooltip(
            message: 'Long press to reset drill',
            child: GestureDetector(
              onTap: onPreviousDrill,
              onLongPress: onResetCurrentDrill,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: const Text(
                  '< PREV',
                  style: TextStyle(
                    color: Color(0xFF9ca3af),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Pause/Resume button using existing widget
          PauseResumeButton(
            isPaused: isPaused,
            onTogglePause: onTogglePause,
          ),
          
          // End workout button with error color styling
          TextButton(
            onPressed: onEndWorkout,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44), // Minimum touch target
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
            child: const Text(
              'END',
              style: TextStyle(
                color: Color(0xFFef4444),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Skip/Next drill button  
          TextButton(
            onPressed: onNextDrill,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44), // Minimum touch target
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
            child: const Text(
              'SKIP >',
              style: TextStyle(
                color: Color(0xFF9ca3af),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 