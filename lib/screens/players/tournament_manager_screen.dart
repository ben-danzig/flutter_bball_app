import 'package:flutter/material.dart';
import '../../models/team_configuration.dart';
import '../../models/player.dart';

class TournamentManagerScreen extends StatelessWidget {
  final TeamConfiguration config;
  final Map<String, Player> playerMap;
  const TournamentManagerScreen({Key? key, required this.config, required this.playerMap}) : super(key: key);

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
    final numTeams = config.teams.length;
    final games = _generateRoundRobin(numTeams);
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
              config.name.isEmpty ? 'Unnamed Tournament' : config.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  final team1 = config.teams[t1];
                  final team2 = config.teams[t2];
                  String teamName(List<String> team) => team.map((pid) => playerMap[pid]?.name ?? 'Unknown').join(' & ');
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text('Game ${idx + 1}'),
                      subtitle: Text('${teamName(team1)}  vs  ${teamName(team2)}'),
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