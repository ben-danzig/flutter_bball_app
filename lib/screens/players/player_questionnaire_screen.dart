import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/player_service.dart';

class PlayerQuestionnaireScreen extends StatefulWidget {
  final Player player;

  const PlayerQuestionnaireScreen({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<PlayerQuestionnaireScreen> createState() => _PlayerQuestionnaireScreenState();
}

class _PlayerQuestionnaireScreenState extends State<PlayerQuestionnaireScreen> {
  final _playerService = PlayerService.instance;
  
  // Form controllers
  String? _selectedPartnerId;
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();
  String? _highestLevelPlayed;
  String? _layupAbility;
  String? _lastTimePlayed;
  final TextEditingController _additionalNotesController = TextEditingController();
  
  List<Player> _availablePlayers = [];
  bool _isLoading = false;

  // Question options
  static const List<String> _highestLevelOptions = [
    'just playing some bball outside of the school',
    'HS',
    'College',
    'Pro',
  ];

  static const List<String> _layupAbilityOptions = [
    'yeah definitely',
    'i think so',
    'dont count on me',
  ];

  static const List<String> _lastTimePlayedOptions = [
    'within the last week',
    'within the last few months',
    'man it\'s been years',
    'what the hell is that orange crap??',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailablePlayers();
    _prefillExistingData();
  }

  @override
  void dispose() {
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailablePlayers() async {
    final players = await _playerService.getPlayers();
    setState(() {
      _availablePlayers = players.where((p) => p.id != widget.player.id).toList();
    });
  }

  void _prefillExistingData() {
    final player = widget.player;
    if (player.preferredPartnerId != null) {
      _selectedPartnerId = player.preferredPartnerId;
    }
    if (player.heightFeet != null) {
      _heightFeetController.text = player.heightFeet.toString();
    }
    if (player.heightInches != null) {
      _heightInchesController.text = player.heightInches.toString();
    }
    _highestLevelPlayed = player.highestLevelPlayed;
    _layupAbility = player.layupAbility;
    _lastTimePlayed = player.lastTimePlayed;
    if (player.additionalNotes != null) {
      _additionalNotesController.text = player.additionalNotes!;
    }
  }

  Future<void> _submitQuestionnaire() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    final error = await _playerService.updatePlayerQuestionnaire(
      widget.player.id,
      preferredPartnerId: _selectedPartnerId,
      heightFeet: int.tryParse(_heightFeetController.text),
      heightInches: int.tryParse(_heightInchesController.text),
      highestLevelPlayed: _highestLevelPlayed,
      layupAbility: _layupAbility,
      lastTimePlayed: _lastTimePlayed,
      additionalNotes: _additionalNotesController.text.trim().isEmpty 
          ? null 
          : _additionalNotesController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // Show confirmation dialog
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Questionnaire Submitted'),
          content: const Text(
            'Thank you for filling out the questionnaire. You will be paired up by the all-powerful algorithm. Stay tuned for the team pairing announcements.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool _validateForm() {
    if (_heightFeetController.text.isEmpty || _heightInchesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your height'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_highestLevelPlayed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the highest level of basketball you\'ve played'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_layupAbility == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your layup ability'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_lastTimePlayed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select when you last played basketball'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Questionnaire'),
        backgroundColor: const Color(0xFF1F2937),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
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
                    'BRO System',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Basketball Roster Optimizer - We\'re collecting player information to ensure fair team pairing for the tournament.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Question 1: Preferred Partner
            _buildQuestion(
              'Is there someone in particular you\'d like to be paired with?',
              _buildPartnerDropdown(),
            ),

            // Question 2: Height
            _buildQuestion(
              'What is your height?',
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightFeetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Feet',
                        suffixText: 'ft',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _heightInchesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Inches',
                        suffixText: 'in',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Question 3: Highest Level Played
            _buildQuestion(
              'What\'s the highest level of basketball you\'ve played?',
              _buildDropdown(
                value: _highestLevelPlayed,
                items: _highestLevelOptions,
                onChanged: (value) => setState(() => _highestLevelPlayed = value),
              ),
            ),

            // Question 4: Layup Ability
            _buildQuestion(
              'Can you consistently make an open layup?',
              _buildDropdown(
                value: _layupAbility,
                items: _layupAbilityOptions,
                onChanged: (value) => setState(() => _layupAbility = value),
              ),
            ),

            // Question 5: Last Time Played
            _buildQuestion(
              'When was the last time you touched a basketball?',
              _buildDropdown(
                value: _lastTimePlayed,
                items: _lastTimePlayedOptions,
                onChanged: (value) => setState(() => _lastTimePlayed = value),
              ),
            ),

            // Question 6: Additional Notes
            _buildQuestion(
              'Any additional pleas you\'d like to make to the algorithm?',
              TextField(
                controller: _additionalNotesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Optional - tell us anything else...',
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitQuestionnaire,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Questionnaire',
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

  Widget _buildQuestion(String question, Widget input) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        input,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPartnerDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPartnerId,
      decoration: const InputDecoration(
        hintText: 'Select a player (optional)',
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('No preference'),
        ),
        ..._availablePlayers.map((player) => DropdownMenuItem<String>(
          value: player.id,
          child: Text(player.name),
        )),
      ],
      onChanged: (value) => setState(() => _selectedPartnerId = value),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        hintText: 'Select an option',
      ),
      items: items.map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
    );
  }
} 