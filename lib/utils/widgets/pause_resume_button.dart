import 'package:flutter/material.dart';

class PauseResumeButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onTogglePause;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const PauseResumeButton({
    super.key,
    required this.isPaused,
    required this.onTogglePause,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTogglePause,
      child: Text(
        isPaused ? 'RESUME' : '|| PAUSE',
        style: TextStyle(
          color: textColor ?? const Color(0xFF9ca3af),
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.bold,
        ),
      ),
    );
  }
} 