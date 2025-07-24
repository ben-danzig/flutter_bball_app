import 'package:flutter/material.dart';

class CueAction {
  final String label;
  final IconData? icon;
  final Color? color;
  final String? ttsPhrase;

  CueAction({
    required this.label,
    this.icon,
    this.color,
    this.ttsPhrase,
  });

  factory CueAction.fromJson(Map<String, dynamic> json) {
    return CueAction(
      label: json['label'] as String,
      icon: json['icon'] != null ? _iconFromString(json['icon']) : null,
      color: json['color'] != null ? _colorFromHex(json['color']) : null,
      ttsPhrase: json['ttsPhrase'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'icon': icon != null ? _iconToString(icon!) : null,
        'color': color != null ? _colorToHex(color!) : null,
        'ttsPhrase': ttsPhrase,
      };

  static IconData? _iconFromString(String iconName) {
    // Add more icons as needed
    switch (iconName) {
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'directions_run':
        return Icons.directions_run;
      default:
        return null;
    }
  }

  static String? _iconToString(IconData icon) {
    // Add more icons as needed
    if (icon == Icons.arrow_back) return 'arrow_back';
    if (icon == Icons.arrow_forward) return 'arrow_forward';
    if (icon == Icons.directions_run) return 'directions_run';
    return null;
  }

  static Color _colorFromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
} 