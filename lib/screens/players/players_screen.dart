import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/player_service.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({Key? key}) : super(key: key);

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _playerService = PlayerService.instance;
  final _nameController = TextEditingController();
  List<Player> _players = [];
  bool _isLoading = true;

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
    final name = _nameController.text;
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
    }
  }

  Future<void> _removePlayer(String id) async {
    final error = await _playerService.removePlayer(id);
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } else {
      await _loadPlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
        backgroundColor: const Color(0xFF1F2937),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter player name',
                          border: OutlineInputBorder(),
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
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Registered Players:  ${_players.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _players.isEmpty
                    ? const Center(
                        child: Text(
                          'No players registered yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _players.length,
                        itemBuilder: (context, index) {
                          final player = _players[index];
                          return ListTile(
                            title: Text(player.name),
                            subtitle: Text(
                              'Registered: ${player.registeredAt.toString().split('.').first}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removePlayer(player.id),
                              tooltip: 'Remove Player',
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}