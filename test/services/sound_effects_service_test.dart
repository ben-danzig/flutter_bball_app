import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/services/sound_effects_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel audioplayersChannel = MethodChannel('xyz.luan/audioplayers');
  const MethodChannel audioplayersGlobalChannel = MethodChannel('xyz.luan/audioplayers.global');

  setUpAll(() {
    Future<dynamic> handler(MethodCall call) async {
      if (call.method == 'create') {
        return 1; // return a fake player id
      }
      return null;
    }

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioplayersChannel, handler);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioplayersGlobalChannel, (call) async => null);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioplayersChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioplayersGlobalChannel, null);
  });

  group('SoundEffectsService', () {
    test('singleton instance should be consistent', () {
      final a = SoundEffectsService();
      final b = SoundEffectsService();
      expect(identical(a, b), true);
    });

    test('playTimerComplete executes without throwing', () async {
      final service = SoundEffectsService();
      // We only assert no exceptions are thrown. Actual audio playback
      // is environment-dependent and covered by integration tests.
      await service.playTimerComplete();
    });

    test('dispose completes without throwing', () {
      final service = SoundEffectsService();
      service.dispose();
    });
  });
}


