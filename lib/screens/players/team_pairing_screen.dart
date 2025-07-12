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
    // Removed focus-stealing line to allow text input
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
                // Action buttons with improved styling
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _saveTeamConfiguration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text('Save Configuration'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TeamConfigurationsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.list),
                        label: const Text('View Saved'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Available Players Section with enhanced styling
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4B5563), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          border: Border(
                            bottom: BorderSide(color: const Color(0xFF4B5563), width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.people,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Available Players (${_availablePlayers.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 100,
                        padding: const EdgeInsets.all(12.0),
                        child: _availablePlayers.isEmpty
                            ? Center(
                                child: Text(
                                  'No players available',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _availablePlayers.length,
                                itemBuilder: (context, index) {
                                  final player = _availablePlayers[index];
                                  return Draggable<Player>(
                                    data: player,
                                    feedback: Material(
                                      elevation: 8,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          player.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Container(
                                      width: 140,
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[700],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[600]!),
                                      ),
                                      child: Center(
                                        child: Text(
                                          player.name,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF374151),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF4B5563)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              player.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
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
                const SizedBox(height: 16),
                // Teams Section with enhanced styling
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF4B5563), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF374151),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            border: Border(
                              bottom: BorderSide(color: const Color(0xFF4B5563), width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.groups,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Teams',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            scrollDirection: Axis.horizontal,
                            itemCount: _teams.length,
                            itemBuilder: (context, teamIndex) {
                              return Container(
                                width: 200, // Fixed width for each team
                                margin: const EdgeInsets.only(right: 16.0),
                                child: DragTarget<Player>(
                                  onWillAccept: (data) => data != null && _teams[teamIndex].length < 2,
                                  onAccept: (player) {
                                    setState(() {
                                      _teams[teamIndex].add(player);
                                      _availablePlayers.remove(player);
                                    });
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    final isHighlighted = candidateData.isNotEmpty && _teams[teamIndex].length < 2;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: isHighlighted
                                            ? const Color(0xFF10B981).withOpacity(0.2)
                                            : const Color(0xFF374151),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isHighlighted
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF4B5563),
                                          width: isHighlighted ? 3 : 2,
                                        ),
                                        boxShadow: isHighlighted
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF10B981).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4B5563),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Team ${teamIndex + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _teams[teamIndex].length == 2
                                                        ? const Color(0xFF10B981)
                                                        : const Color(0xFF6B7280),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${_teams[teamIndex].length}/2',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12.0),
                                              child: _teams[teamIndex].isEmpty
                                                  ? Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.person_add,
                                                            color: Colors.grey[500],
                                                            size: 32,
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            'Drop players here',
                                                            style: TextStyle(
                                                              color: Colors.grey[500],
                                                              fontSize: 12,
                                                              fontStyle: FontStyle.italic,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : ListView.builder(
                                                      itemCount: _teams[teamIndex].length,
                                                      itemBuilder: (context, playerIndex) {
                                                        final player = _teams[teamIndex][playerIndex];
                                                        return Draggable<Player>(
                                                          data: player,
                                                          feedback: Material(
                                                            elevation: 8,
                                                            borderRadius: BorderRadius.circular(8),
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFEF4444),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Text(
                                                                player.name,
                                                                style: const TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          childWhenDragging: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey[700],
                                                              borderRadius: BorderRadius.circular(8),
                                                              border: Border.all(color: Colors.grey[600]!),
                                                            ),
                                                            child: Text(
                                                              player.name,
                                                              style: TextStyle(
                                                                color: Colors.grey[400],
                                                                fontStyle: FontStyle.italic,
                                                              ),
                                                            ),
                                                          ),
                                                          child: Container(
                                                            margin: const EdgeInsets.only(bottom: 8),
                                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFF4B5563),
                                                              borderRadius: BorderRadius.circular(8),
                                                              border: Border.all(color: const Color(0xFF6B7280)),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        player.name,
                                                                        style: const TextStyle(
                                                                          color: Colors.white,
                                                                          fontWeight: FontWeight.w600,
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () => _removePlayerFromTeam(teamIndex, playerIndex),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.all(4),
                                                                    decoration: BoxDecoration(
                                                                      color: const Color(0xFFEF4444),
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons.close,
                                                                      color: Colors.white,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),
                                          ),
                                        ],
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
                ),
              ],
            ),
    );
  }
} 