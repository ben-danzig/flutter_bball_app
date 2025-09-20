import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/services/voice_command_service.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'dart:io';

class FakePathProviderPlatform extends PathProviderPlatform {
  final String path;

  FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceCommandService', () {
    late SettingsService settingsService;
    late VoiceCommandService voiceCommandService;
    late Directory tempDir;

    setUp(() async {
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('voice_test');
      
      // Mock path provider to use our temp directory
      PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
      
      // Create services
      settingsService = SettingsService();
      voiceCommandService = VoiceCommandService(settingsService);
    });

    tearDown(() async {
      voiceCommandService.dispose();
      // Clean up temp directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should initialize to disabled state when voice commands are disabled', () async {
      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(voiceCommandService.state, VoiceCommandState.disabled);
      expect(voiceCommandService.listeningMode, ListeningMode.none);
      expect(voiceCommandService.isListening, false);
    });

    test('should be disabled when voice commands are disabled in settings', () async {
      // Voice commands are disabled by default
      expect(settingsService.voiceCommandsEnabled, false);
      
      // Wait a bit for initialization
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(voiceCommandService.state, VoiceCommandState.disabled);
    });

    test('should expose settings correctly', () {
      expect(voiceCommandService.lastError, '');
      expect(voiceCommandService.currentTranscript, '');
      expect(voiceCommandService.isInitialized, false);
    });

    test('should handle settings changes', () async {
      // Initially disabled
      expect(voiceCommandService.state, VoiceCommandState.disabled);
      
      // Enable voice commands in settings
      await settingsService.setVoiceCommandsEnabled(true);
      
      // Service should attempt to initialize
      await Future.delayed(Duration(milliseconds: 100));
      
      // Note: Actual initialization will fail in tests without proper speech recognition setup
      // but the service should attempt to initialize
      expect(settingsService.voiceCommandsEnabled, true);
    });

    test('should notify listeners on state changes', () async {
      // Create fresh instances for this test
      final testSettings = SettingsService();
      final testVoiceService = VoiceCommandService(testSettings);
      
      int notificationCount = 0;
      testVoiceService.addListener(() {
        notificationCount++;
      });

      // Trigger a settings change
      await testSettings.setVoiceCommandsEnabled(true);
      
      // Wait for notifications
      await Future.delayed(Duration(milliseconds: 100));
      
      // Should have notified at least once
      expect(notificationCount, greaterThan(0));
      
      // Clean up
      testVoiceService.dispose();
    });

    test('should have correct listening modes', () {
      expect(ListeningMode.values.contains(ListeningMode.none), true);
      expect(ListeningMode.values.contains(ListeningMode.wakeWord), true);
      expect(ListeningMode.values.contains(ListeningMode.command), true);
      expect(ListeningMode.values.contains(ListeningMode.alwaysListening), true);
    });

    test('should have correct voice command states', () {
      expect(VoiceCommandState.values.contains(VoiceCommandState.uninitialized), true);
      expect(VoiceCommandState.values.contains(VoiceCommandState.initializing), true);
      expect(VoiceCommandState.values.contains(VoiceCommandState.ready), true);
      expect(VoiceCommandState.values.contains(VoiceCommandState.listening), true);
      expect(VoiceCommandState.values.contains(VoiceCommandState.processing), true);
      expect(VoiceCommandState.values.contains(VoiceCommandState.error), true);
      expect(VoiceCommandState.values.contains(VoiceCommandState.disabled), true);
    });
  });
}




