import 'package:flutter/material.dart';
import '../../models/team_configuration.dart';
import '../../services/team_configuration_service.dart';
import '../../services/player_service.dart';
import '../../models/player.dart';
import 'edit_team_configuration_screen.dart';

class TeamConfigurationsScreen extends StatefulWidget {
  const TeamConfigurationsScreen({Key? key}) : super(key: key);

  @override
  State<TeamConfigurationsScreen> createState() => _TeamConfigurationsScreenState();
}

class _TeamConfigurationsScreenState extends State<TeamConfigurationsScreen> {
  List<TeamConfiguration> _configs = [];
  Map<String, Player> _playerMap = {};
  final Map<String, TextEditingController> _nameControllers = {};
  bool _isLoading = true;

  @override
  void dispose() {
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    setState(() => _isLoading = true);
    final configs = await TeamConfigurationService.instance.getConfigurations();
    final allPlayers = await PlayerService.instance.getPlayers();
    final playerMap = {for (var p in allPlayers) p.id: p};
    for (final config in configs) {
      _nameControllers.putIfAbsent(config.id, () => TextEditingController(text: config.name));
      _nameControllers[config.id]!.text = config.name;
    }
    setState(() {
      _configs = configs;
      _playerMap = playerMap;
      _isLoading = false;
    });
  }

  Future<void> _updateConfigName(String id, String newName) async {
    await TeamConfigurationService.instance.updateConfigurationName(id, newName);
    await _loadConfigs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Team Configurations'),
        backgroundColor: const Color(0xFF1F2937),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _configs.isEmpty
              ? const Center(child: Text('No configurations saved yet.'))
              : ListView.builder(
                  itemCount: _configs.length,
                  itemBuilder: (context, index) {
                    final config = _configs[index];
                    final nameController = _nameControllers[config.id]!;
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Configuration Name',
                                    ),
                                    onSubmitted: (value) {
                                      _updateConfigName(config.id, value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Saved: ${config.createdAt.toLocal().toString().split(".").first}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditTeamConfigurationScreen(configId: config.id),
                                      ),
                                    );
                                  },
                                  child: const Text('Manage'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(config.teams.length, (teamIdx) {
                                  final team = config.teams[teamIdx];
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 