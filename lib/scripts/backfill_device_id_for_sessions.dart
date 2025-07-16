// Dart script to backfill deviceId for all workout sessions in Firestore
//
// INSTRUCTIONS:
// 1. Place this file in your lib/scripts/ directory.
// 2. Run the script using: flutter run -t lib/scripts/backfill_device_id_for_sessions.dart
// 3. After running, check your Firestore 'workout_sessions' collection to verify that all sessions have a deviceId field.
// 4. This script sets deviceId = 'migratedFromLocal' for any session missing the field.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sessionsRef = FirebaseFirestore.instance.collection('workout_sessions');
  final snapshot = await sessionsRef.get();
  int updatedCount = 0;

  for (final doc in snapshot.docs) {
    final data = doc.data();
    if (!data.containsKey('deviceId')) {
      await doc.reference.update({'deviceId': 'migratedFromLocal'});
      updatedCount++;
      print('Updated session ${doc.id} with deviceId: migratedFromLocal');
    }
  }

  print('Backfill complete. Updated $updatedCount session(s).');
} 