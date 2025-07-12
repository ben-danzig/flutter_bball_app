import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/player.dart';
import '../../services/player_service.dart';
import '../../models/team_configuration.dart';
import '../../services/team_configuration_service.dart';
import 'team_configurations_screen.dart';
import 'tournaments_list_screen.dart';

class TeamPairingScreen extends StatefulWidget {
  const TeamPairingScreen({Key? key}) : super(key: key);

  @override
  State<TeamPairingScreen> createState() => _TeamPairingScreenState();
}

class _TeamPairingScreenState extends State<TeamPairingScreen> {
  final _playerService = PlayerService.instance;
  List<Player> _availablePlayers = [];
  List<List<Player>> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _teams = List.generate(8, (_) => []); // Only initialize here
    _loadPlayers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Focus the widget to receive keyboard events
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);
    final players = await _playerService.getPlayers();
    setState(() {
      _availablePlayers = List.from(players);
      _isLoading = false;
    });
  }

  void _removePlayerFromTeam(int teamIndex, int playerIndex) {
    setState(() {
      final player = _teams[teamIndex][playerIndex];
      _availablePlayers.add(player);
      _teams[teamIndex].removeAt(playerIndex);
    });
  }

  Future<void> _saveTeamConfiguration() async {
    final config = TeamConfiguration(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      createdAt: DateTime.now(),
      teams: _teams.map((team) => team.map((p) => p.id).toList()).toList(),
    );
    await TeamConfigurationService.instance.saveConfiguration(config);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team configuration saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Pairing'),
        backgroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Tournaments',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TournamentsListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _saveTeamConfiguration,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Team Configuration'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeamConfigurationsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('View Saved Configurations'),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                // Available Players Section
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF374151),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Available Players (${_availablePlayers.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availablePlayers.length,
                          itemBuilder: (context, index) {
                            final player = _availablePlayers[index];
                            return Draggable<Player>(
                              data: player,
                              feedback: Material(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    player.name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(
                                width: 120,
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Container(
                                width: 120,
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF374151),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    player.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Teams Section
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: const BoxDecoration(
                            color: Color(0xFF059669),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Teams',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(_teams.length, (teamIndex) {
                                final team = _teams[teamIndex];
                                return DragTarget<Player>(
                                  onWillAccept: (player) => team.length < 2,
                                  onAccept: (player) {
                                    setState(() {
                                      team.add(player);
                                      _availablePlayers.removeWhere((p) => p.id == player.id);
                                    });
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return Container(
                                      width: 220,
                                      margin: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1F2937),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: candidateData.isNotEmpty ? Colors.green : Colors.orange,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              'Team ${teamIndex + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (team.isEmpty)
                                            const Expanded(
                                              child: Center(
                                                child: Text(
                                                  'No players yet',
                                                  style: TextStyle(color: Colors.grey),
                                                ),
                                              ),
                                            )
                                          else
                                            ...team.map((player) => ListTile(
                                                  title: Text(
                                                    player.name,
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                  trailing: IconButton(
                                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                                    onPressed: () => _removePlayerFromTeam(teamIndex, team.indexOf(player)),
                                                    tooltip: 'Remove player',
                                                  ),
                                                )),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 