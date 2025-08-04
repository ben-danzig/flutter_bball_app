# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-07-24-always-visible-controls/spec.md

> Created: 2025-07-24
> Version: 1.0.0

## Technical Requirements

- **Fixed Layout Structure**: Three-section layout (primary bar, content area, secondary bar) with guaranteed visibility
- **Large Timer Fonts**: Minimum 150px font size for timer displays, scalable based on available screen space
- **Responsive Height Management**: Dynamic content area sizing that adapts to screen height constraints
- **Mobile Browser Compatibility**: Handle reduced viewport height from browser chrome and address bars
- **Control Priority System**: Drill-specific primary actions at top, universal secondary actions at bottom
- **Touch-Friendly Sizing**: Minimum 44px tap targets for all control buttons

## Approach Options

**Option A: Modify ActiveDrillLayout with Fixed Heights**
- Pros: Minimal changes to existing structure, straightforward implementation
- Cons: Fixed heights don't adapt well to different screen sizes, might waste space

**Option B: Complete Layout Restructure with Flex** (Selected)
- Pros: Flexible, responsive, efficient space usage, future-proof
- Cons: More extensive changes, requires updating all drill widgets

**Option C: Overlay Controls with Z-Index**
- Pros: No layout constraints, always visible
- Cons: Covers drill content, accessibility issues, complex interaction handling

**Rationale:** Option B provides the best balance of flexibility and user experience. The flex-based approach ensures controls are always visible while maximizing space efficiency and providing a foundation for future responsive enhancements.

## External Dependencies

No new external dependencies required. Implementation uses existing Flutter layout widgets (Column, Expanded, SafeArea, etc.).

## Implementation Details

### 1. New Layout Widget: SplitPriorityLayout

```dart
class SplitPriorityLayout extends StatelessWidget {
  final Widget primaryActionBar;
  final Widget content;
  final Widget secondaryControlBar;
  final bool showProgressIndicator;
  final double progress;

  const SplitPriorityLayout({
    Key? key,
    required this.primaryActionBar,
    required this.content,
    required this.secondaryControlBar,
    this.showProgressIndicator = true,
    this.progress = 0.0,
  }) : super(key: key);

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
            Container(
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
            Container(
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
```

### 2. Primary Action Bar Components

```dart
class PrimaryActionBar extends StatelessWidget {
  final DrillType drillType;
  final VoidCallback? onPrimaryAction;
  final String? nextDrillName;
  final bool isPrimaryActionEnabled;

  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Next drill info
          Text(
            'UP NEXT: ${nextDrillName ?? "Workout Complete"}',
            style: const TextStyle(color: Color(0xFF9ca3af), fontSize: 12),
          ),
          const SizedBox(height: 8),
          
          // Primary action button
          _buildPrimaryActionButton(drillType),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton(DrillType drillType) {
    switch (drillType) {
      case DrillType.MAKE_TARGET_TIMED:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(200, 44),
          ),
          onPressed: isPrimaryActionEnabled ? onPrimaryAction : null,
          child: const Text('FINISH DRILL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      case DrillType.REP_BASED:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            minimumSize: const Size(200, 44),
          ),
          onPressed: onPrimaryAction,
          child: const Text('LOG SET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      case DrillType.TIMED:
        return Container(); // No primary action for timed drills
      default:
        return Container();
    }
  }
}
```

### 3. Enhanced Timer Display

```dart
class LargeTimerDisplay extends StatelessWidget {
  final int seconds;
  final Color textColor;
  final String? title;
  final String? subtitle;

  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final availableHeight = mediaQuery.size.height * 0.4; // Max 40% of screen
    
    // Calculate responsive font size (minimum 150px, scales up on larger screens)
    double fontSize = math.max(150, screenWidth * 0.35);
    fontSize = math.min(fontSize, availableHeight * 0.6); // Don't exceed 60% of available height
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
```

### 4. Secondary Control Bar

```dart
class SecondaryControlBar extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onTogglePause;
  final VoidCallback onPreviousDrill;
  final VoidCallback onNextDrill;
  final VoidCallback onEndWorkout;
  final VoidCallback onResetCurrentDrill;

  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous/Reset
          GestureDetector(
            onTap: onPreviousDrill,
            onLongPress: onResetCurrentDrill,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          
          // Pause/Resume
          PauseResumeButton(
            isPaused: isPaused,
            onTogglePause: onTogglePause,
          ),
          
          // End Workout
          TextButton(
            onPressed: onEndWorkout,
            child: const Text(
              'END',
              style: TextStyle(
                color: Color(0xFFef4444),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Skip/Next
          GestureDetector(
            onTap: onNextDrill,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const Text(
                'SKIP >',
                style: TextStyle(
                  color: Color(0xFF9ca3af),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5. Responsive Content Container

```dart
class ResponsiveContentArea extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    
    // Adjust padding based on screen height
    EdgeInsets effectivePadding = padding ?? const EdgeInsets.all(20);
    if (screenHeight < 600) {
      // Smaller padding on short screens
      effectivePadding = const EdgeInsets.all(10);
    }
    
    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: child,
    );
  }
}
```

## File Changes Required

1. **Create**: `lib/widgets/layout/split_priority_layout.dart`
2. **Create**: `lib/widgets/controls/primary_action_bar.dart`
3. **Create**: `lib/widgets/controls/secondary_control_bar.dart`
4. **Create**: `lib/widgets/display/large_timer_display.dart`
5. **Create**: `lib/widgets/layout/responsive_content_area.dart`
6. **Modify**: `lib/screens/active/active_workout_screen.dart`
7. **Modify**: `lib/screens/active/widgets/timed_drill_widget.dart`
8. **Modify**: `lib/screens/active/widgets/make_target_timed_drill_widget.dart`
9. **Modify**: `lib/screens/active/widgets/rep_based_drill_widget.dart`
10. **Modify**: `lib/screens/active/widgets/read_and_react_drill_widget.dart`
11. **Remove**: `lib/screens/active/widgets/active_drill_layout.dart` (replaced by SplitPriorityLayout)

## Responsive Design Strategy

### Mobile Portrait (< 600px height)
- Primary action bar: 60px height
- Secondary control bar: 60px height  
- Timer font size: 150px minimum
- Reduced padding: 10px instead of 20px

### Mobile Landscape (> 800px width, < 600px height)
- Timer font size: up to 200px
- Side-by-side layout for some controls
- Compressed vertical spacing

### Mobile Browser Adjustments
- Account for browser chrome reducing viewport
- Use `vh` units cautiously, prefer MediaQuery
- Test with various mobile browsers (Safari, Chrome, Firefox)

### Large Screens (> 800px width)
- Timer font size: up to 250px
- Increased control button sizes
- More generous spacing and padding

## Performance Considerations

- Use `const` constructors wherever possible to reduce rebuilds
- Minimize widget rebuilds in timer displays using keys and state management
- Leverage `MediaQuery.of(context)` caching for repeated layout calculations
- Implement efficient FittedBox sizing for large timer text 