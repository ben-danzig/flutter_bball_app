import 'package:flutter/material.dart';
import '../../models/player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../utils/widgets/countdown_timer_widget.dart';
import '../../utils/widgets/pause_resume_button.dart';

class GamePrepScreen extends StatefulWidget {
  final int gameNumber;
  final List<String> team1;
  final List<String> team2;
  final Map<String, Player> playerMap;
  final int prepTimeSeconds;
  final int gameTimeSeconds;
  final Function(int, int)? onGameComplete;
  
  const GamePrepScreen({
    Key? key, 
    required this.gameNumber, 
    required this.team1, 
    required this.team2, 
    required this.playerMap,
    this.prepTimeSeconds = 10,
    this.gameTimeSeconds = 300,
    this.onGameComplete,
  }) : super(key: key);

  @override
  State<GamePrepScreen> createState() => _GamePrepScreenState();
}

class _GamePrepScreenState extends State<GamePrepScreen> {
  bool _prepStarted = false;
  bool _gameStarted = false;
  bool _gameCompleted = false;
  bool _isPaused = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _oneMinuteCuePlayed = false;
  bool _lastTenCueStarted = false;
  
  // Score input controllers
  final TextEditingController _team1ScoreController = TextEditingController();
  final TextEditingController _team2ScoreController = TextEditingController();

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tts.stop();
    _team1ScoreController.dispose();
    _team2ScoreController.dispose();
    super.dispose();
  }

  void _startPrepTimer() {
    setState(() {
      _prepStarted = true;
      _oneMinuteCuePlayed = false;
      _lastTenCueStarted = false;
    });
  }

  void _onPrepComplete() async {
    print('Prep timer completed! Transitioning to game...');
    
    // Update state immediately
    setState(() {
      _prepStarted = false;
      _gameStarted = true;
    });
    
    print('State updated: _prepStarted=$_prepStarted, _gameStarted=$_gameStarted');
    
    // Play audio after state change
    try {
      await _audioPlayer.play(AssetSource('referee-whistle.mp3'));
      await _tts.speak("let's hoop you dirty dirty boys");
    } catch (e) {
      print('Audio error: $e');
    }
  }

  void _onGameTick(int secondsLeft) async {
    // 1 minute left cue
    if (secondsLeft == 60 && !_oneMinuteCuePlayed) {
      _oneMinuteCuePlayed = true;
      await _tts.speak('one minute! uno!');
    }
    // Last 10 seconds cue
    if (secondsLeft <= 10 && !_lastTenCueStarted) {
      _lastTenCueStarted = true;
    }
    if (_lastTenCueStarted && secondsLeft <= 10 && secondsLeft > 0) {
      await _audioPlayer.play(AssetSource('timer-end.mp3'));
    }
  }

  void _onGameComplete() async {
    print('Game timer completed!');
    setState(() {
      _gameCompleted = true;
    });
    // Play buzzer
    await _audioPlayer.play(AssetSource('buzzer.mp3'));
  }

  void _submitScores() {
    final team1Score = int.tryParse(_team1ScoreController.text) ?? 0;
    final team2Score = int.tryParse(_team2ScoreController.text) ?? 0;
    
    if (widget.onGameComplete != null) {
      widget.onGameComplete!(team1Score, team2Score);
    }
    
    // Navigate back to tournament schedule
    Navigator.of(context).pop();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building GamePrepScreen: _prepStarted=$_prepStarted, _gameStarted=$_gameStarted, _gameCompleted=$_gameCompleted');
    
    Widget teamColumn(List<String> team) {
      if (team.isEmpty) return const SizedBox();
      if (team.length == 1) {
        return Text(widget.playerMap[team[0]]?.name ?? 'Unknown', style: const TextStyle(fontSize: 22, color: Colors.white), textAlign: TextAlign.center);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.playerMap[team[0]]?.name ?? 'Unknown', style: const TextStyle(fontSize: 22, color: Colors.white), textAlign: TextAlign.center),
          const Text('&', style: TextStyle(fontSize: 22, color: Colors.white70)),
          Text(widget.playerMap[team[1]]?.name ?? 'Unknown', style: const TextStyle(fontSize: 22, color: Colors.white), textAlign: TextAlign.center),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: _prepStarted
            ? _buildTimerScreen(widget.prepTimeSeconds, 'Get Ready!', _onPrepComplete)
            : _gameStarted && !_gameCompleted
                ? _buildTimerScreen(widget.gameTimeSeconds, 'Game Time!', _onGameComplete, onTick: _onGameTick)
                : _gameCompleted
                    ? _buildGameCompletionScreen()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Game ${widget.gameNumber}',
                            style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              teamColumn(widget.team1),
                              const SizedBox(width: 32),
                              const Text('vs', style: TextStyle(fontSize: 32, color: Colors.white70, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 32),
                              teamColumn(widget.team2),
                            ],
                          ),
                          const SizedBox(height: 48),
                          const Text(
                            'Ready to start playing?',
                            style: TextStyle(fontSize: 28, color: Colors.white),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _startPrepTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                            ),
                            child: const Text(
                              "Let's Hoop!",
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildTimerScreen(int duration, String title, VoidCallback onComplete, {Function(int)? onTick}) {
    print('Building timer screen: duration=$duration, title=$title, isPaused=$_isPaused');
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF111827),
            const Color(0xFF1F2937),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header with pause button
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PauseResumeButton(
                  isPaused: _isPaused,
                  onTogglePause: _togglePause,
                  fontSize: 18,
                ),
              ],
            ),
          ),
          // Timer in the center with enhanced styling
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: CountdownTimerWidget(
                  key: ValueKey('${_prepStarted ? 'prep' : 'game'}_timer'),
                  durationSeconds: duration,
                  onComplete: onComplete,
                  onTick: onTick,
                  isPaused: _isPaused,
                  title: '',
                  fontSize: 600, // Even larger for maximum prominence
                  textColor: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCompletionScreen() {
    String team1Name = widget.team1.map((pid) => widget.playerMap[pid]?.name ?? 'Unknown').join(' & ');
    String team2Name = widget.team2.map((pid) => widget.playerMap[pid]?.name ?? 'Unknown').join(' & ');
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF111827),
            const Color(0xFF1F2937),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Game Complete!',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Score Input Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF4B5563)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Team 1 Score Input
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6B7280)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.sports_basketball,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              team1Name,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _team1ScoreController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6B7280)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6B7280)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            filled: true,
                            fillColor: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // VS indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7280),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Team 2 Score Input
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6B7280)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.sports_basketball,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              team2Name,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _team2ScoreController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6B7280)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6B7280)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            filled: true,
                            fillColor: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Submit button
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitScores,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Submit Scores',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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