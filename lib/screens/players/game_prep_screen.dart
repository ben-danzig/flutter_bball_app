import 'package:flutter/material.dart';
import '../../models/player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  int _prepSeconds = 10;
  int _gameSeconds = 300;
  Ticker? _ticker;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _oneMinuteCuePlayed = false;
  bool _lastTenCueStarted = false;

  @override
  void dispose() {
    _ticker?.dispose();
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
    _ticker?.dispose();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) async {
    if (!_gameStarted && _prepStarted) {
      final secondsLeft = 10 - elapsed.inSeconds;
      if (secondsLeft <= 0) {
        setState(() {
          _prepStarted = false;
          _gameStarted = true;
        });
        _ticker?.stop();
        _ticker?.dispose();
        _ticker = Ticker(_onGameTick)..start();
        // Play whistle and TTS
        await _audioPlayer.play(AssetSource('referee-whistle.mp3'));
        await _tts.speak("let's hoop you dirty dirty boys");
      } else {
        setState(() {
          _prepSeconds = secondsLeft;
        });
      }
    }
  }

  void _onGameTick(Duration elapsed) async {
    final secondsLeft = 300 - elapsed.inSeconds;
    if (secondsLeft <= 0) {
      setState(() {
        _gameSeconds = 0;
      });
      _ticker?.stop();
      _ticker?.dispose();
      _ticker = null;
      // Play buzzer
      await _audioPlayer.play(AssetSource('buzzer.mp3'));
    } else {
      setState(() {
        _gameSeconds = secondsLeft;
      });
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
      body: Center(
        child: _prepStarted
            ? _buildTimer(_prepSeconds, 'Get Ready!')
            : _gameStarted
                ? _buildTimer(_gameSeconds, 'Game Time!')
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

  Widget _buildTimer(int seconds, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Text(
            _formatTime(seconds),
            style: const TextStyle(fontSize: 120, color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class Ticker {
  final void Function(Duration) onTick;
  late final Stopwatch _stopwatch;
  late final Duration _interval;
  bool _running = false;
  Ticker(this.onTick, {Duration interval = const Duration(seconds: 1)}) {
    _interval = interval;
    _stopwatch = Stopwatch();
  }
  void start() {
    _running = true;
    _stopwatch.reset();
    _stopwatch.start();
    _tick();
  }
  void _tick() async {
    while (_running && _stopwatch.isRunning) {
      await Future.delayed(_interval);
      if (!_running) break;
      onTick(_stopwatch.elapsed);
    }
  }
  void stop() {
    _running = false;
    _stopwatch.stop();
  }
  void dispose() {
    stop();
  }
} 