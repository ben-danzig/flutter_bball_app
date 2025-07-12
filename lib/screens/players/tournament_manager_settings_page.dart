import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class TournamentManagerSettingsPage extends StatefulWidget {
  final String tournamentId;
  final String initialName;
  final int initialPrepTime;
  final int initialGameTime;
  const TournamentManagerSettingsPage({
    Key? key,
    required this.tournamentId,
    required this.initialName,
    required this.initialPrepTime,
    required this.initialGameTime,
  }) : super(key: key);

  @override
  State<TournamentManagerSettingsPage> createState() => _TournamentManagerSettingsPageState();
}

class _TournamentManagerSettingsPageState extends State<TournamentManagerSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _prepController;
  late TextEditingController _gameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _prepController = TextEditingController(text: widget.initialPrepTime.toString());
    _gameController = TextEditingController(text: widget.initialGameTime.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prepController.dispose();
    _gameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final name = _nameController.text.trim();
    final prep = int.tryParse(_prepController.text) ?? 10;
    final game = int.tryParse(_gameController.text) ?? 300;
    final tournamentsRef = StorageService.instance;
    await tournamentsRef.updateTournamentTimes(widget.tournamentId, prep, game);
    // Update name
    await StorageService.instance.updateTournamentName(widget.tournamentId, name);
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Settings'),
        backgroundColor: const Color(0xFF1F2937),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tournament Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prep Time (seconds)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _prepController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Game Time (seconds)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _gameController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const CircularProgressIndicator() : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 