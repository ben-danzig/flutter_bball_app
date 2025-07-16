import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_session.dart';

class WorkoutSessionService {
  static WorkoutSessionService _instance = WorkoutSessionService._();
  static WorkoutSessionService get instance => _instance;

  // Allow replacement for testing
  static void setInstance(WorkoutSessionService instance) {
    _instance = instance;
  }

  WorkoutSessionService._();

  final CollectionReference _sessionsRef = FirebaseFirestore.instance.collection('workout_sessions');

  /// Adds a new workout session
  Future<void> addSession(WorkoutSession session) async {
    await _sessionsRef.doc(session.id).set(session.toJson());
  }

  /// Returns a list of all workout sessions, ordered by completion date
  Future<List<WorkoutSession>> getAllSessions({required String deviceId, required bool loadUnknownDeviceSessions}) async {
    Query query = _sessionsRef.orderBy('completedAt', descending: true)
      .where('deviceId', isEqualTo: deviceId);
    final deviceSessionsSnapshot = await query.get();
    final deviceSessions = deviceSessionsSnapshot.docs.map((doc) => WorkoutSession.fromJson(doc.data() as Map<String, dynamic>)).toList();

    if (loadUnknownDeviceSessions) {
      final migratedQuery = _sessionsRef.orderBy('completedAt', descending: true)
        .where('deviceId', isEqualTo: 'migratedFromLocal');
      final migratedSnapshot = await migratedQuery.get();
      final migratedSessions = migratedSnapshot.docs.map((doc) => WorkoutSession.fromJson(doc.data() as Map<String, dynamic>)).toList();
      // Merge and sort
      final allSessions = [...deviceSessions, ...migratedSessions];
      allSessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return allSessions;
    } else {
      return deviceSessions;
    }
  }

  /// Updates an existing session
  Future<void> updateSession(WorkoutSession session) async {
    await _sessionsRef.doc(session.id).update(session.toJson());
  }

  /// Deletes a session by ID
  Future<void> deleteSession(String sessionId) async {
    await _sessionsRef.doc(sessionId).delete();
  }
} 