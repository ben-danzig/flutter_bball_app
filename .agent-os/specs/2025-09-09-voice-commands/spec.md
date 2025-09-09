# Voice Commands Feature Specification

> Created: 2025-09-09
> Version: 1.0.0
> Status: Planning

## Overview

This specification details the implementation of voice commands for the Basketball Training App, enabling hands-free interaction during workouts. Users will be able to control the app using voice commands while wearing Bluetooth headphones, allowing them to focus on training without interrupting their workout flow.

## Problem Statement

**Current State:**
- Users must manually interact with the phone screen to register makes/misses, advance drills, and control workout flow
- This interrupts training flow and requires users to physically approach their device
- Users often lose focus on their training when constantly interacting with the app

**User Pain Points:**
- Breaking training rhythm to register shot results
- Difficulty operating phone with sweaty hands during intense workouts
- Phone placement constraints - must be within reach for manual interaction
- Bluetooth microphone issues with existing third-party solutions (Picovoice)

**Target Solution:**
- Hands-free voice interaction using wake words and direct commands
- Seamless integration with Bluetooth headphones
- Minimal latency between command and app response
- Intelligent dual-mode listening (wake word + always-on for makes/misses)

## User Stories

### Core User Stories

**US1: Settings Configuration**
> As a basketball player, I want to enable/disable voice commands in settings so that I can choose when to use hands-free interaction.

**US2: Microphone Permissions**
> As a user, I want to be prompted for microphone permissions when enabling voice commands so that the app can listen for my voice input.

**US3: Wake Word Commands**
> As a player during a workout, I want to say something like "Hey Coach" followed by commands like "pause", "resume", or "next drill" so that I can control workout flow hands-free.

**US4: Make/Miss Registration**
> As a player during shooting drills, I want to say words like "make", "bucket", "miss", or "brick" to register shot results without using the wake word.

**US5: Bluetooth Microphone Support**
> As a user with Bluetooth headphones, I want voice commands to work through my headphone microphone so that I can place my phone away from me during workouts.

**US6: Smooth Transitions With Music Playing**
> As a player, I want to be able to use the voice commands while listening to music in my headphones. The music playing shouldn't interrupt my ability to issue commands, and if audio confirmation is provided back, the music level is temporarily quieted to allow hearing the audio confirmations from the app.

### Advanced User Stories

**US7: Audio Feedback**
> As a player, I want audio confirmation when commands are processed (e.g., "3 makes remaining") so that I know the app understood my input.

**US8: Intelligent Mode Switching**
> As a user, I want the app to automatically switch between wake word mode and always-listening mode based on the current drill type so that the experience is seamless.

**US9: Command Customization**
> As a user, I want to configure which words trigger make/miss registration so that I can use my preferred vocabulary.

## Functional Requirements

### FR1: Voice Command Settings
- Add "Voice Commands" toggle in Settings screen

- Persist settings in local storage.
- Request microphone permissions when feature is enabled
- Disable all voice functionality when setting is off
- Other related settings include "Audio Command Feedback" which will determine whether or not a command will have an audio feedback associated with it after command execution.

### FR2: Wake Word Detection
- Implement wake word detection using open source library
- Support configurable wake word (default: "Hey Coach" or "Register")
- Activate command listening mode after wake word detection
- Timeout command listening after 3 seconds of silence

### FR3: Command Processing
- Support meta commands: "pause", "resume", "next", "previous", "reset", "made X shots" (for REP_BASED drills)
- Process commands with minimal latency (< 500ms)
- Provide audio feedback for successful command execution (if the "Audio Command Feedback" setting is turned on)
- Handle unrecognized commands gracefully

### FR4: Always-On Shot Registration
- Enable always-listening mode during MAKE_TARGET_TIMED drills
- Recognize make words: "make", "bucket", "in", "yes", "yep", "yup", "good"
- Recognize miss words: "miss", "brick", "off", "no", "nope", "out"
- Support natural variations and similar-sounding words

### FR5: Bluetooth Microphone Integration
- Use platform channels to access Android microphone settings
- Automatically switch to Bluetooth microphone when available
- Fallback to device microphone when Bluetooth unavailable
- Handle microphone switching during active workout

### FR6: Dual-Mode Coordination
- Seamlessly hand off between wake word and always-listening modes
- Pause always-listening when wake word is detected
- Resume always-listening after command processing (if applicable)
- Clear mode indicators for debugging and user feedback

## Non-Functional Requirements

### Performance
- Voice command response time: < 500ms from speech end to action
- Wake word detection latency: < 200ms
- Memory usage increase: < 50MB during active voice recognition
- Battery impact: < 10% additional drain during 60-minute workout

### Reliability
- Voice recognition accuracy: > 90% in quiet environments
- Voice recognition accuracy: > 80% in moderate noise (dribbling, crowd)
- Graceful degradation when network connectivity is poor
- No app crashes due to voice recognition failures

### Usability
- Clear audio feedback for all successful commands (if the "Audio Command Feedback" setting is turned on)
- Visual indicators when voice recognition is active
- Easy discovery of available voice commands
- Intuitive wake word that's easy to remember and pronounce

### Compatibility
- Android API 21+ support for speech recognition
- Cross-platform Flutter implementation
- Support for major Bluetooth headphone brands
- Fallback functionality when voice features unavailable

## User Experience Flow

### Initial Setup Flow
1. User navigates to Settings screen
2. User toggles "Voice Commands" and "Audio Command Feedback" settings to ON
3. App requests microphone permissions
4. User grants permissions
5. App performs voice recognition test
6. Settings saved, feature ready for use

### Workout Voice Commands Flow
1. User starts workout with voice commands enabled
2. App begins wake word listening in background
3. User says wake word immediately followed with the command: "Hey Coach, pause"
4. App begins command listening after "Hey Coach" is said, executes command ("pause"), and provides audio confirmation 
5. App returns to wake word listening mode

### Shot Registration Flow (MAKE_TARGET_TIMED drills)
1. User starts shooting drill
2. App enables always-listening mode for make/miss words
3. User takes shot and says "make" or "miss" (or some variation of those words). There is no need for the user to precede this with the wake word.
4. App registers result and provides audio feedback
5. App continues listening for next shot
6. If wake word is said, temporarily pause shot listening

### Shot Registration Flow (REP_BASED drills)
1. User starts shooting drill
2. App begins wake word listening in background
3. User does the drill, and reports the results after finishing. For example, if the drill is to take 10 free throws, the user will take 10 shots and keep track of how many out of 10 they made. Once they've finished the drill, they can report the results via voice commands.
4. User says wake word immediately followed with the command: "Hey Coach, I made 7 shots"
5. App begins command listening after "Hey Coach" is said, executes command ("I made") with the parameter ("7 shots"), and provides audio confirmation 
6. App returns to wake word listening mode

## Technical Constraints

### Platform Limitations
- Android platform channels required for microphone management
- Flutter speech recognition plugins may have platform-specific behavior
- Bluetooth audio routing requires native Android implementation

### Performance Constraints
- Continuous microphone listening impacts battery life
- Real-time speech processing requires sufficient device resources
- Large speech recognition models may impact app size

### Integration Constraints
- Must work with existing WorkoutState and drill management
- Should not interfere with existing audio services (TTS, sound effects)
- Settings integration must follow existing patterns

## Success Criteria

### Functional Success
- [ ] Users can enable/disable voice commands in settings
- [ ] Voice commands work with Bluetooth headphones
- [ ] Make/miss registration works hands-free during shooting drills
- [ ] Meta commands (pause, resume, next) work consistently
- [ ] User shouldn't have to pause between saying the wake word and the command word. They can say it all in one fluid phrase.
- [ ] No interference with existing audio features

### Performance Success
- [ ] < 500ms response time for voice commands
- [ ] > 85% accuracy in typical basketball gym environment
- [ ] < 10% battery impact during typical workout
- [ ] No audio dropouts or recognition failures

### User Experience Success
- [ ] Users prefer voice commands over manual interaction
- [ ] Voice commands feel natural and intuitive
- [ ] Feature discovery is clear and accessible
- [ ] Error states are handled gracefully

## Out of Scope

### Not Included in V1
- Custom wake word training
- Multiple language support
- Voice command customization beyond make/miss words
- Integration with external speech services (cloud-based)
- Voice analytics and training optimization

### Future Considerations
- Advanced natural language processing for complex commands
- Personalized voice recognition training
- Integration with workout analytics for voice-based insights
- Support for multiple user voices in team settings

## Dependencies

### External Dependencies
- Open source speech recognition library (TBD - research required)
- Android platform channel implementation for microphone management
- Bluetooth audio routing native implementation

### Internal Dependencies
- Existing WorkoutState service for drill management
- SettingsService for preference persistence
- AudioService integration for feedback sounds
- Current drill widget architecture for result registration

## Risk Assessment

### High Risk
- **Bluetooth microphone integration complexity**: Platform-specific implementation required
- **Speech recognition accuracy in noisy environments**: Basketball gyms can be very noisy
- **Battery life impact**: Continuous microphone listening

### Medium Risk
- **Library selection**: Finding suitable open source speech recognition library
- **User adoption**: Users may prefer familiar manual interaction
- **Performance on older devices**: Speech processing requirements

### Low Risk
- **Settings integration**: Following existing patterns
- **Basic command processing**: Straightforward implementation
- **Audio feedback integration**: Building on existing audio services

## Acceptance Criteria

### Minimum Viable Product (MVP)
1. Voice commands setting can be toggled on/off
2. Microphone permissions requested and handled properly
3. Basic wake word detection works with default wake word
4. Core commands work: pause, resume, next drill, I made X shots
5. Make/miss registration works during shooting drills
6. Feature works with device microphone (Bluetooth support in next iteration)

### Full Feature Implementation
1. All MVP criteria met
2. Bluetooth microphone switching implemented
3. Intelligent mode switching between wake word and always-listening
4. Audio feedback for all commands
5. Graceful error handling and user guidance
6. Performance benchmarks met
7. User testing validates positive experience

This specification provides the foundation for implementing voice commands as a hands-free enhancement to the basketball training app, focusing on user workflow optimization and technical feasibility.
