import 'package:flutter/material.dart';
import 'package:flutter_bball_app/screens/home_screen.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SettingsService>(
      future: SettingsService.create(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => WorkoutState()),
              ChangeNotifierProvider.value(value: snapshot.data!),
            ],
            child: const BballTrainerApp(),
          );
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
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
