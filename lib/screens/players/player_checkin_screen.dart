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
  List<Player> _players = [];
  Player? _selectedPlayer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);
    final players = await _playerService.getPlayers();
    setState(() {
      _players = players;
      _isLoading = false;
    });
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to the Tournament!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Select your name from the list below, then fill out the B.R.O. (Basketball Roster Optimizer) assessment to get paired by our all-powerful algorithm. You\'ll be all set!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Who are you?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedPlayer?.id,
                    decoration: const InputDecoration(
                      hintText: 'Select your name',
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
                        'Start B.R.O. Assessment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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