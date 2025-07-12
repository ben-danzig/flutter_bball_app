import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DanzigCupApp extends StatelessWidget {
  const DanzigCupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danzig Cup 2v2 Tournament',
      debugShowCheckedModeBanner: false,
      theme: _scoreboardTheme,
      home: const DanzigCupHome(),
    );
  }
}

class DanzigCupHome extends StatefulWidget {
  const DanzigCupHome({super.key});

  @override
  State<DanzigCupHome> createState() => _DanzigCupHomeState();
}

class _DanzigCupHomeState extends State<DanzigCupHome> {
  String _selectedScreen = 'Player Register';

  Widget _buildBody() {
    switch (_selectedScreen) {
      case 'Player Register':
        return Center(
          child: Text(
            'Player Register',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      case 'Tournament Manager':
        return Center(
          child: Text(
            'Tournament Manager',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      default:
        return const Center(child: Text('Select a screen'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danzig Cup 2v2 Tournament'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_basketball,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DANZIG CUP',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Player Register'),
              onTap: () {
                setState(() {
                  _selectedScreen = 'Player Register';
                });
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_basketball),
              title: const Text('Tournament Manager'),
              onTap: () {
                setState(() {
                  _selectedScreen = 'Tournament Manager';
                });
                Navigator.pop(context); // Close drawer
              },
            ),
            const Divider(color: Color(0xFF39FF14)),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Back to Workout App'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pop(context); // Go back to workout app
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }
}

// Scoreboard theme
final ThemeData _scoreboardTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFF111111),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF39FF14), // Neon green
    secondary: Color(0xFF181818), // Very dark gray
    surface: Color(0xFF111111),
    onPrimary: Colors.black,
    onSecondary: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF181818),
    foregroundColor: const Color(0xFF39FF14),
    titleTextStyle: GoogleFonts.orbitron(
      color: const Color(0xFF39FF14),
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: GoogleFonts.orbitronTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: const Color(0xFF39FF14),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF181818),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF39FF14)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF39FF14),
      foregroundColor: Colors.black,
      textStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
    ),
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Color(0xFF39FF14),
    textColor: Colors.white,
  ),
);