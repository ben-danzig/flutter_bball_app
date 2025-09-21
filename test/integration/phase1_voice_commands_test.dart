import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:flutter_bball_app/services/voice_command_service.dart';
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

  group('Phase 1 Voice Commands Integration', () {
    late SettingsService settingsService;
    late VoiceCommandService voiceCommandService;
    late Directory tempDir;

    setUp(() async {
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('phase1_test');
      
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

    test('Phase 1.1: Dependencies and setup are properly configured', () {
      // Verify settings service is created
      expect(settingsService, isNotNull);
      
      // Verify voice command service is created
      expect(voiceCommandService, isNotNull);
      
      // Verify default settings
      expect(settingsService.voiceCommandsEnabled, false);
      expect(settingsService.audioCommandFeedback, true);
      expect(settingsService.voiceConfidenceThreshold, 0.7);
    });

    test('Phase 1.2: Settings persistence works correctly', () async {
      // Change settings
      await settingsService.setVoiceCommandsEnabled(true);
      await settingsService.setAudioCommandFeedback(false);
      await settingsService.setVoiceConfidenceThreshold(0.8);
      
      // Verify changes
      expect(settingsService.voiceCommandsEnabled, true);
      expect(settingsService.audioCommandFeedback, false);
      expect(settingsService.voiceConfidenceThreshold, 0.8);
      
      // Create new settings service to test persistence
      final newSettings = SettingsService();
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(newSettings.voiceCommandsEnabled, true);
      expect(newSettings.audioCommandFeedback, false);
      expect(newSettings.voiceConfidenceThreshold, 0.8);
    });

    test('Phase 1.4: VoiceCommandService responds to settings changes', () async {
      // Initially disabled
      expect(voiceCommandService.state, VoiceCommandState.disabled);
      
      // Enable voice commands
      await settingsService.setVoiceCommandsEnabled(true);
      await Future.delayed(Duration(milliseconds: 100));
      
      // Service should attempt to initialize (will fail due to no speech recognition in tests)
      expect(voiceCommandService.state, anyOf([
        VoiceCommandState.initializing,
        VoiceCommandState.error,
      ]));
    });

    test('Phase 1.5: Command processor recognizes all basic commands', () {
      final processor = CommandProcessor(settingsService);
      
      // Test pause command
      var result = processor.processCommand('pause');
      expect(result, isNotNull);
      expect(result!.type, CommandType.pause);
      
      // Test resume command
      result = processor.processCommand('resume');
      expect(result, isNotNull);
      expect(result!.type, CommandType.resume);
      
      // Test next command
      result = processor.processCommand('next');
      expect(result, isNotNull);
      expect(result!.type, CommandType.next);
      
      // Test previous command
      result = processor.processCommand('previous');
      expect(result, isNotNull);
      expect(result!.type, CommandType.previous);
      
      // Test reset command
      result = processor.processCommand('reset');
      expect(result, isNotNull);
      expect(result!.type, CommandType.reset);
      
      // Test made shots command
      result = processor.processCommand('made 5 shots');
      expect(result, isNotNull);
      expect(result!.type, CommandType.madeShots);
      expect(result.data, 5);
    });

    test('Phase 1.5: Command processor uses confidence threshold correctly', () {
      final processor = CommandProcessor(settingsService);
      
      // All recognized commands should have confidence 1.0
      final result = processor.processCommand('pause');
      expect(result, isNotNull);
      expect(result!.confidence, 1.0);
      
      // This ensures commands will be accepted when confidence > threshold
      expect(result.confidence, greaterThan(settingsService.voiceConfidenceThreshold));
    });

    test('Integration: All Phase 1 components work together', () async {
      // Enable voice commands
      await settingsService.setVoiceCommandsEnabled(true);
      await settingsService.setVoiceConfidenceThreshold(0.7);
      
      // Verify settings are applied
      expect(settingsService.voiceCommandsEnabled, true);
      
      // Command processor should work with settings
      final processor = CommandProcessor(settingsService);
      final result = processor.processCommand('pause workout');
      expect(result, isNotNull);
      expect(result!.type, CommandType.pause);
      
      // Verify all command types are available
      expect(CommandType.values.length, greaterThanOrEqualTo(8));
      expect(CommandType.values.contains(CommandType.pause), true);
      expect(CommandType.values.contains(CommandType.resume), true);
      expect(CommandType.values.contains(CommandType.next), true);
      expect(CommandType.values.contains(CommandType.previous), true);
      expect(CommandType.values.contains(CommandType.reset), true);
      expect(CommandType.values.contains(CommandType.madeShots), true);
      expect(CommandType.values.contains(CommandType.make), true);
      expect(CommandType.values.contains(CommandType.miss), true);
    });
  });
}




