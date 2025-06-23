import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/workout_session.dart';
import 'package:flutter_bball_app/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StorageService storageService;
  late Directory tempDir;

  setUp(() async {
    storageService = StorageService.instance;
    tempDir = await Directory.systemTemp.createTemp();

    // Mock the path_provider platform channel
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });
  });

  tearDown(() async {
    // Delete the temporary directory and all its contents
    await tempDir.delete(recursive: true);
    // Clear the mock handler
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('saveSession should write a JSON file to the documents directory',
      () async {
    // ARRANGE
    final blueprint = WorkoutBlueprint(
        id: 'bp1', name: 'Test BP', drills: [], estimatedDuration: 1, objective: '');
    final session = WorkoutSession(
      id: 'session1',
      workoutBlueprint: blueprint,
      results: [],
      completedAt: DateTime.now(),
    );

    // ACT
    await storageService.saveSession(session);

    // ASSERT
    final expectedFile = File('${tempDir.path}/session_session1.json');
    expect(await expectedFile.exists(), isTrue,
        reason: 'The session file should be created.');

    final fileContent = await expectedFile.readAsString();
    final jsonMap = jsonDecode(fileContent);
    expect(jsonMap['id'], 'session1',
        reason: 'The saved JSON should have the correct session ID.');
    expect(jsonMap['workoutBlueprint']['id'], 'bp1',
        reason: 'The blueprint within the session should be saved correctly.');
  });

  test('getAllSessions should read all session files from the directory',
      () async {
    // ARRANGE
    final blueprint = WorkoutBlueprint(
        id: 'bp1', name: 'Test BP', drills: [], estimatedDuration: 1, objective: '');
    final session1 = WorkoutSession(
        id: 's1', workoutBlueprint: blueprint, results: [], completedAt: DateTime.now());
    final session2 = WorkoutSession(
        id: 's2', workoutBlueprint: blueprint, results: [], completedAt: DateTime.now());

    // Manually create some files in our temp directory
    await File('${tempDir.path}/session_s1.json')
        .writeAsString(jsonEncode(session1.toJson()));
    await File('${tempDir.path}/session_s2.json')
        .writeAsString(jsonEncode(session2.toJson()));
    await File('${tempDir.path}/not_a_session.txt').writeAsString('ignore me');

    // ACT
    final loadedSessions = await storageService.getAllSessions();

    // ASSERT
    expect(loadedSessions.length, 2,
        reason: 'Should only load the two .json session files.');
    expect(loadedSessions.any((s) => s.id == 's1'), isTrue,
        reason: 'Session 1 should be loaded.');
    expect(loadedSessions.any((s) => s.id == 's2'), isTrue,
        reason: 'Session 2 should be loaded.');
  });
}
