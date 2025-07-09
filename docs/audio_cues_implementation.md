# Audio Cues Implementation

## Overview
This document describes the implementation of text-to-speech audio cues for the Basketball Training App.

## Features Implemented

### 1. Text-to-Speech Service
- **AudioService** (`lib/services/audio_service.dart`): Singleton service that handles all text-to-speech functionality
- Uses the `flutter_tts` package for cross-platform TTS support
- Provides methods for speaking text, pausing, and stopping audio

### 2. Settings Service
- **SettingsService** (`lib/services/settings_service.dart`): Manages user preferences for audio cues
- Persists settings to local storage using JSON files
- Implements ChangeNotifier pattern for reactive UI updates

### 3. Settings Available
All settings are **enabled by default**:
- **Announce Drill Name**: Speaks the name of the drill when it starts
- **Announce Drill Description**: Speaks the drill description when starting a new drill
- **Announce Target Makes**: Speaks the target number of makes for applicable drill types

### 4. Settings Screen
- **SettingsScreen** (`lib/screens/settings/settings_screen.dart`): User interface for managing audio preferences
- Features toggle switches for each audio setting
- Accessible via bottom navigation bar

### 5. Navigation Update
- Added bottom navigation bar to switch between Workouts and Settings screens
- **HomeScreen** (`lib/screens/home_screen.dart`): Main container with navigation

### 6. Audio Integration Points
Audio cues are triggered at the following moments:
- When starting a workout (announces first drill)
- When advancing to the next drill
- When going back to a previous drill
- When resetting the current drill

### 7. Drill-Specific Announcements
- **REP_BASED drills**: Announces the number of repetitions to complete
- **MAKE_TARGET_TIMED drills**: Announces the target number of shots to make
- **TIMED drills**: Only announces name and description (no specific targets)

## Usage

1. Navigate to Settings using the bottom navigation bar
2. Toggle audio cue preferences on/off as desired
3. Start a workout - audio cues will play based on your settings
4. Audio announcements include:
   - "Next drill: [Drill Name]"
   - Drill description (if enabled)
   - Target requirements (if applicable and enabled)

## Technical Details

### Dependencies Added
```yaml
flutter_tts: ^3.8.7
```

### State Management
- Uses Provider pattern for state management
- SettingsService is provided at the app level
- WorkoutState connects to SettingsService when starting workouts

### Persistence
- Settings are saved to local storage automatically
- Settings persist between app sessions
- Default values are used on first launch

## Testing
- Unit tests added for SettingsService (`test/services/settings_service_test.dart`)
- Tests cover default values, updates, and change notifications