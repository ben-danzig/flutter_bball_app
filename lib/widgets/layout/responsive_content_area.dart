import 'package:flutter/material.dart';

/// A responsive container that adapts padding based on screen size constraints.
/// 
/// This widget provides adaptive padding to optimize space usage:
/// - Standard padding (20px) on normal screens (height >= 600px)
/// - Reduced padding (10px) on small screens (height < 600px)
/// - Custom padding can be provided to override responsive behavior
///
/// Used within SplitPriorityLayout to ensure content area adapts to
/// available screen space while maintaining proper spacing.
class ResponsiveContentArea extends StatelessWidget {
  /// The child widget to display within the responsive container
  final Widget child;
  
  /// Optional custom padding to override responsive padding logic
  final EdgeInsets? padding;

  const ResponsiveContentArea({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    
    // Determine effective padding based on screen height or custom override
    EdgeInsets effectivePadding;
    
    if (padding != null) {
      // Use custom padding if provided
      effectivePadding = padding!;
    } else {
      // Apply responsive padding logic
      if (screenHeight < 600) {
        // Smaller padding on short screens to maximize content space
        effectivePadding = const EdgeInsets.all(10);
      } else {
        // Standard padding on normal/large screens
        effectivePadding = const EdgeInsets.all(20);
      }
    }
    
    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: child,
    );
  }
} 