import 'package:flutter/material.dart';
import '../../models/team_configuration.dart';
import '../../models/player.dart';
import '../../models/game_result.dart';
import '../../services/storage_service.dart';
import 'game_prep_screen.dart';

class TournamentManagerScreen extends StatefulWidget {
  final TeamConfiguration config;
  final Map<String, Player> playerMap;
  const TournamentManagerScreen({Key? key, required this.config, required this.playerMap}) : super(key: key);

  @override
  State<TournamentManagerScreen> createState() => _TournamentManagerScreenState();
}

class _TournamentManagerScreenState extends State<TournamentManagerScreen> {
  bool _useTestTimes = false;
  List<GameResult> _gameResults = [];
  final StorageService _storageService = StorageService.instance;

  @override
  void initState() {
    super.initState();
    _loadGameResults();
  }

  Future<void> _loadGameResults() async {
    final results = await _storageService.getGameResults(widget.config.name);
    setState(() {
      _gameResults = results;
    });
  }

  Future<void> _saveGameResult(GameResult result) async {
    await _storageService.saveGameResult(widget.config.name, result);
    await _loadGameResults(); // Reload to update UI
  }

  GameResult? _getGameResult(int gameNumber) {
    return _gameResults.where((result) => result.gameNumber == gameNumber).firstOrNull;
  }

  List<List<int>> _generateRoundRobin(int numTeams) {
    List<List<List<int>>> rounds = [];
    List<int> teams = List.generate(numTeams, (i) => i);
    if (numTeams < 2) return [];
    bool isOdd = numTeams % 2 != 0;
    if (isOdd) {
      teams.add(-1); // -1 means bye
    }
    int n = teams.length;
    for (int round = 0; round < n - 1; round++) {
      List<List<int>> pairs = [];
      for (int i = 0; i < n ~/ 2; i++) {
        int t1 = teams[i];
        int t2 = teams[n - 1 - i];
        if (t1 != -1 && t2 != -1) {
          pairs.add([t1, t2]);
        }
      }
      rounds.add(pairs);
      teams.insert(1, teams.removeLast());
    }
    return rounds.expand((r) => r).toList();
  }

  @override
  Widget build(BuildContext context) {
    final numTeams = widget.config.teams.length;
    final games = _generateRoundRobin(numTeams);
    
    // Define time settings based on toggle
    final prepTimeSeconds = _useTestTimes ? 3 : 10;
    final gameTimeSeconds = _useTestTimes ? 3 : 300; // 5 minutes = 300 seconds
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Manager'),
        backgroundColor: const Color(0xFF1F2937),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.config.name.isEmpty ? 'Unnamed Tournament' : widget.config.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Test times toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test Mode',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _useTestTimes 
                            ? 'Prep: 3s, Game: 3s' 
                            : 'Prep: 10s, Game: 5m',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    Switch(
                      value: _useTestTimes,
                      onChanged: (value) {
                        setState(() {
                          _useTestTimes = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text('Round Robin Schedule:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, idx) {
                  final t1 = games[idx][0];
                  final t2 = games[idx][1];
                  final team1 = widget.config.teams[t1];
                  final team2 = widget.config.teams[t2];
                  final gameNumber = idx + 1;
                  final gameResult = _getGameResult(gameNumber);
                  
                  String teamName(List<String> team) => team.map((pid) => widget.playerMap[pid]?.name ?? 'Unknown').join(' & ');
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: gameResult?.isCompleted == true ? Colors.green.shade50 : null,
                    child: ListTile(
                      leading: gameResult?.isCompleted == true 
                          ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                          : null,
                      title: Text('Game $gameNumber'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${teamName(team1)}  vs  ${teamName(team2)}'),
                          if (gameResult?.isCompleted == true && gameResult?.team1Score != null && gameResult?.team2Score != null)
                            Text(
                              '${gameResult!.team1Score} - ${gameResult.team2Score}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GamePrepScreen(
                              gameNumber: gameNumber,
                              team1: team1,
                              team2: team2,
                              playerMap: widget.playerMap,
                              prepTimeSeconds: prepTimeSeconds,
                              gameTimeSeconds: gameTimeSeconds,
                              onGameComplete: (team1Score, team2Score) async {
                                final result = GameResult(
                                  gameNumber: gameNumber,
                                  team1: team1,
                                  team2: team2,
                                  team1Score: team1Score,
                                  team2Score: team2Score,
                                  isCompleted: true,
                                  completedAt: DateTime.now(),
                                );
                                await _saveGameResult(result);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 