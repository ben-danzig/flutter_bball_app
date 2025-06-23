import 'package:flutter/material.dart';
import 'package:flutter_bball_app/screens/library/workout_library_screen.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WorkoutState(),
      child: const BballTrainerApp(),
    ),
  );
}

class BballTrainerApp extends StatelessWidget {
  const BballTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basketball Trainer',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111827),
      ),
      // Change the home property to our new screen
      home: const WorkoutLibraryScreen(),
    );
  }
}
