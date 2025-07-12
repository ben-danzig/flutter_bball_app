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
  const GamePrepScreen({Key? key, required this.gameNumber, required this.team1, required this.team2, required this.playerMap}) : super(key: key);

  @override
  State<GamePrepScreen> createState() => _GamePrepScreenState();
}

class _GamePrepScreenState extends State<GamePrepScreen> {
  bool _prepStarted = false;
  bool _gameStarted = false;
  bool _isPaused = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _oneMinuteCuePlayed = false;
  bool _lastTenCueStarted = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tts.stop();
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
    setState(() {
      _prepStarted = false;
      _gameStarted = true;
    });
    // Play whistle and TTS
    await _audioPlayer.play(AssetSource('referee-whistle.mp3'));
    await _tts.speak("let's hoop you dirty dirty boys");
  }

  void _onGameTick(int secondsLeft) async {
    // 1 minute left cue
    if (secondsLeft == 60 && !_oneMinuteCuePlayed) {
      _oneMinuteCuePlayed = true;
      await _audioPlayer.play(AssetSource('Peter Griffins Laugh Sound Effect.mp3'));
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
    // Play buzzer
    await _audioPlayer.play(AssetSource('buzzer.mp3'));
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            ? _buildTimerScreen(10, 'Get Ready!', _onPrepComplete)
            : _gameStarted
                ? _buildTimerScreen(300, 'Game Time!', _onGameComplete, onTick: _onGameTick)
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
    return Column(
      children: [
        // Pause button at the top
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PauseResumeButton(
                isPaused: _isPaused,
                onTogglePause: _togglePause,
                fontSize: 18,
              ),
            ],
          ),
        ),
        // Timer in the center
        Expanded(
          child: CountdownTimerWidget(
            durationSeconds: duration,
            onComplete: onComplete,
            onTick: onTick,
            isPaused: _isPaused,
            title: title,
            fontSize: 600, // Much larger font size for game prep screen
            textColor: Colors.green,
          ),
        ),
      ],
    );
  }
} 