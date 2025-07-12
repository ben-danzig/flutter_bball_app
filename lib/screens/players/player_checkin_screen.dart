import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/player_service.dart';
import 'player_questionnaire_screen.dart';

class PlayerCheckinScreen extends StatefulWidget {
  const PlayerCheckinScreen({Key? key}) : super(key: key);

  @override
  State<PlayerCheckinScreen> createState() => _PlayerCheckinScreenState();
}

class _PlayerCheckinScreenState extends State<PlayerCheckinScreen> {
  final _playerService = PlayerService.instance;
  final TextEditingController _nameController = TextEditingController();
  List<Player> _players = [];
  Player? _selectedPlayer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);
    final players = await _playerService.getPlayers();
    setState(() {
      _players = players;
      _isLoading = false;
    });
  }

  Future<void> _addPlayer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final error = await _playerService.addPlayer(name);
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } else {
      _nameController.clear();
      await _loadPlayers();
      // Auto-select the new player
      final newPlayer = _players.firstWhere((p) => p.name == name, orElse: () => _players.last);
      setState(() {
        _selectedPlayer = newPlayer;
      });
      _goToQuestionnaire(newPlayer);
    }
  }

  void _goToQuestionnaire(Player player) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerQuestionnaireScreen(player: player),
      ),
    );
    // Reload players and reset selection after questionnaire
    await _loadPlayers();
    setState(() {
      _selectedPlayer = null;
    });
  }

  void _onSelectPlayer() {
    if (_selectedPlayer != null && !_selectedPlayer!.hasCompletedQuestionnaire) {
      _goToQuestionnaire(_selectedPlayer!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Checkin'),
        backgroundColor: const Color(0xFF1F2937),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Player',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter player name',
                          ),
                          onSubmitted: (_) => _addPlayer(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addPlayer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Select Existing Player',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedPlayer?.id,
                    decoration: const InputDecoration(
                      hintText: 'Select a player',
                    ),
                    items: _players.map((player) {
                      final completed = player.hasCompletedQuestionnaire;
                      return DropdownMenuItem<String>(
                        value: player.id,
                        enabled: !completed,
                        child: Row(
                          children: [
                            Text(player.name),
                            if (completed)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (id) {
                      final player = _players.firstWhere((p) => p.id == id);
                      setState(() {
                        _selectedPlayer = player;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedPlayer != null && !_selectedPlayer!.hasCompletedQuestionnaire
                          ? _onSelectPlayer
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Select',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Players who have already checked in are disabled in the list.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
} 