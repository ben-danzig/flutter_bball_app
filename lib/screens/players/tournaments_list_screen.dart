import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../models/tournament.dart';
import 'tournament_manager_screen.dart';
import '../../models/player.dart';
import '../../services/player_service.dart';

class TournamentsListScreen extends StatefulWidget {
  const TournamentsListScreen({Key? key}) : super(key: key);

  @override
  State<TournamentsListScreen> createState() => _TournamentsListScreenState();
}

class _TournamentsListScreenState extends State<TournamentsListScreen> {
  List<Tournament> _tournaments = [];
  Map<String, Player> _playerMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    setState(() => _isLoading = true);
    final rawTournaments = await StorageService.instance.getTournaments();
    final tournaments = rawTournaments.map((json) => Tournament.fromJson(json)).toList();
    final allPlayers = await PlayerService.instance.getPlayers();
    final playerMap = {for (var p in allPlayers) p.id: p};
    setState(() {
      _tournaments = tournaments;
      _playerMap = playerMap;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        backgroundColor: const Color(0xFF1F2937),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tournaments.isEmpty
              ? const Center(child: Text('No tournaments yet.'))
              : ListView.builder(
                  itemCount: _tournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = _tournaments[index];
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: Text(
                          tournament.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Started: ${tournament.createdAt.toLocal().toString().split(".").first}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TournamentManagerScreen(
                                tournamentId: tournament.id,
                                config: null, // Will load from snapshot
                                playerMap: _playerMap,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
} 