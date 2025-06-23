import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/workout_session.dart';

class StorageService {
  static StorageService _instance = StorageService._();
  static StorageService get instance => _instance;

  // Allow replacement for testing
  static void setInstance(StorageService instance) {
    _instance = instance;
  }

  StorageService._();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getLocalFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<void> saveSession(WorkoutSession session) async {
    final file = await _getLocalFile('session_${session.id}.json');
    final jsonString = jsonEncode(session.toJson());
    await file.writeAsString(jsonString);
  }

  Future<List<WorkoutSession>> getAllSessions() async {
    final path = await _localPath;
    final directory = Directory(path);
    final files = directory.listSync().where((item) => item.path.endsWith('.json'));

    final List<WorkoutSession> sessions = [];
    for (var file in files) {
      if (file is File) {
        final jsonString = await file.readAsString();
        final jsonMap = jsonDecode(jsonString);
        sessions.add(WorkoutSession.fromJson(jsonMap));
      }
    }
    return sessions;
  }
}
