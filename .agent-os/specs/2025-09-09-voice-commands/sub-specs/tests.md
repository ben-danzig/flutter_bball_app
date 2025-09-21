# Test Specification - Voice Commands

> Created: 2025-09-09
> Version: 1.0.0
> Parent Spec: @.agent-os/specs/2025-09-09-voice-commands/spec.md

## Testing Overview

This document outlines the comprehensive testing strategy for the voice commands feature, covering unit tests, integration tests, and user acceptance testing. The testing approach ensures reliability, accuracy, and user experience quality across different environments and edge cases.

## Test Categories

### 1. Unit Tests

#### VoiceCommandService Tests
```dart
group('VoiceCommandService', () {
  late VoiceCommandService service;
  late MockSpeechToText mockSpeechToText;
  late MockSettingsService mockSettings;
  
  setUp(() {
    mockSpeechToText = MockSpeechToText();
    mockSettings = MockSettingsService();
    service = VoiceCommandService();
  });
  
  group('Initialization', () {
    test('should initialize successfully with permissions granted', () async {
      when(mockSpeechToText.initialize()).thenAnswer((_) async => true);
      
      final result = await service.initialize();
      
      expect(result, true);
      expect(service.isInitialized, true);
    });
    
    test('should fail gracefully when permissions denied', () async {
      when(mockSpeechToText.initialize()).thenAnswer((_) async => false);
      
      final result = await service.initialize();
      
      expect(result, false);
      expect(service.currentError, VoiceCommandError.permissionDenied);
    });
  });
  
  group('Mode Management', () {
    test('should transition from wake word to command listening', () async {
      service.startWakeWordListening();
      expect(service.currentMode, VoiceMode.wakeWordListening);
      
      service.onWakeWordDetected();
      expect(service.currentMode, VoiceMode.commandListening);
    });
    
    test('should timeout command listening after 3 seconds', () async {
      service.startCommandListening();
      
      await Future.delayed(Duration(seconds: 4));
      
      expect(service.currentMode, VoiceMode.wakeWordListening);
    });
  });
});
```

#### CommandProcessor Tests
```dart
group('CommandProcessor', () {
  late CommandProcessor processor;
  
  setUp(() {
    processor = CommandProcessor();
  });
  
  group('Meta Command Recognition', () {
    test('should recognize pause commands with variations', () {
      final testCases = [
        'pause',
        'stop',
        'hold on',
        'wait',
        'pause workout'
      ];
      
      for (final input in testCases) {
        final result = processor.processSpokenText(input, VoiceMode.commandListening);
        expect(result.type, CommandType.pause);
        expect(result.confidence, greaterThan(0.7));
      }
    });
    
    test('should recognize resume commands', () {
      final testCases = [
        'resume',
        'continue',
        'start',
        'go',
        'keep going'
      ];
      
      for (final input in testCases) {
        final result = processor.processSpokenText(input, VoiceMode.commandListening);
        expect(result.type, CommandType.resume);
      }
    });
    
    test('should handle next drill commands', () {
      final testCases = [
        'next',
        'next drill',
        'move on',
        'skip',
        'advance'
      ];
      
      for (final input in testCases) {
        final result = processor.processSpokenText(input, VoiceMode.commandListening);
        expect(result.type, CommandType.next);
      }
    });
  });
  
  group('Shot Result Recognition', () {
    test('should detect makes with high confidence', () {
      final makeWords = [
        'make',
        'bucket',
        'in',
        'good',
        'yes',
        'swish',
        'score'
      ];
      
      for (final word in makeWords) {
        final result = processor.detectShotResult(word);
        expect(result?.type, ShotResultType.make);
        expect(result?.confidence, greaterThan(0.8));
      }
    });
    
    test('should detect misses with high confidence', () {
      final missWords = [
        'miss',
        'brick',
        'off',
        'no',
        'out',
        'clank',
        'rim'
      ];
      
      for (final word in missWords) {
        final result = processor.detectShotResult(word);
        expect(result?.type, ShotResultType.miss);
        expect(result?.confidence, greaterThan(0.8));
      }
    });
    
    test('should handle similar-sounding words correctly', () {
      // Test fuzzy matching
      final testCases = [
        ('mke', ShotResultType.make), // typo simulation
        ('brik', ShotResultType.miss),
        ('maek', ShotResultType.make),
        ('yas', ShotResultType.make), // accent variation
      ];
      
      for (final (input, expectedType) in testCases) {
        final result = processor.detectShotResult(input);
        expect(result?.type, expectedType);
      }
    });
    
    test('should reject ambiguous inputs', () {
      final ambiguousInputs = [
        'maybe',
        'sort of',
        'hello',
        'what',
        'um'
      ];
      
      for (final input in ambiguousInputs) {
        final result = processor.detectShotResult(input);
        expect(result, isNull);
      }
    });
  });
  
  group('Confidence Scoring', () {
    test('should score exact matches highly', () {
      final confidence = processor.calculateConfidence('make', ['make', 'bucket']);
      expect(confidence, equals(1.0));
    });
    
    test('should score partial matches appropriately', () {
      final confidence = processor.calculateConfidence('mak', ['make']);
      expect(confidence, greaterThan(0.7));
      expect(confidence, lessThan(1.0));
    });
    
    test('should score unrelated words lowly', () {
      final confidence = processor.calculateConfidence('elephant', ['make', 'miss']);
      expect(confidence, lessThan(0.3));
    });
  });
});
```

#### AudioRouterService Tests
```dart
group('AudioRouterService', () {
  late AudioRouterService service;
  late MockMethodChannel mockChannel;
  
  setUp(() {
    mockChannel = MockMethodChannel();
    service = AudioRouterService();
  });
  
  test('should get available input devices', () async {
    final mockDevices = [
      {'id': 'internal', 'name': 'Phone Microphone', 'type': 'internal'},
      {'id': 'bt123', 'name': 'AirPods Pro', 'type': 'bluetooth'}
    ];
    
    when(mockChannel.invokeMethod('getAvailableInputDevices'))
        .thenAnswer((_) async => mockDevices);
    
    final devices = await service.getAvailableInputDevices();
    
    expect(devices.length, 2);
    expect(devices[0].name, 'Phone Microphone');
    expect(devices[1].type, AudioDeviceType.bluetooth);
  });
  
  test('should switch to bluetooth microphone when available', () async {
    when(mockChannel.invokeMethod('setPreferredInputDevice', any))
        .thenAnswer((_) async => true);
    
    final result = await service.switchToBluetoothMic();
    
    expect(result, true);
    verify(mockChannel.invokeMethod('setPreferredInputDevice', any)).called(1);
  });
});
```

### 2. Integration Tests

#### End-to-End Voice Command Flow
```dart
group('Voice Command Integration', () {
  late WidgetTester tester;
  late MockWorkoutState mockWorkoutState;
  late MockSettingsService mockSettings;
  
  setUp(() async {
    mockWorkoutState = MockWorkoutState();
    mockSettings = MockSettingsService();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WorkoutState>.value(value: mockWorkoutState),
          ChangeNotifierProvider<SettingsService>.value(value: mockSettings),
        ],
        child: MaterialApp(home: ActiveWorkoutScreen()),
      ),
    );
  });
  
  testWidgets('should pause workout via voice command', (tester) async {
    // Setup: workout is active and not paused
    when(mockWorkoutState.isWorkoutStarted).thenReturn(true);
    when(mockWorkoutState.isPaused).thenReturn(false);
    when(mockSettings.voiceCommandsEnabled).thenReturn(true);
    
    // Simulate voice command
    final voiceService = Provider.of<VoiceCommandService>(
      tester.element(find.byType(ActiveWorkoutScreen)),
      listen: false
    );
    
    voiceService.simulateVoiceInput('hey coach');
    await tester.pump();
    
    voiceService.simulateVoiceInput('pause');
    await tester.pump();
    
    // Verify workout was paused
    verify(mockWorkoutState.togglePause()).called(1);
  });
  
  testWidgets('should register shot results during shooting drill', (tester) async {
    // Setup: shooting drill is active
    final mockDrill = Drill(
      drillId: 'test',
      name: 'Free Throws',
      type: DrillTypes.makeTargetTimed,
      targetMakes: 10,
    );
    
    when(mockWorkoutState.currentDrill).thenReturn(mockDrill);
    when(mockWorkoutState.isWorkoutStarted).thenReturn(true);
    when(mockWorkoutState.isPaused).thenReturn(false);
    
    // Simulate shot registration
    final voiceService = Provider.of<VoiceCommandService>(
      tester.element(find.byType(ActiveWorkoutScreen)),
      listen: false
    );
    
    voiceService.simulateVoiceInput('make');
    await tester.pump();
    
    // Verify shot was registered
    verify(mockWorkoutState.logMakeTargetTimedDrill(makes: 1, misses: 0)).called(1);
  });
});
```

#### Settings Integration
```dart
group('Settings Integration', () {
  testWidgets('should enable voice commands from settings', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsService()),
          ChangeNotifierProvider(create: (_) => VoiceCommandService()),
        ],
        child: MaterialApp(home: SettingsScreen()),
      ),
    );
    
    // Find and tap voice commands toggle
    final toggle = find.byKey(Key('voice_commands_toggle'));
    expect(toggle, findsOneWidget);
    
    await tester.tap(toggle);
    await tester.pump();
    
    // Verify service was notified
    final voiceService = Provider.of<VoiceCommandService>(
      tester.element(find.byType(SettingsScreen)),
      listen: false
    );
    
    expect(voiceService.isEnabled, true);
  });
});
```

### 3. Device Tests

#### Bluetooth Integration Tests
```dart
group('Bluetooth Device Tests', () {
  // These tests require actual Bluetooth hardware
  // Run on physical devices with different headphone models
  
  test('should detect AirPods Pro connection', () async {
    final audioRouter = AudioRouterService();
    await audioRouter.initialize();
    
    // Connect AirPods during test
    await Future.delayed(Duration(seconds: 2));
    
    final devices = await audioRouter.getAvailableInputDevices();
    final airpods = devices.firstWhere(
      (d) => d.name.contains('AirPods'),
      orElse: () => throw 'AirPods not detected'
    );
    
    expect(airpods.type, AudioDeviceType.bluetooth);
    expect(airpods.isConnected, true);
  });
  
  test('should handle Bluetooth disconnection gracefully', () async {
    final voiceService = VoiceCommandService();
    await voiceService.initialize();
    
    // Start voice recognition with Bluetooth
    await voiceService.enableVoiceCommands();
    expect(voiceService.currentAudioDevice?.type, AudioDeviceType.bluetooth);
    
    // Simulate disconnection (turn off headphones)
    await Future.delayed(Duration(seconds: 5));
    
    // Should fallback to internal microphone
    expect(voiceService.currentAudioDevice?.type, AudioDeviceType.internal);
    expect(voiceService.isListening, true); // Should continue listening
  });
});
```

#### Performance Tests
```dart
group('Performance Tests', () {
  test('should recognize commands within 500ms', () async {
    final processor = CommandProcessor();
    final stopwatch = Stopwatch()..start();
    
    final result = processor.processSpokenText('pause', VoiceMode.commandListening);
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
    expect(result.type, CommandType.pause);
  });
  
  test('should handle continuous listening without memory leaks', () async {
    final voiceService = VoiceCommandService();
    await voiceService.initialize();
    
    // Monitor memory usage
    final initialMemory = await _getCurrentMemoryUsage();
    
    // Run continuous listening for 5 minutes
    voiceService.startWakeWordListening();
    
    for (int i = 0; i < 300; i++) { // 5 minutes
      await Future.delayed(Duration(seconds: 1));
      if (i % 60 == 0) {
        // Check memory every minute
        final currentMemory = await _getCurrentMemoryUsage();
        expect(currentMemory - initialMemory, lessThan(50 * 1024 * 1024)); // <50MB increase
      }
    }
  });
});
```

### 4. User Acceptance Tests

#### Scenario-Based Testing
```dart
group('User Scenarios', () {
  group('Basketball Player Using Voice Commands', () {
    test('Scenario: Free throw practice with Bluetooth headphones', () async {
      // Given: Player has Bluetooth headphones connected
      // And: Voice commands are enabled
      // And: Free throw drill is active (MAKE_TARGET_TIMED, target: 10)
      
      final testScenario = VoiceCommandTestScenario();
      await testScenario.setupBluetoothHeadphones();
      await testScenario.startFreethrowDrill(targetMakes: 10);
      
      // When: Player takes shots and calls results
      await testScenario.simulateShot('make'); // Shot 1
      await testScenario.simulateShot('make'); // Shot 2
      await testScenario.simulateShot('miss'); // Shot 3
      await testScenario.simulateShot('make'); // Shot 4
      
      // Then: Results should be accurately recorded
      expect(testScenario.currentMakes, 3);
      expect(testScenario.currentMisses, 1);
      
      // And: Audio feedback should be provided
      expect(testScenario.audioFeedbackReceived, isTrue);
      
      // When: Player says wake word + command
      await testScenario.simulateVoiceCommand('hey coach', 'next drill');
      
      // Then: Should advance to next drill
      expect(testScenario.currentDrillIndex, 1);
    });
    
    test('Scenario: Noisy gym environment', () async {
      // Given: Background noise simulation (dribbling, crowd)
      final testScenario = VoiceCommandTestScenario();
      await testScenario.setupNoisyEnvironment(noiseLevel: 70); // dB
      
      // When: Player uses voice commands
      final recognitionResults = [];
      for (int i = 0; i < 20; i++) {
        final result = await testScenario.simulateNoisyVoiceCommand('make');
        recognitionResults.add(result.wasRecognized);
      }
      
      // Then: Recognition accuracy should be > 80%
      final accuracy = recognitionResults.where((r) => r).length / recognitionResults.length;
      expect(accuracy, greaterThan(0.8));
    });
  });
});
```

### 5. Edge Case Tests

#### Error Handling Tests
```dart
group('Edge Cases', () {
  test('should handle microphone permission revoked during use', () async {
    final voiceService = VoiceCommandService();
    await voiceService.initialize();
    await voiceService.enableVoiceCommands();
    
    expect(voiceService.isListening, true);
    
    // Simulate permission revocation
    await voiceService.simulatePermissionRevoked();
    
    expect(voiceService.currentError, VoiceCommandError.permissionDenied);
    expect(voiceService.isListening, false);
    
    // Should provide user guidance
    expect(voiceService.userGuidanceMessage, isNotNull);
  });
  
  test('should handle phone call interruption', () async {
    final voiceService = VoiceCommandService();
    await voiceService.initialize();
    await voiceService.enableVoiceCommands();
    
    // Simulate incoming phone call
    await voiceService.simulatePhoneCallInterruption();
    
    expect(voiceService.isListening, false);
    expect(voiceService.currentMode, VoiceMode.disabled);
    
    // Should resume after call ends
    await voiceService.simulatePhoneCallEnded();
    
    expect(voiceService.isListening, true);
    expect(voiceService.currentMode, VoiceMode.wakeWordListening);
  });
  
  test('should handle speech recognition service crash', () async {
    final voiceService = VoiceCommandService();
    await voiceService.initialize();
    
    // Simulate service crash
    await voiceService.simulateServiceCrash();
    
    expect(voiceService.currentError, VoiceCommandError.speechRecognitionFailed);
    
    // Should attempt recovery
    await Future.delayed(Duration(seconds: 2));
    
    expect(voiceService.isRecovering, true);
    
    // Should eventually recover or provide fallback
    await Future.delayed(Duration(seconds: 5));
    
    expect(voiceService.currentMode, isNot(VoiceMode.error));
  });
});
```

#### Boundary Tests
```dart
group('Boundary Tests', () {
  test('should handle very long speech input', () async {
    final processor = CommandProcessor();
    final longInput = 'this is a very long speech input that goes on and on and includes many words but should still be processed correctly and the command should be extracted even though there is a lot of extra noise in the input make';
    
    final result = processor.detectShotResult(longInput);
    
    expect(result?.type, ShotResultType.make);
    expect(result?.confidence, greaterThan(0.7));
  });
  
  test('should handle rapid consecutive commands', () async {
    final voiceService = VoiceCommandService();
    await voiceService.initialize();
    
    // Simulate rapid commands
    final commands = ['make', 'miss', 'make', 'make', 'miss'];
    final results = <ShotResult>[];
    
    for (final command in commands) {
      final result = await voiceService.processImmediateCommand(command);
      results.add(result);
      // No delay between commands
    }
    
    expect(results.length, 5);
    expect(results.where((r) => r.type == ShotResultType.make).length, 3);
    expect(results.where((r) => r.type == ShotResultType.miss).length, 2);
  });
  
  test('should handle very quiet speech input', () async {
    final voiceService = VoiceCommandService();
    await voiceService.initialize();
    
    // Simulate very quiet input (low volume)
    final result = await voiceService.processQuietInput('make', volumeLevel: 0.1);
    
    // Should still recognize or provide appropriate feedback
    expect(result.wasProcessed || result.requestedRetry, true);
  });
});
```

## Test Data and Fixtures

### Speech Input Variations
```dart
class VoiceTestData {
  static const Map<String, List<String>> commandVariations = {
    'pause': [
      'pause',
      'stop',
      'hold on',
      'wait',
      'pause workout',
      'stop the drill',
      'hold up',
      'wait a minute'
    ],
    'resume': [
      'resume',
      'continue',
      'start',
      'go',
      'keep going',
      'resume workout',
      'start again',
      'continue drill'
    ],
    'make': [
      'make',
      'bucket',
      'in',
      'good',
      'yes',
      'swish',
      'score',
      'got it',
      'perfect',
      'nailed it'
    ],
    'miss': [
      'miss',
      'brick',
      'off',
      'no',
      'out',
      'clank',
      'rim',
      'missed it',
      'no good',
      'dang'
    ]
  };
  
  static const List<String> accentVariations = [
    'mek', // make with accent
    'gud', // good with accent
    'brik', // brick with accent
    'yas', // yes with accent
  ];
  
  static const List<String> noisyEnvironmentInputs = [
    'make [dribbling sounds]',
    '[crowd noise] bucket',
    'good shot [whistle]',
    '[shoe squeak] miss'
  ];
}
```

### Mock Implementations
```dart
class MockVoiceCommandService extends Mock implements VoiceCommandService {
  @override
  Future<bool> initialize() async => true;
  
  @override
  void simulateVoiceInput(String input) {
    // Simulate processing with realistic delay
    Future.delayed(Duration(milliseconds: 200), () {
      final result = CommandProcessor().processSpokenText(input, currentMode);
      notifyListeners();
    });
  }
}
```

## Test Environment Setup

### Prerequisites
- Physical Android device with microphone
- Bluetooth headphones for device testing
- Quiet testing environment
- Noisy environment simulation capability

### Test Configuration
```yaml
# test_config.yaml
voice_command_tests:
  confidence_threshold: 0.7
  max_response_time_ms: 500
  bluetooth_test_devices:
    - "AirPods Pro"
    - "Sony WH-1000XM4"
    - "Jabra Elite 85h"
  test_environments:
    - quiet_room
    - gym_simulation
    - outdoor_court
```

## Success Criteria

### Functional Tests
- [ ] All unit tests pass (>95% code coverage)
- [ ] Integration tests pass for all user flows
- [ ] Voice commands work in 3+ different acoustic environments
- [ ] Bluetooth switching works with 3+ headphone models

### Performance Tests
- [ ] Command recognition < 500ms response time
- [ ] Memory usage increase < 50MB during extended use
- [ ] Battery impact < 10% during 60-minute session

### User Acceptance Tests
- [ ] >90% accuracy in quiet environments
- [ ] >80% accuracy in moderate noise environments
- [ ] Users prefer voice commands over manual interaction
- [ ] Error recovery is intuitive and helpful

### Reliability Tests
- [ ] No crashes during 2-hour continuous operation
- [ ] Graceful handling of all identified edge cases
- [ ] Successful recovery from all error conditions

This comprehensive test specification ensures the voice commands feature is thoroughly validated across all scenarios and provides a reliable, accurate user experience.
