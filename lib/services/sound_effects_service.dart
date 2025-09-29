import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundEffectsService {
  static const String _timerEndSoundFile = 'timer-end-buzzer.mp3';
  static const String _timerTickSoundFile = 'timer-tick.mp3';
  static const String _fallbackSoundFile = 'buzzer.mp3';
  static const String _whistleSoundFile = 'referee-whistle.mp3';
  
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal() {
    _preloadSounds();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _preloadSounds() async {
    try {
      // Preload the timer end sound for faster initial playback
      await _audioPlayer.setSource(AssetSource(_timerEndSoundFile));
    } catch (e) {
      debugPrint('Failed to preload $_timerEndSoundFile: $e');
      try {
        // Fallback to preloading buzzer
        await _audioPlayer.setSource(AssetSource(_fallbackSoundFile));
      } catch (e2) {
        debugPrint('Failed to preload $_fallbackSoundFile: $e2');
      }
    }
  }

  Future<void> playTimerComplete() async {
    try {
      // Always use play() to ensure sound starts from beginning
      // The preloading helps with faster initialization, but we still call play()
      await _audioPlayer
          .play(AssetSource(_timerEndSoundFile))
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Error playing $_timerEndSoundFile: $e');
      try {
        await _audioPlayer
            .play(AssetSource(_fallbackSoundFile))
            .timeout(const Duration(seconds: 2));
      } catch (e2) {
        debugPrint('Error playing fallback $_fallbackSoundFile: $e2');
      }
    }
  }

  Future<void> playTimerTick() async {
    try {
      // Play tick sound for countdown (final 3 seconds)
      await _audioPlayer
          .play(AssetSource(_timerTickSoundFile))
          .timeout(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Error playing $_timerTickSoundFile: $e');
      // No fallback for tick sound - just fail silently
    }
  }

  // Voice command feedback sounds
  Future<void> playPauseSound() async {
    try {
      // Play whistle sound for pause
      await _audioPlayer
          .play(AssetSource(_whistleSoundFile), volume: 0.5)
          .timeout(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Error playing pause sound: $e');
      await playTimerTick();
    }
  }

  Future<void> playResumeSound() async {
    // Double tick for resume
    await playTimerTick();
    await Future.delayed(const Duration(milliseconds: 100));
    await playTimerTick();
  }

  Future<void> playNextSound() async {
    // Single tick for navigation
    await playTimerTick();
  }

  Future<void> playPreviousSound() async {
    // Single tick for navigation
    await playTimerTick();
  }

  Future<void> playResetSound() async {
    // Double tick for reset
    await playTimerTick();
    await Future.delayed(const Duration(milliseconds: 150));
    await playTimerTick();
  }

  Future<void> playCommandRecognizedSound() async {
    // Quick tick for successful command recognition
    await playTimerTick();
  }

  Future<void> playCommandErrorSound() async {
    try {
      // Play buzzer for errors
      await _audioPlayer
          .play(AssetSource(_fallbackSoundFile), volume: 0.3)
          .timeout(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Error playing error sound: $e');
    }
  }

  Future<void> playWakeWordDetectedSound() async {
    // Double quick tick for wake word detection
    await playTimerTick();
    await Future.delayed(const Duration(milliseconds: 50));
    await playTimerTick();
  }

  Future<void> playListeningStartSound() async {
    // Rising tone effect with two ticks
    await playTimerTick();
  }

  Future<void> playListeningEndSound() async {
    // Single tick to indicate end of listening
    await playTimerTick();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}


