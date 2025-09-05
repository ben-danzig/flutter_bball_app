import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playTimerComplete() async {
    try {
      await _audioPlayer
          .play(AssetSource('timer-end.mp3'))
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Error playing timer-end.mp3: $e');
      try {
        await _audioPlayer
            .play(AssetSource('buzzer.mp3'))
            .timeout(const Duration(seconds: 2));
      } catch (e2) {
        debugPrint('Error playing fallback buzzer.mp3: $e2');
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}


