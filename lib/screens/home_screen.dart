import 'package:flutter/material.dart';
import 'package:flutter_bball_app/screens/library/workout_library_screen.dart';
import 'package:flutter_bball_app/screens/settings/settings_screen.dart';
import 'package:flutter_bball_app/screens/history/workout_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    WorkoutLibraryScreen(),
    WorkoutHistoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: const Color(0xFF4B5563),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFF3B82F6),
            unselectedItemColor: const Color(0xFF9CA3AF),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center, size: 24),
                activeIcon: Icon(Icons.fitness_center, size: 28),
                label: 'Workouts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history, size: 24),
                activeIcon: Icon(Icons.history, size: 28),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings, size: 24),
                activeIcon: Icon(Icons.settings, size: 28),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}