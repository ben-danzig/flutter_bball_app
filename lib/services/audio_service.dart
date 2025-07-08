import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await _initTts();
    }
    
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking text: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('Error pausing TTS: $e');
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}