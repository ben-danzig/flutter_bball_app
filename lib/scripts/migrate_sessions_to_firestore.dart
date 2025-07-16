// Dart script to migrate all local workout sessions to Firestore
//
// INSTRUCTIONS:
// 1. Place this file in your lib/scripts/ directory.
// 2. Run the script using: flutter run -t lib/scripts/migrate_sessions_to_firestore.dart
//    (or use your IDE's Run/Debug feature, setting this as the entry point)
// 3. After running, open the Firestore console and verify that all your workout sessions
//    are present and correct in the 'workout_sessions' collection.
// 4. DO NOT delete your local session files until you have verified the migration!
// 5. Once verified, you can safely remove local session files and this script.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('Starting migration of local workout sessions to Firestore...');
  await StorageService.instance.migrateSessionsToFirestore(deleteAfter: false);
  //await StorageService.instance.migrateSessionsToFirestore(deleteAfter: true);
  print('Migration complete!');
  print('Please verify your data in the Firestore console before deleting local files.');
  // Optionally, exit the app after migration
  // exit(0);
} 