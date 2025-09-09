# Implementation Tasks - Voice Commands

> Created: 2025-09-09
> Version: 1.0.0
> Parent Spec: @.agent-os/specs/2025-09-09-voice-commands/spec.md

## Task Breakdown

This document provides a detailed breakdown of implementation tasks for the voice commands feature, organized by phases with clear dependencies, effort estimates, and acceptance criteria.

## Phase 1: Foundation (Weeks 1-2)
**Goal:** Establish basic voice command infrastructure and settings integration

### Task 1.1: Project Setup and Dependencies
**Effort:** XS (1 day)
**Priority:** Must-Have
**Dependencies:** None

**Description:**
Add required dependencies and initial project configuration for voice commands.

**Acceptance Criteria:**
- [ ] Add `speech_to_text: ^6.6.0` to pubspec.yaml
- [ ] Add required Android permissions to AndroidManifest.xml
- [ ] Update gradle files if needed for speech recognition
- [ ] Verify dependencies work on test device

**Implementation Steps:**
1. Update `pubspec.yaml` with speech_to_text dependency
2. Add microphone permissions to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.BLUETOOTH" />
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
   ```
3. Run `flutter pub get`
4. Test basic speech_to_text initialization on device

### Task 1.2: Settings Service Extension
**Effort:** S (2 days)
**Priority:** Must-Have
**Dependencies:** Task 1.1

**Description:**
Extend the existing SettingsService to include voice command preferences with proper persistence.

**Acceptance Criteria:**
- [ ] Add voice commands enabled/disabled setting
- [ ] Add audio command feedback enabled/disabled setting (default: true)
- [ ] Add confidence threshold setting (default: 0.7)
- [ ] Implement persistence in JSON settings file
- [ ] Add getters and setters following existing patterns
- [ ] Notify listeners on changes

**Implementation Steps:**
1. Add new fields to `SettingsService`:
   ```dart
   bool _voiceCommandsEnabled = false;
   bool _audioCommandFeedback = true;
   double _voiceConfidenceThreshold = 0.7;
   String _preferredAudioDeviceId = '';
   ```
2. Add getters and setters with persistence
3. Update `_loadSettings()` and `_saveSettings()` methods
4. Add unit tests for new functionality

### Task 1.3: Settings UI Implementation
**Effort:** S (2 days)
**Priority:** Must-Have
**Dependencies:** Task 1.2

**Description:**
Add voice commands section to the Settings screen with intuitive controls.

**Acceptance Criteria:**
- [ ] Add "Voice Commands" section to Settings screen
- [ ] Include toggle switch for enabling/disabling voice commands
- [ ] Include toggle switch for audio command feedback
- [ ] Add confidence threshold slider (0.5 - 0.9 range)
- [ ] Show microphone permission status
- [ ] Display helpful instructions and tips
- [ ] Follow existing UI patterns and styling

**Implementation Steps:**
1. Update `SettingsScreen` widget with new voice commands section
2. Add toggle switches for voice commands and audio feedback
3. Create confidence threshold slider widget
4. Add permission status indicator
5. Include user guidance text and wake word information ("Hey Coach")
6. Test UI responsiveness and state updates

### Task 1.4: VoiceCommandService Foundation
**Effort:** M (1 week)
**Priority:** Must-Have
**Dependencies:** Task 1.1, 1.2

**Description:**
Create the core VoiceCommandService with basic initialization and permission handling.

**Acceptance Criteria:**
- [ ] Create VoiceCommandService as ChangeNotifier
- [ ] Implement initialization with speech_to_text
- [ ] Handle microphone permission requests
- [ ] Add basic error handling and states
- [ ] Integrate with SettingsService
- [ ] Add service to main app providers

**Implementation Steps:**
1. Create `lib/services/voice_command_service.dart`
2. Implement basic service structure with speech_to_text integration
3. Add permission handling methods
4. Create error states and user-friendly error messages
5. Create CommandProcessor with SettingsService dependency injection
6. Add to provider setup in `main.dart`
7. Write comprehensive unit tests

### Task 1.5: Basic Command Recognition (with Debug Button)
**Effort:** S (3 days)
**Priority:** Must-Have
**Dependencies:** Task 1.4

**Description:**
Implement basic voice command recognition for simple workout controls using a temporary debug button for testing before wake word implementation.

**Acceptance Criteria:**
- [ ] Add temporary "Listen for Command" debug button in active workout screen
- [ ] Implement single-command listening with 5-second timeout
- [ ] Recognize "pause" and "resume" commands
- [ ] Recognize "next" and "previous" commands
- [ ] Implement basic confidence scoring using SettingsService threshold
- [ ] Provide audio feedback for successful commands (if enabled in settings)
- [ ] Handle unrecognized commands gracefully with user feedback
- [ ] Integrate with WorkoutState service
- [ ] Add clear visual indicator when listening is active

**Implementation Steps:**
1. Create `CommandProcessor` class with SettingsService dependency injection
2. Implement single-command listening method with timeout
3. Add temporary debug button to ActiveWorkoutScreen
4. Implement pause/resume command recognition
5. Add next/previous drill command support
6. Connect to WorkoutState methods
7. Add audio feedback using existing AudioService
8. Add visual listening indicator (e.g., pulsing microphone icon)
9. Test command recognition accuracy
10. Document debug button for removal in Phase 2

## Phase 2: Core Commands (Weeks 3-4)
**Goal:** Implement wake word detection and comprehensive meta commands

### Task 2.1: Wake Word Detection
**Effort:** M (1 week)
**Priority:** Must-Have
**Dependencies:** Phase 1 complete

**Description:**
Implement continuous listening for wake word with timeout handling.

**Acceptance Criteria:**
- [ ] Continuous listening for "hey coach" wake word
- [ ] Switch to command listening mode after wake word detection
- [ ] 3-second timeout for command input
- [ ] Visual indicators for listening states
- [ ] Handle wake word false positives
- [ ] Battery-optimized listening strategy
- [ ] Remove temporary debug button from Phase 1
- [ ] Replace debug button functionality with wake word activation

**Implementation Steps:**
1. Implement continuous speech recognition
2. Add wake word detection logic
3. Create listening mode state machine
4. Add timeout handling for command mode
5. Create visual indicators for listening states
6. Remove debug button from ActiveWorkoutScreen
7. Update UI to show wake word listening status
8. Optimize for battery usage

### Task 2.2: Enhanced Command Processing
**Effort:** S (3 days)
**Priority:** Must-Have
**Dependencies:** Task 2.1

**Description:**
Enhance command processing with fuzzy matching and variations.

**Acceptance Criteria:**
- [ ] Support command variations (e.g., "stop" for pause)
- [ ] Implement fuzzy matching for similar-sounding words
- [ ] Add confidence-based command filtering
- [ ] Handle accents and pronunciation variations
- [ ] Log command history for debugging
- [ ] Support "made X shots" commands for REP_BASED drills

**Implementation Steps:**
1. Expand CommandProcessor with fuzzy matching algorithms
2. Add comprehensive command vocabulary
3. Implement dynamic confidence thresholds from SettingsService
4. Add command history logging
5. Add REP_BASED drill reporting logic
6. Test with various pronunciations and accents

### Task 2.3: Complete Meta Commands
**Effort:** S (2 days)
**Priority:** Must-Have
**Dependencies:** Task 2.1

**Description:**
Implement all workout control commands with proper integration.

**Acceptance Criteria:**
- [ ] "Reset" command for current drill
- [ ] "Next drill" and "previous drill" commands
- [ ] "Pause workout" and "resume workout" commands
- [ ] "Made X shots" command for REP_BASED drills
- [ ] Proper integration with WorkoutState
- [ ] Command confirmation feedback
- [ ] Error handling for invalid states

**Implementation Steps:**
1. Add reset drill command handling
2. Implement drill navigation commands
3. Add workout pause/resume with state validation
4. Add REP_BASED drill result logging
5. Create command confirmation system
6. Add error handling for invalid workout states
7. Test all commands in various workout scenarios

### Task 2.4: Audio Feedback System
**Effort:** S (2 days)
**Priority:** Should-Have
**Dependencies:** Task 2.3

**Description:**
Create comprehensive audio feedback for voice command interactions.

**Acceptance Criteria:**
- [ ] Audio confirmation for successful commands (if enabled in settings)
- [ ] Speaking current drill status after commands
- [ ] Error sound for unrecognized commands
- [ ] Mode change audio cues (entering/exiting command mode)
- [ ] Integration with existing AudioService
- [ ] Configurable feedback preferences

**Implementation Steps:**
1. Extend AudioService with command feedback methods
2. Create audio cues for different command results
3. Add contextual status announcements
4. Implement feedback preferences in settings
5. Test audio feedback quality and timing

## Phase 3: Bluetooth Integration (Weeks 5-6)
**Goal:** Enable Bluetooth microphone support and music integration

### Task 3.1: Android Platform Channel
**Effort:** L (2 weeks)
**Priority:** Should-Have
**Dependencies:** Phase 2 complete

**Description:**
Create Android platform channel for audio device management and Bluetooth microphone routing.

**Acceptance Criteria:**
- [ ] Platform channel for audio device enumeration
- [ ] Bluetooth device detection and connection status
- [ ] Audio input routing to Bluetooth microphone
- [ ] Fallback to device microphone when Bluetooth unavailable
- [ ] Handle Bluetooth disconnection events
- [ ] Integration with speech recognition
- [ ] Audio focus management for music integration

**Implementation Steps:**
1. Create Android platform channel in MainActivity.kt
2. Implement audio device enumeration methods
3. Add Bluetooth device detection and management
4. Create audio routing methods
5. Handle device disconnection and reconnection
6. Implement audio focus management for music ducking
7. Integrate with VoiceCommandService
8. Test with multiple Bluetooth device types

### Task 3.2: AudioRouterService
**Effort:** M (1 week)
**Priority:** Should-Have
**Dependencies:** Task 3.1

**Description:**
Create Flutter service to manage audio device routing through platform channels.

**Acceptance Criteria:**
- [ ] AudioRouterService for device management
- [ ] Automatic Bluetooth microphone detection
- [ ] Device preference persistence
- [ ] Real-time device status updates
- [ ] Integration with VoiceCommandService
- [ ] Error handling for device failures
- [ ] Audio ducking support for music apps

**Implementation Steps:**
1. Create AudioRouterService class
2. Implement platform channel communication
3. Add device preference management
4. Create device status monitoring
5. Integrate with voice command service
6. Add audio ducking implementation
7. Add comprehensive error handling

### Task 3.3: Bluetooth UI Controls
**Effort:** S (3 days)
**Priority:** Should-Have
**Dependencies:** Task 3.2

**Description:**
Add user interface controls for Bluetooth device management in settings.

**Acceptance Criteria:**
- [ ] Audio device selection in Settings
- [ ] Current device status display
- [ ] Automatic switching preferences
- [ ] Device connection troubleshooting help
- [ ] Real-time device status updates
- [ ] User-friendly device management

**Implementation Steps:**
1. Add audio device section to Settings screen
2. Create device selection dropdown/list
3. Add device status indicators
4. Implement automatic switching toggle
5. Add troubleshooting guidance
6. Test UI with various device states

### Task 3.4: Device Switching Logic
**Effort:** M (5 days)
**Priority:** Should-Have
**Dependencies:** Task 3.2, 3.3

**Description:**
Implement intelligent device switching and fallback logic.

**Acceptance Criteria:**
- [ ] Automatic switching to preferred Bluetooth device
- [ ] Graceful fallback when Bluetooth disconnects
- [ ] Maintain voice recognition during device switches
- [ ] User notification for device changes
- [ ] Preference learning from user behavior
- [ ] Robust error recovery

**Implementation Steps:**
1. Implement automatic device preference logic
2. Add graceful fallback mechanisms
3. Handle device switching during active recognition
4. Create user notification system
5. Add preference learning algorithms
6. Test switching scenarios and edge cases

## Phase 4: Shot Registration (Weeks 7-8)
**Goal:** Implement always-listening mode for hands-free shot registration

### Task 4.1: Always-Listening Mode
**Effort:** M (1 week)
**Priority:** Must-Have
**Dependencies:** Phase 3 complete

**Description:**
Implement continuous listening for make/miss registration during shooting drills.

**Acceptance Criteria:**
- [ ] Define constant for drill types that enable always-listening mode
- [ ] Automatic always-listening mode for MAKE_TARGET_TIMED and other configured drill types
- [ ] Recognition of make words: "make", "bucket", "in", "yes", "yep", "yup", "good"
- [ ] Recognition of miss words: "miss", "brick", "off", "no", "nope", "out"
- [ ] Mode coordination with wake word detection
- [ ] Confidence-based shot registration
- [ ] No interference with existing drill functionality

**Implementation Steps:**
1. Define `alwaysListeningDrillTypes` constant in VoiceCommandService
2. Add drill type detection logic using the constant
3. Implement make/miss word recognition
4. Create mode coordination between wake word and always-listening
5. Add confidence scoring for shot results
6. Integrate with existing drill result logging
7. Test mode switching and coordination

### Task 4.2: Shot Result Integration
**Effort:** S (3 days)
**Priority:** Must-Have
**Dependencies:** Task 4.1

**Description:**
Integrate voice-recognized shot results with existing drill widgets and result tracking.

**Acceptance Criteria:**
- [ ] Update drill widgets to accept voice input
- [ ] Integrate with existing make/miss tracking systems
- [ ] Provide immediate visual feedback for shot registration
- [ ] Audio confirmation for shot results (with music ducking)
- [ ] Handle rapid consecutive shot calls
- [ ] Maintain accuracy of drill statistics

**Implementation Steps:**
1. Update drill widgets to handle voice command input
2. Integrate with existing shot tracking methods
3. Add visual feedback for voice-registered shots
4. Create audio confirmation for shot results
5. Handle rapid consecutive commands
6. Test integration with all shooting drill types

### Task 4.3: Mode Handoff Logic
**Effort:** M (5 days)
**Priority:** Must-Have
**Dependencies:** Task 4.1, 4.2

**Description:**
Implement seamless handoff between wake word detection and always-listening modes.

**Acceptance Criteria:**
- [ ] Pause always-listening when wake word is detected
- [ ] Resume always-listening after command processing
- [ ] Handle wake word during shot registration
- [ ] Prevent mode conflicts and interference
- [ ] Maintain consistent user experience
- [ ] Debug logging for mode transitions

**Implementation Steps:**
1. Create mode state machine with proper transitions
2. Implement wake word interruption of always-listening
3. Add resume logic after command completion
4. Handle edge cases and conflicts
5. Add comprehensive logging for debugging
6. Test mode transitions in various scenarios

### Task 4.4: Shot Registration Accuracy
**Effort:** S (3 days)
**Priority:** Should-Have
**Dependencies:** Task 4.2

**Description:**
Optimize shot registration accuracy with advanced recognition techniques.

**Acceptance Criteria:**
- [ ] >90% accuracy in quiet environments
- [ ] >80% accuracy in moderate noise
- [ ] Handle variations in pronunciation
- [ ] Filter out false positives from conversation
- [ ] Confidence-based filtering
- [ ] User feedback for unclear commands

**Implementation Steps:**
1. Implement advanced noise filtering
2. Add context-aware recognition (shooting drill context)
3. Create false positive filtering
4. Add pronunciation variation handling
5. Implement user feedback for unclear commands
6. Conduct accuracy testing in various environments

## Phase 5: Polish and Testing (Week 9)
**Goal:** Final testing, performance optimization, and user experience polish

### Task 5.1: Performance Optimization
**Effort:** S (3 days)
**Priority:** Must-Have
**Dependencies:** All previous phases

**Description:**
Optimize voice command performance for battery life and responsiveness.

**Acceptance Criteria:**
- [ ] Command response time < 500ms
- [ ] Battery impact < 10% during 60-minute workout
- [ ] Memory usage increase < 50MB
- [ ] Optimized listening strategies
- [ ] Performance monitoring and metrics
- [ ] Battery usage reporting

**Implementation Steps:**
1. Profile current performance metrics
2. Optimize speech recognition lifecycle
3. Implement smart listening strategies
4. Add performance monitoring
5. Create battery usage reporting
6. Test performance on various devices

### Task 5.2: Error Recovery and User Guidance
**Effort:** S (2 days)
**Priority:** Must-Have
**Dependencies:** All previous phases

**Description:**
Implement comprehensive error recovery and user guidance systems.

**Acceptance Criteria:**
- [ ] Graceful recovery from all error states
- [ ] Clear user guidance for common issues
- [ ] Automatic retry mechanisms
- [ ] Fallback to manual controls
- [ ] User-friendly error messages
- [ ] Help documentation integration

**Implementation Steps:**
1. Implement error recovery mechanisms
2. Create user guidance system
3. Add automatic retry logic
4. Ensure manual control fallbacks
5. Create user-friendly error messages
6. Add help documentation

### Task 5.3: Integration Testing
**Effort:** S (3 days)
**Priority:** Must-Have
**Dependencies:** All previous phases

**Description:**
Comprehensive integration testing across all voice command functionality.

**Acceptance Criteria:**
- [ ] End-to-end testing of all user flows
- [ ] Integration testing with existing app features
- [ ] Device testing with multiple hardware configurations
- [ ] Bluetooth testing with various headphone models
- [ ] Noise environment testing
- [ ] Performance testing under load

**Implementation Steps:**
1. Create comprehensive test scenarios
2. Execute end-to-end testing
3. Test integration with existing features
4. Conduct device and hardware testing
5. Test in various acoustic environments
6. Perform load and stress testing

### Task 5.4: Documentation and User Onboarding
**Effort:** S (2 days)
**Priority:** Should-Have
**Dependencies:** All previous phases

**Description:**
Create user documentation and onboarding experience for voice commands.

**Acceptance Criteria:**
- [ ] In-app tutorial for voice commands
- [ ] Help section with troubleshooting guide
- [ ] Voice command reference card
- [ ] Setup wizard for first-time users
- [ ] Tips and best practices
- [ ] Video tutorials or animations

**Implementation Steps:**
1. Create in-app tutorial flow
2. Add help section to settings
3. Create voice command reference
4. Implement setup wizard
5. Add tips and best practices
6. Create visual guides or animations

## Dependencies and Critical Path

### Critical Path:
1. Phase 1 (Foundation) → Phase 2 (Core Commands) → Phase 3 (Bluetooth Integration) → Phase 4 (Shot Registration) → Phase 5 (Polish)

### Key Dependencies:
- **Settings Integration** must be complete before any user-facing features
- **VoiceCommandService Foundation** blocks all voice recognition features
- **Wake Word Detection** must work before implementing always-listening mode
- **Core Commands** should be functional before adding Bluetooth complexity
- **Shot Registration** requires working mode coordination
- **Bluetooth Integration** enhances the experience but core functionality works without it

## Risk Mitigation

### High-Risk Tasks:
- **Task 3.1 (Android Platform Channel)**: Complex native development
- **Task 4.3 (Mode Handoff Logic)**: Complex state management
- **Task 2.1 (Wake Word Detection)**: Performance and accuracy critical

### Mitigation Strategies:
1. **Platform Channel Risk**: Start in Phase 3, create minimal prototype first
2. **Mode Handoff Risk**: Extensive state machine testing, clear documentation
3. **Wake Word Risk**: Use proven libraries, implement fallback mechanisms
4. **Music Integration Risk**: Test with multiple music apps, implement standard audio focus patterns

## Success Metrics

### Development Success:
- [ ] All Must-Have tasks completed
- [ ] >80% Should-Have tasks completed
- [ ] All unit tests passing (>95% coverage)
- [ ] Integration tests passing
- [ ] Performance benchmarks met

### User Success:
- [ ] >90% voice command accuracy in testing
- [ ] <500ms average response time
- [ ] Positive user feedback in testing
- [ ] Successful hands-free workout completion
- [ ] Bluetooth integration working with major headphone brands

This task breakdown provides a clear roadmap for implementing voice commands with realistic effort estimates, clear dependencies, and measurable success criteria.
