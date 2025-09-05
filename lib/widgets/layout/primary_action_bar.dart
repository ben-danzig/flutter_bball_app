import 'package:flutter/material.dart';
import '../../utils/drill_types.dart';

/// Primary action bar that displays drill-specific actions at the top of the split priority layout.
/// 
/// This widget adapts its content based on the drill type:
/// - MAKE_TARGET_TIMED: Shows green "FINISH DRILL" button
/// - REP_BASED: Shows blue "LOG SET" button  
/// - TIMED & READ_AND_REACT: No primary action button
///
/// Always displays "UP NEXT" information with the next drill name or "Workout Complete".
class PrimaryActionBar extends StatelessWidget {
  /// The type of the current drill
  final DrillType drillType;
  
  /// The name of the next drill, or null if workout is complete
  final String? nextDrillName;
  
  /// Callback for when the primary action button is pressed
  final VoidCallback? onPrimaryAction;
  
  /// Whether the primary action button should be enabled
  final bool isPrimaryActionEnabled;

  const PrimaryActionBar({
    super.key,
    required this.drillType,
    this.nextDrillName,
    this.onPrimaryAction,
    this.isPrimaryActionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Next drill info
          Text(
            'UP NEXT: ${nextDrillName ?? "Workout Complete"}',
            style: const TextStyle(
              color: Color(0xFF9ca3af),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Primary action button (if drill type requires one)
          _buildPrimaryActionButton(),
        ],
      ),
    );
  }

  /// Build the primary action button based on drill type
  Widget _buildPrimaryActionButton() {
    // Check if this drill type needs a primary action
    if (!DrillTypeUtils.hasPrimaryAction(drillType)) {
      return const SizedBox.shrink();
    }

    final buttonText = DrillTypeUtils.getPrimaryActionText(drillType);
    final buttonColorInt = DrillTypeUtils.getPrimaryActionColor(drillType);
    
    if (buttonText == null || buttonColorInt == null) {
      return const SizedBox.shrink();
    }

    final buttonColor = Color(buttonColorInt);
    
    // Determine if button should be enabled
    final bool isEnabled = isPrimaryActionEnabled && onPrimaryAction != null;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        disabledBackgroundColor: buttonColor.withOpacity(0.5),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withOpacity(0.7),
        minimumSize: const Size(200, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: isEnabled ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: isEnabled ? onPrimaryAction : null,
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
} 