import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_session.dart';
import '../models/game_result.dart';

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
        // Skip settings file
        if (file.path.contains('settings.json')) {
          continue;
        }
        try {
          final jsonString = await file.readAsString();
          final jsonMap = jsonDecode(jsonString);
          // Defensive: check for required keys
          if (jsonMap is Map<String, dynamic> &&
              jsonMap.containsKey('id') &&
              jsonMap.containsKey('workoutBlueprint') &&
              jsonMap.containsKey('results') &&
              jsonMap.containsKey('completedAt')) {
            sessions.add(WorkoutSession.fromJson(jsonMap));
          } else {
            // Log and skip malformed session
            print('Skipped malformed session file: ${file.path}');
          }
        } catch (e) {
          // Log and skip on error
          print('Error reading session file ${file.path}: $e');
          final fileContents = await file.readAsString();
          print('File had contents: ${fileContents}');
        }
      }
    }
    return sessions;
  }

  Future<void> deleteSession(String sessionId) async {
    final file = await _getLocalFile('session_$sessionId.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> updateSession(WorkoutSession session) async {
    final file = await _getLocalFile('session_${session.id}.json');
    final jsonString = jsonEncode(session.toJson());
    await file.writeAsString(jsonString);
  }

  // Game Results Methods using Firestore
  Future<void> saveGameResult(String tournamentName, GameResult result) async {
    final CollectionReference gameResultsRef = FirebaseFirestore.instance.collection('game_results');
    
    // Create a unique document ID for this game result
    final String documentId = '${tournamentName}_game_${result.gameNumber}';
    
    await gameResultsRef.doc(documentId).set(result.toJson());
  }

  Future<List<GameResult>> getGameResults(String tournamentName) async {
    try {
      final CollectionReference gameResultsRef = FirebaseFirestore.instance.collection('game_results');
      
      // Query for all game results for this tournament
      final QuerySnapshot snapshot = await gameResultsRef
          .where('gameNumber', isGreaterThan: 0) // This will get all game results
          .get();
      
      final List<GameResult> results = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Only include results for this tournament
        if (data.containsKey('team1') && data.containsKey('team2')) {
          // Check if this result belongs to our tournament by looking at the document ID
          if (doc.id.startsWith('${tournamentName}_game_')) {
            results.add(GameResult.fromJson(data));
          }
        }
      }
      
      // Sort by game number
      results.sort((a, b) => a.gameNumber.compareTo(b.gameNumber));
      
      return results;
    } catch (e) {
      print('Error reading game results from Firestore: $e');
      return [];
    }
  }
}
