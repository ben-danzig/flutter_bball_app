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

  group('CommandProcessor', () {
    late SettingsService settingsService;
    late CommandProcessor processor;
    late Directory tempDir;

    setUp(() async {
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('command_test');
      
      // Mock path provider to use our temp directory
      PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
      
      // Create services
      settingsService = SettingsService();
      processor = CommandProcessor(settingsService);
    });

    tearDown(() async {
      // Clean up temp directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('Pause Command', () {
      test('should recognize "pause"', () {
        final result = processor.processCommand('pause');
        expect(result, isNotNull);
        expect(result!.type, CommandType.pause);
      });

      test('should recognize "stop"', () {
        final result = processor.processCommand('stop');
        expect(result, isNotNull);
        expect(result!.type, CommandType.pause);
      });

      test('should recognize "hold"', () {
        final result = processor.processCommand('hold');
        expect(result, isNotNull);
        expect(result!.type, CommandType.pause);
      });

      test('should recognize "wait"', () {
        final result = processor.processCommand('wait');
        expect(result, isNotNull);
        expect(result!.type, CommandType.pause);
      });
    });

    group('Resume Command', () {
      test('should recognize "resume"', () {
        final result = processor.processCommand('resume');
        expect(result, isNotNull);
        expect(result!.type, CommandType.resume);
      });

      test('should recognize "continue"', () {
        final result = processor.processCommand('continue');
        expect(result, isNotNull);
        expect(result!.type, CommandType.resume);
      });

      test('should recognize "start"', () {
        final result = processor.processCommand('start');
        expect(result, isNotNull);
        expect(result!.type, CommandType.resume);
      });

      test('should recognize "go"', () {
        final result = processor.processCommand('go');
        expect(result, isNotNull);
        expect(result!.type, CommandType.resume);
      });

      test('should recognize "play"', () {
        final result = processor.processCommand('play');
        expect(result, isNotNull);
        expect(result!.type, CommandType.resume);
      });
    });

    group('Next Command', () {
      test('should recognize "next"', () {
        final result = processor.processCommand('next');
        expect(result, isNotNull);
        expect(result!.type, CommandType.next);
      });

      test('should recognize "next drill"', () {
        final result = processor.processCommand('next drill');
        expect(result, isNotNull);
        expect(result!.type, CommandType.next);
      });

      test('should recognize "skip"', () {
        final result = processor.processCommand('skip');
        expect(result, isNotNull);
        expect(result!.type, CommandType.next);
      });

      test('should recognize "forward"', () {
        final result = processor.processCommand('forward');
        expect(result, isNotNull);
        expect(result!.type, CommandType.next);
      });
    });

    group('Previous Command', () {
      test('should recognize "previous"', () {
        final result = processor.processCommand('previous');
        expect(result, isNotNull);
        expect(result!.type, CommandType.previous);
      });

      test('should recognize "back"', () {
        final result = processor.processCommand('back');
        expect(result, isNotNull);
        expect(result!.type, CommandType.previous);
      });

      test('should recognize "last"', () {
        final result = processor.processCommand('last');
        expect(result, isNotNull);
        expect(result!.type, CommandType.previous);
      });

      test('should recognize "previous drill"', () {
        final result = processor.processCommand('previous drill');
        expect(result, isNotNull);
        expect(result!.type, CommandType.previous);
      });

      test('should recognize "go back"', () {
        final result = processor.processCommand('go back');
        expect(result, isNotNull);
        expect(result!.type, CommandType.previous);
      });
    });

    group('Reset Command', () {
      test('should recognize "reset"', () {
        final result = processor.processCommand('reset');
        expect(result, isNotNull);
        expect(result!.type, CommandType.reset);
      });

      test('should recognize "restart"', () {
        final result = processor.processCommand('restart');
        expect(result, isNotNull);
        expect(result!.type, CommandType.reset);
      });

      test('should recognize "start over"', () {
        final result = processor.processCommand('start over');
        expect(result, isNotNull);
        expect(result!.type, CommandType.reset);
      });

      test('should recognize "again"', () {
        final result = processor.processCommand('again');
        expect(result, isNotNull);
        expect(result!.type, CommandType.reset);
      });
    });

    group('Made Shots Command', () {
      test('should recognize "made 5 shots"', () {
        final result = processor.processCommand('made 5 shots');
        expect(result, isNotNull);
        expect(result!.type, CommandType.madeShots);
        expect(result.data, 5);
      });

      test('should recognize "made 3"', () {
        final result = processor.processCommand('made 3');
        expect(result, isNotNull);
        expect(result!.type, CommandType.madeShots);
        expect(result.data, 3);
      });

      test('should recognize "made 10 shot"', () {
        final result = processor.processCommand('made 10 shot');
        expect(result, isNotNull);
        expect(result!.type, CommandType.madeShots);
        expect(result.data, 10);
      });
    });

    group('Make/Miss Commands', () {
      test('should recognize make variations', () {
        final variations = ['make', 'made', 'bucket', 'in', 'yes', 'yep', 'yup', 'good'];
        for (final word in variations) {
          final result = processor.processCommand(word);
          expect(result, isNotNull, reason: 'Failed to recognize "$word"');
          expect(result!.type, CommandType.make);
        }
      });

      test('should recognize miss variations', () {
        final variations = ['miss', 'missed', 'brick', 'off', 'no', 'nope', 'out'];
        for (final word in variations) {
          final result = processor.processCommand(word);
          expect(result, isNotNull, reason: 'Failed to recognize "$word"');
          expect(result!.type, CommandType.miss);
        }
      });
    });

    group('Edge Cases', () {
      test('should handle case insensitive commands', () {
        final result = processor.processCommand('PAUSE');
        expect(result, isNotNull);
        expect(result!.type, CommandType.pause);
      });

      test('should handle commands with extra spaces', () {
        final result = processor.processCommand('  pause  ');
        expect(result, isNotNull);
        expect(result!.type, CommandType.pause);
      });

      test('should return null for unrecognized commands', () {
        final result = processor.processCommand('random words');
        expect(result, isNull);
      });

      test('should return null for empty commands', () {
        final result = processor.processCommand('');
        expect(result, isNull);
      });

      test('should handle commands in sentences', () {
        final result = processor.processCommand('please pause the workout');
        expect(result, isNotNull);
        expect(result!.type, CommandType.pause);
      });
    });

    group('Confidence', () {
      test('should have confidence of 1.0 for recognized commands', () {
        final result = processor.processCommand('pause');
        expect(result, isNotNull);
        expect(result!.confidence, 1.0);
      });
    });
  });
}




