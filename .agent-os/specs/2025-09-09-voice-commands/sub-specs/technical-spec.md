# Technical Specification - Voice Commands

> Created: 2025-09-09
> Version: 1.0.0
> Parent Spec: @.agent-os/specs/2025-09-09-voice-commands/spec.md

## Architecture Overview

The voice commands feature will be implemented as a new service layer that integrates with the existing app architecture. The implementation follows a multi-layered approach with clear separation of concerns.

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                     │
├─────────────────────────────────────────────────────────────┤
│  Settings Screen  │  Active Workout Screen  │  Drill Widgets │
├─────────────────────────────────────────────────────────────┤
│                     Service Layer                          │
├─────────────────────────────────────────────────────────────┤
│  VoiceCommandService  │  AudioRouterService  │  CommandProcessor │
├─────────────────────────────────────────────────────────────┤
│                    Platform Layer                          │
├─────────────────────────────────────────────────────────────┤
│   speech_to_text    │   Platform Channels   │   Native Android │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack Selection

### Primary Speech Recognition: speech_to_text (^6.6.0)

**Rationale:**
- Most mature and widely-used Flutter speech recognition package
- Built-in platform optimizations for Android/iOS
- Supports continuous listening modes
- Good community support and documentation
- Native platform integration (Android SpeechRecognizer, iOS Speech framework)

**Capabilities:**
- Real-time speech recognition
- Configurable listening modes
- Built-in permission handling
- Multiple language support
- Noise cancellation on supported devices

### Platform Channel for Bluetooth Audio

**Implementation:** Custom Android platform channel
- Access native AudioManager APIs
- Bluetooth device detection and switching
- Audio routing management
- Integration with speech recognition pipeline

### Music Integration and Audio Ducking

**Implementation:** Audio focus management and ducking
- Integrate with Android AudioManager for audio focus
- Implement audio ducking when providing voice feedback
- Ensure voice commands work while music is playing
- Restore music volume after voice feedback completion

### Always-Listening Mode Configuration

**Design Pattern:** Configurable drill type constants
- Centralized configuration of which drill types enable always-listening
- Easy to extend for new drill types without code changes
- Clear separation between drill logic and voice command behavior
- Consistent behavior across all drill widgets

**Benefits:**
- **Maintainability**: Single source of truth for always-listening drill types
- **Extensibility**: Easy to add new drill types that support shot registration
- **Testability**: Clear configuration makes testing mode switching straightforward
- **Performance**: Avoids repeated type checking logic

### Confidence Threshold Architecture

**Design Pattern:** Settings-driven configuration with dependency injection
- SettingsService as single source of truth for confidence threshold
- CommandProcessor receives SettingsService dependency
- Dynamic threshold adjustment without app restart
- User-controlled personalization via Settings UI

**Benefits:**
- **User Control**: Users can adjust thresholds based on environment/accent
- **Personalization**: Different users may need different sensitivity levels
- **Runtime Flexibility**: Changes take effect immediately
- **Consistency**: Follows established settings pattern

### Alternative Technologies Considered

**Vosk (Rejected for V1):**
- Pro: Fully offline, customizable
- Con: Large app size increase (50MB+), complexity

**Google Cloud Speech-to-Text (Future consideration):**
- Pro: Superior accuracy, advanced features
- Con: Requires API costs, network dependency

## Service Architecture

### 1. VoiceCommandService

Core orchestration service managing all voice command functionality.

```dart
class VoiceCommandService extends ChangeNotifier {
  // Dependencies
  final SpeechToText _speechToText = SpeechToText();
  WorkoutState? _workoutState;
  SettingsService? _settingsService;
  AudioService? _audioService;
  AudioRouterService? _audioRouter;
  CommandProcessor? _commandProcessor;
  
  // State
  VoiceMode _currentMode = VoiceMode.disabled;
  bool _isListening = false;
  bool _isWaitingForCommand = false;
  
  // Configuration
  static const String defaultWakeWord = "hey coach";
  static const List<String> makeWords = ["make", "bucket", "in", "yes", "yep", "yup", "good", "swish"];
  static const List<String> missWords = ["miss", "brick", "off", "no", "nope", "out", "clank"];
  static const List<String> alwaysListeningDrillTypes = [
    DrillTypes.makeTargetTimed,
    // Add other drill types that should enable always-listening mode
  ];
  
  // Initialize command processor with settings dependency
  void _initializeCommandProcessor() {
    if (_settingsService != null) {
      _commandProcessor = CommandProcessor(_settingsService!);
    }
  }
  
  // Public Interface
  Future<bool> initialize();
  Future<void> enableVoiceCommands();
  Future<void> disableVoiceCommands();
  void startWakeWordListening();
  void startAlwaysListening();
  void stopListening();
}

enum VoiceMode {
  disabled,
  wakeWordListening,
  commandListening,
  alwaysListening,
  error
}
```

### 2. AudioRouterService (Platform Channel)

Manages audio input device routing, particularly for Bluetooth microphones.

```dart
class AudioRouterService {
  static const MethodChannel _channel = 
      MethodChannel('com.bball.app/audio_router');
  
  Future<List<AudioDevice>> getAvailableInputDevices();
  Future<bool> setPreferredInputDevice(String deviceId);
  Future<AudioDevice?> getCurrentInputDevice();
  Stream<AudioDeviceEvent> get deviceChanges;
  
  // Bluetooth-specific methods
  Future<bool> switchToBluetoothMic();
  Future<bool> switchToInternalMic();
  Future<bool> isBluetoothMicAvailable();
}

class AudioDevice {
  final String id;
  final String name;
  final AudioDeviceType type;
  final bool isConnected;
  final bool isPreferred;
}
```

### 3. CommandProcessor

Handles speech-to-command parsing with fuzzy matching and confidence scoring.

```dart
class CommandProcessor {
  final SettingsService _settingsService;
  
  CommandProcessor(this._settingsService);
  
  // Dynamic confidence threshold from settings
  double get confidenceThreshold => _settingsService.voiceConfidenceThreshold;
  
  // Main processing method
  CommandResult processSpokenText(String text, VoiceMode currentMode) {
    final cleanText = _normalizeText(text);
    
    if (currentMode == VoiceMode.commandListening) {
      return _processMetaCommand(cleanText);
    } else if (currentMode == VoiceMode.alwaysListening) {
      return _processShotCommand(cleanText);
    }
    
    return CommandResult.unrecognized(text);
  }
  
  // Fuzzy matching for make/miss detection
  ShotResult? detectShotResult(String text) {
    final makeConfidence = _calculateBestMatch(text, makeWords);
    final missConfidence = _calculateBestMatch(text, missWords);
    
    if (makeConfidence > confidenceThreshold && makeConfidence > missConfidence) {
      return ShotResult.make(makeConfidence);
    } else if (missConfidence > confidenceThreshold) {
      return ShotResult.miss(missConfidence);
    }
    
    return null;
  }
}
```

## Implementation Phases

### Phase 1: Foundation (Weeks 1-2)
**Goal:** Basic voice command infrastructure

**Tasks:**
1. Add speech_to_text dependency to pubspec.yaml
2. Create VoiceCommandService with basic initialization
3. Extend SettingsService with voice command preferences
4. Update Settings UI with voice commands toggle
5. Implement microphone permission handling
6. Create basic command processing for pause/resume

**Deliverables:**
- Working voice commands toggle in settings
- Basic speech recognition with simple commands
- Permission handling for microphone access

### Phase 2: Core Commands (Weeks 3-4)
**Goal:** Wake word detection and meta commands

**Tasks:**
1. Implement wake word detection using continuous listening
2. Add command timeout handling (3-second window)
3. Create all meta commands (pause, resume, next, previous, reset, "made X shots")
4. Add audio feedback for command confirmation
5. Implement visual indicators for listening states
6. Add error handling for unrecognized commands

**Deliverables:**
- Wake word activation working
- All workout control commands functional
- Audio and visual feedback system
- REP_BASED drill voice reporting

### Phase 3: Bluetooth Integration (Weeks 5-6)
**Goal:** Bluetooth microphone support via platform channels

**Tasks:**
1. Create Android platform channel for audio routing
2. Implement Bluetooth device detection and switching
3. Add audio device preference management
4. Handle device disconnection gracefully
5. Create audio device selection UI
6. Add troubleshooting guidance for users
7. Implement music audio ducking for voice feedback

**Deliverables:**
- Bluetooth microphone support
- Device management UI
- Robust audio routing system
- Music integration with audio ducking

### Phase 4: Shot Registration (Weeks 7-8)
**Goal:** Always-listening mode for make/miss tracking

**Tasks:**
1. Implement always-listening mode during shooting drills
2. Add automatic mode switching based on drill type
3. Create make/miss word detection with confidence scoring
4. Handle mode transitions (wake word interrupts always-listening)
5. Integrate with existing drill result logging
6. Add shot registration audio feedback

**Deliverables:**
- Hands-free shot registration working
- Intelligent mode switching
- Integration with drill widgets

## Integration Points

### SettingsService Extension
```dart
// Add to existing SettingsService
class SettingsService extends ChangeNotifier {
  // New voice command settings
  bool _voiceCommandsEnabled = false;
  bool _audioCommandFeedback = true;
  String _preferredAudioDeviceId = '';
  double _voiceConfidenceThreshold = 0.7;
  
  // Getters
  bool get voiceCommandsEnabled => _voiceCommandsEnabled;
  bool get audioCommandFeedback => _audioCommandFeedback;
  String get preferredAudioDeviceId => _preferredAudioDeviceId;
  double get voiceConfidenceThreshold => _voiceConfidenceThreshold;
  
  // Setters with persistence
  Future<void> setVoiceCommandsEnabled(bool enabled);
  Future<void> setAudioCommandFeedback(bool enabled);
  Future<void> setPreferredAudioDevice(String deviceId);
  Future<void> setVoiceConfidenceThreshold(double threshold);
}
```

### WorkoutState Integration
```dart
// Extend existing WorkoutState
class WorkoutState extends ChangeNotifier {
  VoiceCommandService? _voiceCommandService;
  
  void setVoiceCommandService(VoiceCommandService service) {
    _voiceCommandService = service;
    service.setWorkoutState(this);
  }
  
  void handleVoiceCommand(CommandType command) {
    switch (command) {
      case CommandType.pause:
        togglePause();
        break;
      case CommandType.resume:
        if (isPaused) togglePause();
        break;
      case CommandType.next:
        nextDrill();
        break;
      case CommandType.previous:
        previousDrill();
        break;
      case CommandType.reset:
        resetCurrentDrill();
        break;
    }
  }
  
  bool get shouldEnableAlwaysListening {
    return isWorkoutStarted && 
           !isPaused && 
           currentDrill?.type != null &&
           VoiceCommandService.alwaysListeningDrillTypes.contains(currentDrill!.type);
  }
}
```

### Main App Integration
```dart
// Update main.dart provider setup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => WorkoutState()),
        ChangeNotifierProvider(create: (context) => SettingsService()),
        Provider<SoundEffectsService>(create: (context) => SoundEffectsService()),
        ChangeNotifierProvider(create: (context) => VoiceCommandService()), // New
        Provider<AudioRouterService>(create: (context) => AudioRouterService()), // New
      ],
      child: const BballTrainerApp(),
    ),
  );
}
```

## Platform Channel Implementation

### Android Native Code
```kotlin
// android/app/src/main/kotlin/com/example/flutter_bball_app/MainActivity.kt
class MainActivity: FlutterActivity() {
    private val AUDIO_ROUTER_CHANNEL = "com.bball.app/audio_router"
    private lateinit var audioManager: AudioManager
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_ROUTER_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAvailableInputDevices" -> getAvailableInputDevices(result)
                    "setPreferredInputDevice" -> setPreferredInputDevice(call, result)
                    "getCurrentInputDevice" -> getCurrentInputDevice(result)
                    "isBluetoothMicAvailable" -> isBluetoothMicAvailable(result)
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun getAvailableInputDevices(result: MethodChannel.Result) {
        // Implementation for getting audio input devices
    }
    
    private fun setPreferredInputDevice(call: MethodCall, result: MethodChannel.Result) {
        // Implementation for setting preferred audio input
    }
}
```

### Required Android Permissions
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

## Error Handling & Edge Cases

### Recognition Errors
```dart
enum VoiceCommandError {
  permissionDenied,
  microphoneUnavailable,
  speechRecognitionFailed,
  bluetoothDisconnected,
  networkTimeout,
  serviceNotInitialized,
  lowConfidence
}

class VoiceCommandException implements Exception {
  final VoiceCommandError error;
  final String message;
  final String? userGuidance;
  
  String get userFriendlyMessage {
    switch (error) {
      case VoiceCommandError.permissionDenied:
        return "Microphone permission is required for voice commands";
      case VoiceCommandError.bluetoothDisconnected:
        return "Bluetooth headphones disconnected. Switching to phone microphone.";
      // ... other cases
    }
  }
}
```

### Fallback Strategies
1. **Bluetooth failure:** Automatically switch to internal microphone
2. **Recognition failure:** Provide visual cue to retry command
3. **Permission denied:** Show settings guidance and disable feature
4. **Network issues:** Use cached models where possible
5. **Low confidence:** Request command repetition

## Performance Considerations

### Memory Management
- Lazy initialization of speech services
- Proper disposal of listeners and platform channels
- Limit recognition result history to prevent memory leaks

### Battery Optimization
- Use efficient listening modes (start/stop based on workout state)
- Implement smart wake word detection (reduce CPU when not needed)
- Monitor battery usage and provide user feedback

### Recognition Accuracy
- Implement confidence thresholds for different command types
- Use context-aware recognition (drill type influences word matching)
- Support accent and pronunciation variations

## Testing Strategy

### Unit Tests
- CommandProcessor with various speech inputs
- Confidence scoring algorithms
- Mode transition logic
- Error handling scenarios

### Integration Tests
- End-to-end voice command flows
- Service integration with WorkoutState
- Settings persistence and loading
- Platform channel communication

### Device Testing
- Multiple Android devices and API levels
- Various Bluetooth headphone models
- Different acoustic environments
- Edge cases (phone calls, notifications interrupting)

This technical specification provides a detailed roadmap for implementing voice commands while maintaining clean architecture and robust error handling.