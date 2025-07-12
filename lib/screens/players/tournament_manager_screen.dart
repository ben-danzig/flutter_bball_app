import 'package:flutter/material.dart';
import '../../models/team_configuration.dart';
import '../../models/player.dart';
import '../../models/game_result.dart';
import '../../models/tournament.dart';
import '../../services/storage_service.dart';
import 'game_prep_screen.dart';
import 'tournament_manager_settings_page.dart';

class TournamentManagerScreen extends StatefulWidget {
  final String? tournamentId;
  final TeamConfiguration? config;
  final Map<String, Player> playerMap;
  const TournamentManagerScreen({Key? key, this.tournamentId, this.config, required this.playerMap}) : super(key: key);

  @override
  State<TournamentManagerScreen> createState() => _TournamentManagerScreenState();
}

class _TournamentManagerScreenState extends State<TournamentManagerScreen> {
  bool _useTestTimes = false;
  List<GameResult> _gameResults = [];
  final StorageService _storageService = StorageService.instance;
  TeamConfiguration? _config;
  String? _tournamentId;
  bool _isLoading = true;
  int _prepTimeSeconds = 10;
  int _gameTimeSeconds = 300;
  List<Map<String, dynamic>> _standings = [];

  @override
  void initState() {
    super.initState();
    _initTournament();
  }

  Future<void> _initTournament() async {
    if (widget.tournamentId != null) {
      // Load tournament and config snapshot from Firestore
      final tournaments = await _storageService.getTournaments();
      final tJson = tournaments.firstWhere((t) => t['id'] == widget.tournamentId, orElse: () => <String, dynamic>{});
      if (tJson.isNotEmpty) {
        final tournament = Tournament.fromJson(tJson);
        _tournamentId = tournament.id;
        _config = TeamConfiguration.fromJson(tournament.teamConfigSnapshot as Map<String, dynamic>, tournament.teamConfigId);
        _prepTimeSeconds = tournament.prepTimeSeconds;
        _gameTimeSeconds = tournament.gameTimeSeconds;
      }
    } else {
      // Use provided config and create a new tournament
      _config = widget.config;
      final now = DateTime.now().toLocal();
      final name = '${now.toString().replaceAll(":", "-").replaceAll(".", "-").split(" ").join("_")}_${_config!.name}';
      _tournamentId = await _storageService.createTournament(
        name: name,
        teamConfigId: _config!.id,
        teamConfigSnapshot: _config!.toJson(),
        prepTimeSeconds: _prepTimeSeconds,
        gameTimeSeconds: _gameTimeSeconds,
      );
    }
    await _loadGameResults();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadGameResults() async {
    if (_tournamentId == null) return;
    final results = await _storageService.getGameResults(_tournamentId!);
    setState(() {
      _gameResults = results;
    });
  }

  Future<void> _saveGameResult(GameResult result) async {
    if (_tournamentId == null) return;
    await _storageService.saveGameResult(_tournamentId!, result);
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

  Future<void> _updateTimes() async {
    if (_tournamentId == null) return;
    await _storageService.updateTournamentTimes(_tournamentId!, _prepTimeSeconds, _gameTimeSeconds);
    setState(() {});
  }

  bool _teamsEqual(List<String> a, List<String> b) {
    return a.length == b.length && Set<String>.from(a).containsAll(b) && Set<String>.from(b).containsAll(a);
  }

  void _calculateStandings() {
    if (_config == null) return;
    final teamIds = List.generate(_config!.teams.length, (i) => i);
    final standings = <int, Map<String, dynamic>>{};
    for (final i in teamIds) {
      standings[i] = {
        'teamIndex': i,
        'wins': 0,
        'losses': 0,
        'draws': 0,
        'pf': 0,
        'pa': 0,
      };
    }
    for (final result in _gameResults) {
      if (result.team1Score == null || result.team2Score == null) continue;
      final t1 = _config!.teams.indexWhere((team) => _teamsEqual(team, result.team1));
      final t2 = _config!.teams.indexWhere((team) => _teamsEqual(team, result.team2));
      if (t1 == -1 || t2 == -1) continue;
      standings[t1]!['pf'] += result.team1Score!;
      standings[t1]!['pa'] += result.team2Score!;
      standings[t2]!['pf'] += result.team2Score!;
      standings[t2]!['pa'] += result.team1Score!;
      if (result.team1Score! > result.team2Score!) {
        standings[t1]!['wins'] += 1;
        standings[t2]!['losses'] += 1;
      } else if (result.team2Score! > result.team1Score!) {
        standings[t2]!['wins'] += 1;
        standings[t1]!['losses'] += 1;
      } else {
        standings[t1]!['draws'] += 1;
        standings[t2]!['draws'] += 1;
      }
    }
    _standings = standings.values.toList();
    _standings.sort((a, b) {
      if (b['wins'] != a['wins']) return b['wins'] - a['wins'];
      final diffA = a['pf'] - a['pa'];
      final diffB = b['pf'] - b['pa'];
      return diffB - diffA;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _config == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    _calculateStandings();
    final numTeams = _config!.teams.length;
    final games = _generateRoundRobin(numTeams);
    
    // Define time settings based on toggle
    final prepTimeSeconds = _useTestTimes ? 3 : 10;
    final gameTimeSeconds = _useTestTimes ? 3 : 300; // 5 minutes = 300 seconds
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Manager'),
        backgroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () async {
              if (_tournamentId != null && _config != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TournamentManagerSettingsPage(
                      tournamentId: _tournamentId!,
                      initialName: _config!.name,
                      initialPrepTime: _prepTimeSeconds,
                      initialGameTime: _gameTimeSeconds,
                    ),
                  ),
                );
                // After returning, reload tournament info
                await _initTournament();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schedule (left)
            Expanded(
              child: Card(
                elevation: 4,
                color: const Color(0xFF1F2937),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _config!.name.isEmpty ? 'Unnamed Tournament' : _config!.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Schedule (click on a game to begin playing)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: games.length,
                          itemBuilder: (context, idx) {
                            final t1 = games[idx][0];
                            final t2 = games[idx][1];
                            final team1 = _config!.teams[t1];
                            final team2 = _config!.teams[t2];
                            final gameNumber = idx + 1;
                            final gameResult = _getGameResult(gameNumber);
                            
                            String teamName(List<String> team) => team.map((pid) => widget.playerMap[pid]?.name ?? 'Unknown').join(' & ');
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: gameResult?.isCompleted == true 
                                    ? const Color(0xFF1A2E1A) 
                                    : const Color(0xFF374151),
                                borderRadius: BorderRadius.circular(12),
                                border: gameResult?.isCompleted == true
                                    ? Border.all(color: Colors.green, width: 2)
                                    : Border.all(color: const Color(0xFF4B5563), width: 1),
                                boxShadow: gameResult?.isCompleted == true
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      // Green accent bar for completed games
                                      if (gameResult?.isCompleted == true)
                                        Container(
                                          width: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              bottomLeft: Radius.circular(12),
                                            ),
                                          ),
                                        ),
                                      Expanded(
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          leading: gameResult?.isCompleted == true
                                              ? Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                )
                                              : Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF6B7280),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    '$gameNumber',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                          title: Text(
                                            'Game $gameNumber',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              Text(
                                                '${teamName(team1)}  vs  ${teamName(team2)}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (gameResult?.isCompleted == true && gameResult?.team1Score != null && gameResult?.team2Score != null)
                                                Container(
                                                  margin: const EdgeInsets.only(top: 8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                                                  ),
                                                  child: Text(
                                                    '${gameResult!.team1Score} - ${gameResult.team2Score}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green,
                                                      fontSize: 20,
                                                    ),
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
                                                  prepTimeSeconds: _prepTimeSeconds,
                                                  gameTimeSeconds: _gameTimeSeconds,
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
                                      ),
                                    ],
                                  ),
                                  // Completed badge in top right
                                  if (gameResult?.isCompleted == true)
                                    Positioned(
                                      top: 12,
                                      right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          'COMPLETED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Standings (right)
            Expanded(
              child: Card(
                elevation: 4,
                color: const Color(0xFF1F2937),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.leaderboard,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tournament Standings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF374151),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DataTable(
                              headingTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              dataTextStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              columns: const [
                                DataColumn(label: Text('#', style: TextStyle(fontSize: 12))),
                                DataColumn(label: Text('Team', style: TextStyle(fontSize: 12))),
                                DataColumn(label: Text('W', style: TextStyle(fontSize: 12))),
                                DataColumn(label: Text('L', style: TextStyle(fontSize: 12))),
                                DataColumn(label: Text('D', style: TextStyle(fontSize: 12))),
                                DataColumn(label: Text('Diff', style: TextStyle(fontSize: 12))),
                                DataColumn(label: Text('Games\nLeft', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
                              ],
                              rows: List.generate(_standings.length, (i) {
                                final s = _standings[i];
                                final teamIdx = s['teamIndex'] as int;
                                final teamNames = _config!.teams[teamIdx].map((pid) => widget.playerMap[pid]?.name ?? 'Unknown').join(' & ');
                                final diff = s['pf'] - s['pa'];
                                final gamesPlayed = s['wins'] + s['losses'] + s['draws'];
                                final totalGames = _config!.teams.length - 1;
                                final gamesRemaining = totalGames - gamesPlayed;
                                
                                return DataRow(
                                  color: i == 0 ? MaterialStateProperty.all(Colors.green.withOpacity(0.1)) : null,
                                  cells: [
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: i == 0 ? Colors.green : const Color(0xFF6B7280),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '#${i + 1}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(teamNames)),
                                    DataCell(Text('${s['wins']}')),
                                    DataCell(Text('${s['losses']}')),
                                    DataCell(Text('${s['draws']}')),
                                    DataCell(
                                      Text(
                                        '$diff',
                                        style: TextStyle(
                                          color: diff > 0 ? Colors.green : diff < 0 ? Colors.red : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text('$gamesRemaining')),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tournament progress info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4B5563)),
                        ),
                        child: Builder(
                          builder: (context) {
                            final totalGames = _generateRoundRobin(_config!.teams.length).length;
                            final gamesPlayed = _gameResults.where((g) => g.team1Score != null && g.team2Score != null).length;
                            final gamesLeft = totalGames - gamesPlayed;
                            final secondsPerGame = _prepTimeSeconds + _gameTimeSeconds + 60; // 1 min break
                            final totalSeconds = gamesLeft * secondsPerGame;
                            final hours = totalSeconds ~/ 3600;
                            final minutes = (totalSeconds % 3600) ~/ 60;
                            final seconds = totalSeconds % 60;
                            String timeStr = '';
                            if (hours > 0) timeStr += '${hours}h ';
                            if (minutes > 0 || hours > 0) timeStr += '${minutes}m ';
                            timeStr += '${seconds.toString().padLeft(2, '0')}s';
                            final estFinish = DateTime.now().add(Duration(seconds: totalSeconds));
                            final hour = estFinish.hour % 12 == 0 ? 12 : estFinish.hour % 12;
                            final ampm = estFinish.hour >= 12 ? 'PM' : 'AM';
                            final finishStr = '${hour}:${estFinish.minute.toString().padLeft(2, '0')}$ampm';
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Tournament Progress',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Games Left:',
                                      style: TextStyle(color: Colors.grey[300]),
                                    ),
                                    Text(
                                      '$gamesLeft',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Est. Time Remaining:',
                                      style: TextStyle(color: Colors.grey[300]),
                                    ),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Est. Finish Time:',
                                      style: TextStyle(color: Colors.grey[300]),
                                    ),
                                    Text(
                                      finishStr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 