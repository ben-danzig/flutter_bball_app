# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-07-24-always-visible-controls/spec.md

> Created: 2025-07-24
> Status: Ready for Implementation

## Tasks

- [x] 1. Create Core Layout Infrastructure
  - [x] 1.1 Write tests for SplitPriorityLayout widget with responsive height calculations
  - [x] 1.2 Implement SplitPriorityLayout widget with primary bar, content area, and secondary bar sections
  - [x] 1.3 Create ResponsiveContentArea widget with adaptive padding based on screen height
  - [x] 1.4 Add responsive design breakpoint handling for mobile vs desktop layouts
  - [x] 1.5 Verify all tests pass and layout renders correctly on different screen sizes

- [x] 2. Implement Primary Action Bar System
  - [x] 2.1 Write tests for PrimaryActionBar with drill-type-specific button rendering
  - [x] 2.2 Create PrimaryActionBar widget with dynamic button content based on drill type
  - [x] 2.3 Implement drill-specific button logic (FINISH DRILL, LOG SET, none for timed drills)
  - [x] 2.4 Add next drill name display and proper styling
  - [x] 2.5 Integrate button enable/disable state based on drill completion status
  - [x] 2.6 Verify all tests pass and buttons appear correctly for each drill type

- [x] 3. Create Large Timer Display Component
  - [x] 3.1 Write tests for LargeTimerDisplay with minimum 150px font size calculations
  - [x] 3.2 Implement LargeTimerDisplay widget with responsive font size scaling
  - [x] 3.3 Add font size calculation logic (minimum 150px, scales up on larger screens)
  - [x] 3.4 Implement FittedBox integration for text scaling when content exceeds space
  - [x] 3.5 Add proper title and subtitle handling with overflow protection
  - [x] 3.6 Verify all tests pass and timer displays at correct sizes across devices

- [ ] 4. Build Secondary Control Bar
  - [ ] 4.1 Write tests for SecondaryControlBar with all control buttons and touch targets
  - [ ] 4.2 Implement SecondaryControlBar widget with consistent button layout
  - [ ] 4.3 Create proper button spacing and minimum 44px touch targets
  - [ ] 4.4 Add gesture handling for PREV (tap) and reset (long press) functionality
  - [ ] 4.5 Integrate pause/resume button state updates from WorkoutState
  - [ ] 4.6 Verify all tests pass and all controls are accessible and functional

- [ ] 5. Update Drill Widgets for New Layout
  - [ ] 5.1 Write tests for TimedDrillWidget integration with SplitPriorityLayout
  - [ ] 5.2 Refactor TimedDrillWidget to use LargeTimerDisplay and new layout system
  - [ ] 5.3 Update MakeTargetTimedDrillWidget to integrate with PrimaryActionBar for FINISH button
  - [ ] 5.4 Modify RepBasedDrillWidget to use LOG SET button in primary action bar
  - [ ] 5.5 Update ReadAndReactDrillWidget to work with new layout constraints  
  - [ ] 5.6 Verify all tests pass and drill functionality remains intact with new layout

- [ ] 6. Integrate Layout System in Active Workout Screen
  - [ ] 6.1 Write tests for ActiveWorkoutScreen with new SplitPriorityLayout integration
  - [ ] 6.2 Replace ActiveDrillLayout usage with SplitPriorityLayout in ActiveWorkoutScreen
  - [ ] 6.3 Wire up primary action callbacks to appropriate drill completion methods
  - [ ] 6.4 Connect secondary control callbacks to WorkoutState methods
  - [ ] 6.5 Add progress indicator integration with workout progress tracking
  - [ ] 6.6 Verify all tests pass and complete workout flow works with new layout

- [ ] 7. Mobile Browser Optimizations
  - [ ] 7.1 Write tests for mobile browser viewport handling and responsive adjustments  
  - [ ] 7.2 Implement special handling for reduced viewport height in mobile browsers
  - [ ] 7.3 Add MediaQuery-based adjustments for browser chrome detection
  - [ ] 7.4 Create fallback layouts for very small screen constraints (< 400px height)
  - [ ] 7.5 Test cross-platform behavior on actual mobile devices and browsers
  - [ ] 7.6 Verify all tests pass and layout works correctly in mobile web environments

- [ ] 8. Remove Legacy Layout Components
  - [ ] 8.1 Write migration tests to ensure no functionality is lost when removing old components
  - [ ] 8.2 Remove ActiveDrillLayout widget and all references to it
  - [ ] 8.3 Clean up any unused import statements and dependencies
  - [ ] 8.4 Update any remaining test files that reference the old layout system
  - [ ] 8.5 Run full test suite to ensure no breaking changes introduced
  - [ ] 8.6 Verify all tests pass and no legacy layout code remains in codebase 