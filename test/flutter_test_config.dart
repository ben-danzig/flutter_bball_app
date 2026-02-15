import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger = TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger;

  // Mock path_provider methods to return a temporary directory path.
  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  final Directory tempDir = await Directory.systemTemp
      .createTemp('flutter_test_path_provider');

  Future<dynamic> pathHandler(MethodCall call) async {
    switch (call.method) {
      case 'getApplicationDocumentsDirectory':
      case 'getTemporaryDirectory':
      case 'getApplicationSupportDirectory':
      case 'getStorageDirectory':
      case 'getDownloadsDirectory':
        return tempDir.path;
    }
    return null;
  }

  messenger.setMockMethodCallHandler(pathProviderChannel, pathHandler);

  // Mock flutter_tts channel to avoid real platform code during tests.
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');
  messenger.setMockMethodCallHandler(ttsChannel, (call) async {
    // Return simple success values for all methods used by the app.
    switch (call.method) {
      case 'setLanguage':
      case 'setSpeechRate':
      case 'setVolume':
      case 'setPitch':
      case 'speak':
      case 'stop':
      case 'pause':
        return 1;
    }
    return null;
  });

  // Mock audioplayers channels.
  const MethodChannel apChannel = MethodChannel('xyz.luan/audioplayers');
  const MethodChannel apGlobalChannel =
      MethodChannel('xyz.luan/audioplayers.global');

  messenger.setMockMethodCallHandler(apChannel, (call) async {
    return 1; // return a success/int for all audioplayers calls
  });

  messenger.setMockMethodCallHandler(apGlobalChannel, (call) async {
    return 1;
  });

  await testMain();
}


