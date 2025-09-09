import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundEffectsService {
  static const String _timerEndSoundFile = 'timer-end-buzzer.mp3';
  static const String _timerTickSoundFile = 'timer-tick.mp3';
  static const String _fallbackSoundFile = 'buzzer.mp3';
  
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
    // Using tick sound for pause feedback
    await playTimerTick();
  }

  Future<void> playResumeSound() async {
    // Using tick sound for resume feedback
    await playTimerTick();
  }

  Future<void> playNextSound() async {
    // Using tick sound for next feedback
    await playTimerTick();
  }

  Future<void> playPreviousSound() async {
    // Using tick sound for previous feedback
    await playTimerTick();
  }

  Future<void> playResetSound() async {
    // Using timer complete sound for reset feedback
    await playTimerComplete();
  }

  Future<void> playCommandRecognizedSound() async {
    // Using tick sound for command recognition feedback
    await playTimerTick();
  }

  Future<void> playCommandErrorSound() async {
    // Using timer complete sound for error feedback
    await playTimerComplete();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}


