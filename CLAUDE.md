# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run all tests
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
- Drill widgets handle different exercise types (timed, rep-based, make-target-timed)
- Provider context used throughout for state access
- JSON assets for workout data with asset bundling

### Testing
- Comprehensive test coverage in `test/` directory
- Uses Mockito for mocking services
- Widget tests for all screens and components
- Model and repository unit tests

## JSON Code Generation

When modifying model classes with `@JsonSerializable`, run:
```bash
dart run build_runner build
```

Models requiring regeneration are in `lib/models/` and have corresponding `.g.dart` files.