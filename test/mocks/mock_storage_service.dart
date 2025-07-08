import 'package:flutter_bball_app/models/workout_session.dart';
import 'package:flutter_bball_app/services/storage_service.dart';

class FakeStorageService implements StorageService {
  WorkoutSession? lastSavedSession;
  WorkoutSession? lastUpdatedSession;
  String? lastDeletedSessionId;
  List<WorkoutSession> sessionsToReturn = [];
  bool updateSessionCalled = false;
  bool deleteSessionCalled = false;

  @override
  Future<void> saveSession(WorkoutSession session) async {
    lastSavedSession = session;
    return Future.value();
  }

  @override
  Future<List<WorkoutSession>> getAllSessions() async {
    return Future.value(sessionsToReturn);
  }

  @override
  Future<void> updateSession(WorkoutSession session) async {
    updateSessionCalled = true;
    lastUpdatedSession = session;
    return Future.value();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    deleteSessionCalled = true;
    lastDeletedSessionId = sessionId;
    sessionsToReturn.removeWhere((s) => s.id == sessionId);
    return Future.value();
  }
}
