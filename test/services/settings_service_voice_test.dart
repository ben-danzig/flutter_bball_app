import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'dart:io';

class MockPathProviderPlatform extends Mock implements PathProviderPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService Voice Commands', () {
    late SettingsService settingsService;
    late Directory tempDir;

    setUp(() async {
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('settings_test');
      
      // Mock path provider to use our temp directory
      PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
      
      // Create settings service
      settingsService = SettingsService();
    });

    tearDown(() async {
      // Clean up temp directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should have correct default values for voice command settings', () {
      expect(settingsService.voiceCommandsEnabled, false);
      expect(settingsService.audioCommandFeedback, true);
      expect(settingsService.voiceConfidenceThreshold, 0.7);
      expect(settingsService.preferredAudioDeviceId, '');
    });

    test('should update voiceCommandsEnabled and persist', () async {
      await settingsService.setVoiceCommandsEnabled(true);
      expect(settingsService.voiceCommandsEnabled, true);

      // Create a new service instance to test persistence
      final newService = SettingsService();
      await Future.delayed(Duration(milliseconds: 100)); // Allow time for loading
      expect(newService.voiceCommandsEnabled, true);
    });

    test('should update audioCommandFeedback and persist', () async {
      await settingsService.setAudioCommandFeedback(false);
      expect(settingsService.audioCommandFeedback, false);

      // Create a new service instance to test persistence
      final newService = SettingsService();
      await Future.delayed(Duration(milliseconds: 100)); // Allow time for loading
      expect(newService.audioCommandFeedback, false);
    });

    test('should update voiceConfidenceThreshold and persist', () async {
      await settingsService.setVoiceConfidenceThreshold(0.9);
      expect(settingsService.voiceConfidenceThreshold, 0.9);

      // Create a new service instance to test persistence
      final newService = SettingsService();
      await Future.delayed(Duration(milliseconds: 100)); // Allow time for loading
      expect(newService.voiceConfidenceThreshold, 0.9);
    });

    test('should update preferredAudioDeviceId and persist', () async {
      await settingsService.setPreferredAudioDeviceId('bluetooth-device-123');
      expect(settingsService.preferredAudioDeviceId, 'bluetooth-device-123');

      // Create a new service instance to test persistence
      final newService = SettingsService();
      await Future.delayed(Duration(milliseconds: 100)); // Allow time for loading
      expect(newService.preferredAudioDeviceId, 'bluetooth-device-123');
    });

    test('should notify listeners when voice settings change', () async {
      int notificationCount = 0;
      settingsService.addListener(() {
        notificationCount++;
      });

      await settingsService.setVoiceCommandsEnabled(true);
      expect(notificationCount, 1);

      await settingsService.setAudioCommandFeedback(false);
      expect(notificationCount, 2);

      await settingsService.setVoiceConfidenceThreshold(0.8);
      expect(notificationCount, 3);

      await settingsService.setPreferredAudioDeviceId('device-456');
      expect(notificationCount, 4);
    });
  });
}

// Fake implementation of PathProviderPlatform for testing
class FakePathProviderPlatform extends PathProviderPlatform {
  final String path;

  FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return path;
  }
}




