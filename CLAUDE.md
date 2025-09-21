# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run all tests
- `flutter test test/specific_test.dart` - Run a single test file
- `flutter test --name "test name"` - Run specific test by name pattern
- `flutter analyze` - Run static analysis/linting
- `dart run build_runner build` - Generate JSON serialization code (*.g.dart files)
- `dart run build_runner build --delete-conflicting-outputs` - Force regenerate JSON serialization

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

## Architecture Overview

This is a Flutter basketball training app with the following architecture:

### State Management
- Uses **Provider** pattern with `WorkoutState` as the main state manager
- `WorkoutState` (lib/services/workout_state.dart) manages active workout sessions, drill progression, and results

### Data Models
All models use JSON serialization with code generation:
- `WorkoutBlueprint` - Defines workout templates with drills
- `Drill` - Individual exercises with different types (TIMED, REP_BASED, MAKE_TARGET_TIMED)
- `DrillResult` - Records performance data from completed drills
- `WorkoutSession` - Completed workout with results and timestamps

### Data Layer
- `WorkoutRepository` - Loads workout blueprints from JSON assets
- `WorkoutSessionService` - Handles persistent storage of workout session history using Firestore
- `VoiceCommandService` - Manages speech-to-text functionality for voice control during workouts
- `AudioService` - Handles text-to-speech announcements and workout audio cues
- `SoundEffectsService` - Manages sound effects and audio feedback
- `SettingsService` - User preferences and app configuration
- Workout session data is stored in the Firestore `workout_sessions` collection
- `StorageService` (legacy) - Previously handled local file storage for workout history; now deprecated
- Workout blueprints/templates are stored in `assets/workouts.json` and `assets/test_workouts.json`

### Screen Structure
- **Library**: Browse available workouts
- **Detail**: View workout details before starting
- **Active**: Execute workouts with drill-specific widgets
- **Summary**: Review completed workout results
- **History**: View past workout sessions

### Key Components
- Drill widgets handle different exercise types (timed, rep-based, make-target-timed, read-and-react)
- Provider context used throughout for state access with MultiProvider setup in main.dart
- Firebase integration for authentication (AuthService) and data persistence
- Voice command integration with speech-to-text for hands-free workout control
- JSON assets for workout data with asset bundling

### Testing
- Comprehensive test coverage in `test/` directory
- Uses Mockito for mocking services  
- Widget tests for all screens and components
- Model and repository unit tests
- Integration tests for complex workflows (e.g., `test/integration/phase1_voice_commands_test.dart`)
- Service-specific tests including voice command functionality

## JSON Code Generation

When modifying model classes with `@JsonSerializable`, run:
```bash
dart run build_runner build
```

Models requiring regeneration are in `lib/models/` and have corresponding `.g.dart` files. Key models include:
- `WorkoutBlueprint` - Workout templates and drill definitions
- `Drill` - Exercise configurations with type-specific parameters  
- `DrillResult` - Performance tracking data
- `WorkoutSession` - Complete workout records with timestamps
- `UserProfile` - User account and preference data

## Agent OS Documentation

### Product Context
- **Mission & Vision:** @.agent-os/product/mission.md
- **Technical Architecture:** @.agent-os/product/tech-stack.md
- **Development Roadmap:** @.agent-os/product/roadmap.md
- **Decision History:** @.agent-os/product/decisions.md

### Development Standards
- **Code Style:** @~/.agent-os/standards/code-style.md
- **Best Practices:** @~/.agent-os/standards/best-practices.md

### Project Management
- **Active Specs:** @.agent-os/specs/
- **Spec Planning:** Use `@~/.agent-os/instructions/create-spec.md`
- **Tasks Execution:** Use `@~/.agent-os/instructions/execute-tasks.md`

## Workflow Instructions

When asked to work on this codebase:

1. **First**, check @.agent-os/product/roadmap.md for current priorities
2. **Then**, follow the appropriate instruction file:
   - For new features: @.agent-os/instructions/create-spec.md
   - For tasks execution: @.agent-os/instructions/execute-tasks.md
3. **Always**, adhere to the standards in the files listed above

## Important Notes

- Product-specific files in `.agent-os/product/` override any global standards
- User's specific instructions override (or amend) instructions found in `.agent-os/specs/...`
- Always adhere to established patterns, code style, and best practices documented above.