import 'package:flutter/material.dart';
import '../../models/team_configuration.dart';
import '../../services/team_configuration_service.dart';
import '../../services/player_service.dart';
import '../../models/player.dart';
import 'tournament_manager_screen.dart';

class EditTeamConfigurationScreen extends StatefulWidget {
  final String configId;
  const EditTeamConfigurationScreen({Key? key, required this.configId}) : super(key: key);

  @override
  State<EditTeamConfigurationScreen> createState() => _EditTeamConfigurationScreenState();
}

class _EditTeamConfigurationScreenState extends State<EditTeamConfigurationScreen> {
  TeamConfiguration? _config;
  Map<String, Player> _playerMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    final configs = await TeamConfigurationService.instance.getConfigurations();
    final config = configs.firstWhere((c) => c.id == widget.configId);
    final allPlayers = await PlayerService.instance.getPlayers();
    final playerMap = {for (var p in allPlayers) p.id: p};
    setState(() {
      _config = config;
      _playerMap = playerMap;
      _isLoading = false;
    });
  }

  void _beginTournament() {
    if (_config == null) return;
    // Remove empty teams before starting the tournament
    final nonEmptyTeams = _config!.teams.where((team) => team.isNotEmpty).toList();
    final cleanedConfig = TeamConfiguration(
      id: _config!.id,
      name: _config!.name,
      createdAt: _config!.createdAt,
      teams: nonEmptyTeams,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentManagerScreen(config: cleanedConfig, playerMap: _playerMap),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Team Configuration'),
        backgroundColor: const Color(0xFF1F2937),
      ),
      body: _isLoading || _config == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _config!.name.isEmpty ? 'Unnamed Configuration' : _config!.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: _beginTournament,
                        child: const Text('Begin Tournament'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_config!.teams.length, (teamIdx) {
                        final team = _config!.teams[teamIdx];
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Team ${teamIdx + 1}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (team.isEmpty)
                                const Text('No players', style: TextStyle(color: Colors.grey))
                              else
                                ...team.map((pid) => Text(
                                      _playerMap[pid]?.name ?? 'Unknown',
                                      style: const TextStyle(color: Colors.white),
                                    )),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 