# Tests Specification

This is the tests coverage details for the spec detailed in @.agent-os/specs/2025-07-24-always-visible-controls/spec.md

> Created: 2025-07-24
> Version: 1.0.0

## Test Coverage

### Unit Tests

**SplitPriorityLayout**
- Should render three sections (primary bar, content, secondary bar) with correct proportions
- Should adjust content area height based on screen size constraints
- Should handle progress indicator visibility and positioning correctly
- Should maintain minimum heights for control bars on small screens

**PrimaryActionBar**
- Should display correct button text and style for each drill type (FINISH DRILL, LOG SET, none)
- Should enable/disable primary action button based on drill state
- Should display next drill information correctly
- Should handle missing or null nextDrillName gracefully

**LargeTimerDisplay**
- Should calculate minimum 150px font size for timer text
- Should scale font size responsively based on screen dimensions
- Should format timer duration correctly (MM:SS format)
- Should handle edge cases (0 seconds, large values, negative numbers)
- Should apply FittedBox scaling when text exceeds available space

**SecondaryControlBar**
- Should render all control buttons with correct labels and colors
- Should handle button press events for all controls (PREV, PAUSE, END, SKIP)
- Should update pause button state based on workout state
- Should provide long-press functionality for drill reset

### Integration Tests

**Layout Responsiveness**
- Should maintain control visibility on screens < 600px height (mobile)
- Should adapt timer font size appropriately on different screen sizes
- Should handle orientation changes without breaking layout
- Should work correctly in mobile browsers with reduced viewport

**Control Interaction Flow**
- Should allow completing make-target-timed drill via FINISH DRILL button regardless of content length
- Should maintain secondary control access during all drill types
- Should handle rapid button presses without UI breaking
- Should preserve control state during drill transitions

**Timer Display Integration**
- Should display timer with minimum 150px font size in all drill contexts
- Should remain readable from distance (simulated via font size testing)
- Should update timer display smoothly without layout shifts
- Should handle timer completion without control visibility issues

### Widget Tests

**Drill Widget Integration**
- Should integrate TimedDrillWidget with new layout system
- Should integrate MakeTargetTimedDrillWidget with primary action bar
- Should integrate RepBasedDrillWidget with LOG SET button positioning
- Should maintain existing drill functionality while using new layout

**Responsive Behavior**
- Should compress layout appropriately on mobile devices
- Should expand content area on larger screens
- Should adjust button sizes based on screen dimensions
- Should handle keyboard appearance without obscuring controls

**Cross-Platform Compatibility**
- Should render correctly on Android native app
- Should work properly in mobile web browsers (Safari, Chrome, Firefox)
- Should handle different device pixel densities correctly
- Should respect platform-specific safe areas and notches

### Feature Tests

**End-to-End Control Accessibility**
- Start workout, verify all controls accessible throughout entire session
- Complete make-target-timed drill with long description, verify FINISH DRILL always visible
- Test pause/resume functionality during different drill types
- Verify END workout dialog accessible from all drill states

**Distance Readability Simulation**
- Test timer visibility at minimum font sizes (150px+)
- Verify timer contrast ratios meet accessibility standards
- Test timer readability in various lighting conditions (light/dark theme)
- Validate timer display doesn't break with very long durations

**Mobile Browser Specific Tests**
- Test layout with browser address bar visible/hidden
- Verify controls remain accessible with browser chrome
- Test pull-to-refresh interference prevention
- Validate touch targets meet minimum size requirements (44px)

### Mocking Requirements

- **MediaQuery:** Mock device dimensions and screen constraints for responsive testing
- **WorkoutState:** Mock drill progression and state changes for control testing
- **Timer Updates:** Mock timer progression for display testing without waiting
- **Platform Detection:** Mock web vs mobile platform for browser-specific behavior

## Test Strategy

### Unit Test Implementation
- Use Flutter's `testWidgets()` for widget testing with mocked screen sizes
- Test responsive calculations with various `MediaQueryData` configurations
- Verify timer font size calculations across range of screen dimensions
- Mock workout state changes to test control bar updates

### Integration Test Approach
- Use Flutter integration tests to verify actual layout behavior on devices
- Test with physical devices to validate distance readability of timers
- Validate cross-platform consistency between Android app and web
- Test with various screen orientations and browser configurations

### Visual Regression Testing
- Capture screenshots of layout at different screen sizes
- Compare timer display sizing across different devices
- Verify control positioning consistency across drill types
- Test dark theme compatibility with new layout system

### Performance Testing
- Measure layout calculation performance with responsive sizing
- Test timer update performance with large font rendering
- Validate smooth transitions between drill types
- Check memory usage with frequent layout changes

## Testing Edge Cases

### Screen Size Extremes
- Very small screens (< 400px height) - old Android devices
- Very large screens (> 1200px) - tablets in landscape
- Ultra-wide aspect ratios - modern mobile devices
- Notched displays - iPhone X series and similar

### Content Overflow Scenarios
- Extremely long drill descriptions (> 500 characters)
- Very long drill names that might wrap
- Multiple lines of drill instructions
- Next drill names that are unusually long

### State Management Edge Cases
- Rapid drill advancement without timer completion
- Workout state changes during control interactions
- App backgrounding/foregrounding during active drill
- Network connectivity loss during drill execution

### Platform-Specific Edge Cases
- iOS Safari pull-to-refresh conflicts
- Android back button behavior during workouts
- Web browser zoom levels affecting layout
- Mobile keyboard appearance during text input

## Accessibility Testing

### Screen Reader Compatibility
- Verify all control buttons have proper accessibility labels
- Test timer announcements for visually impaired users
- Validate navigation flow with assistive technologies
- Ensure color contrast meets WCAG guidelines

### Touch Accessibility
- Verify minimum 44px touch targets for all controls
- Test with accessibility scaling enabled (large text)
- Validate button spacing prevents accidental presses
- Test with motor impairment simulation tools

### Cognitive Accessibility
- Verify consistent control positioning reduces cognitive load
- Test with simplified UI modes if available
- Validate clear visual hierarchy and button importance
- Ensure error states provide clear recovery paths 