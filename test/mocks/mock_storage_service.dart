import 'package:flutter_bball_app/models/workout_session.dart';
import 'package:flutter_bball_app/services/storage_service.dart';

class FakeStorageService implements StorageService {
  WorkoutSession? lastSavedSession;
  List<WorkoutSession> sessionsToReturn = [];

  @override
  Future<void> saveSession(WorkoutSession session) async {
    lastSavedSession = session;
    return Future.value();
  }

  @override
  Future<List<WorkoutSession>> getAllSessions() async {
    return Future.value(sessionsToReturn);
  }
}
