import 'package:flutter/material.dart';
import 'package:flutter_bball_app/screens/home_screen.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_bball_app/services/player_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize PlayerService and load players
  await PlayerService.instance.loadPlayers();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WorkoutState()),
        ChangeNotifierProvider(create: (context) => SettingsService()),
      ],
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
      home: const HomeScreen(),
    );
  }
}
