import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bball_app/services/settings_service.dart';

enum VoiceCommandState {
  uninitialized,
  initializing,
  ready,
  listening,
  processing,
  error,
  disabled
}

enum ListeningMode {
  none,
  wakeWord,
  command,
  alwaysListening
}

enum CommandType {
  pause,
  resume,
  next,
  previous,
  reset,
  madeShots,
  make,
  miss,
}

class CommandResult {
  final CommandType type;
  final dynamic data;
  final double confidence;
  
  CommandResult({
    required this.type,
    this.data,
    required this.confidence,
  });
}

class VoiceCommandService extends ChangeNotifier {
  final SettingsService _settingsService;
  final SpeechToText _speechToText = SpeechToText();
  
  // State management
  VoiceCommandState _state = VoiceCommandState.uninitialized;
  ListeningMode _listeningMode = ListeningMode.none;
  String _lastError = '';
  String _currentTranscript = '';
  bool _isInitialized = false;
  CommandResult? _lastRecognizedCommand;
  
  // Available locales
  List<LocaleName> _locales = [];
  String _currentLocaleId = '';
  
  // Getters
  VoiceCommandState get state => _state;
  ListeningMode get listeningMode => _listeningMode;
  String get lastError => _lastError;
  String get currentTranscript => _currentTranscript;
  bool get isListening => _speechToText.isListening;
  bool get isInitialized => _isInitialized;
  List<LocaleName> get availableLocales => _locales;
  String get currentLocaleId => _currentLocaleId;
  CommandResult? get lastRecognizedCommand => _lastRecognizedCommand;
  
  VoiceCommandService(this._settingsService) {
    _settingsService.addListener(_onSettingsChanged);
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    if (_state == VoiceCommandState.initializing) return;
    
    _setState(VoiceCommandState.initializing);
    
    try {
      // Check if voice commands are enabled
      if (!_settingsService.voiceCommandsEnabled) {
        _setState(VoiceCommandState.disabled);
        return;
      }
      
      // Check microphone permission
      final permissionStatus = await Permission.microphone.status;
      if (!permissionStatus.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          _setError('Microphone permission denied');
          return;
        }
      }
      
      // Initialize speech recognition
      final available = await _speechToText.initialize(
        onStatus: _handleStatus,
        onError: _handleError,
        debugLogging: kDebugMode,
      );
      
      if (!available) {
        _setError('Speech recognition not available on this device');
        return;
      }
      
      // Get available locales
      _locales = await _speechToText.locales();
      
      // Set current locale (default to system locale)
      final systemLocale = await _speechToText.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? 'en_US';
      
      _isInitialized = true;
      _setState(VoiceCommandState.ready);
      
      debugPrint('VoiceCommandService initialized successfully');
      debugPrint('Available locales: ${_locales.length}');
      debugPrint('Current locale: $_currentLocaleId');
      
    } catch (e) {
      _setError('Failed to initialize voice commands: $e');
    }
  }
  
  void _onSettingsChanged() {
    if (_settingsService.voiceCommandsEnabled && 
        _state == VoiceCommandState.disabled) {
      _initializeService();
    } else if (!_settingsService.voiceCommandsEnabled && 
               _state != VoiceCommandState.disabled) {
      _stopListening();
      _setState(VoiceCommandState.disabled);
    }
  }
  
  void _handleStatus(String status) {
    debugPrint('Speech recognition status: $status');
    
    if (status == 'done' || status == 'notListening') {
      if (_listeningMode == ListeningMode.command) {
        // Command mode ended, return to wake word listening if enabled
        if (_settingsService.voiceCommandsEnabled) {
          _startWakeWordListening();
        }
      }
    }
  }
  
  void _handleError(SpeechRecognitionError error) {
    debugPrint('Speech recognition error: ${error.errorMsg} - ${error.permanent}');
    
    String userFriendlyMessage;
    switch (error.errorMsg) {
      case 'error_speech_timeout':
        userFriendlyMessage = 'No speech detected. Please try again.';
        break;
      case 'error_no_match':
        userFriendlyMessage = 'Could not understand. Please speak clearly.';
        break;
      case 'error_audio':
        userFriendlyMessage = 'Audio recording error. Please check your microphone.';
        break;
      case 'error_network':
        userFriendlyMessage = 'Network error. Please check your connection.';
        break;
      case 'error_permission':
        userFriendlyMessage = 'Microphone permission denied.';
        break;
      default:
        userFriendlyMessage = 'Voice command error: ${error.errorMsg}';
    }
    
    _setError(userFriendlyMessage);
    
    // For non-permanent errors, try to recover
    if (!error.permanent && _settingsService.voiceCommandsEnabled) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_listeningMode == ListeningMode.wakeWord) {
          _startWakeWordListening();
        }
      });
    }
  }
  
  Future<void> _startWakeWordListening() async {
    if (!_isInitialized || !_settingsService.voiceCommandsEnabled) return;
    
    try {
      _listeningMode = ListeningMode.wakeWord;
      _setState(VoiceCommandState.listening);
      
      await _speechToText.listen(
        onResult: _handleWakeWordResult,
        localeId: _currentLocaleId,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation,
      );
    } catch (e) {
      _setError('Failed to start wake word listening: $e');
    }
  }
  
  void _handleWakeWordResult(SpeechRecognitionResult result) {
    _currentTranscript = result.recognizedWords.toLowerCase();
    notifyListeners();
    
    debugPrint('Wake word transcript: $_currentTranscript (final: ${result.finalResult})');
    
    // Check for wake word
    if (_currentTranscript.contains('hey coach') || 
        _currentTranscript.contains('hey coach')) {
      _stopListening();
      _startCommandListening();
    }
  }
  
  Future<void> _startCommandListening() async {
    if (!_isInitialized) return;
    
    try {
      _listeningMode = ListeningMode.command;
      _setState(VoiceCommandState.listening);
      _currentTranscript = '';
      notifyListeners();
      
      await _speechToText.listen(
        onResult: _handleCommandResult,
        localeId: _currentLocaleId,
        cancelOnError: true,
        partialResults: true,
        listenMode: ListenMode.dictation,
        listenFor: const Duration(seconds: 5),
      );
    } catch (e) {
      _setError('Failed to start command listening: $e');
    }
  }
  
  void _handleCommandResult(SpeechRecognitionResult result) {
    _currentTranscript = result.recognizedWords;
    notifyListeners();
    
    debugPrint('Command transcript: $_currentTranscript (final: ${result.finalResult})');
    
    if (result.finalResult && result.confidence >= _settingsService.voiceConfidenceThreshold) {
      _processCommand(_currentTranscript);
    }
  }
  
  void _processCommand(String command) {
    _setState(VoiceCommandState.processing);
    
    final processor = CommandProcessor(_settingsService);
    final result = processor.processCommand(command);
    
    if (result != null) {
      debugPrint('Command recognized: ${result.type} - ${result.data}');
      
      // Notify listeners about the recognized command
      _lastRecognizedCommand = result;
      notifyListeners();
      
      // Play audio feedback if enabled
      if (_settingsService.audioCommandFeedback) {
        // Audio feedback will be implemented with AudioService integration
      }
    } else {
      debugPrint('Command not recognized: $command');
      _setError('Command not recognized. Please try again.');
    }
    
    // Return to appropriate listening mode
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_settingsService.voiceCommandsEnabled) {
        _startWakeWordListening();
      } else {
        _setState(VoiceCommandState.ready);
      }
    });
  }
  
  Future<void> startListening() async {
    if (!_isInitialized || _state == VoiceCommandState.disabled) return;
    
    await _startWakeWordListening();
  }
  
  // Debug method for testing single command listening without wake word
  Future<void> startSingleCommandListening() async {
    if (!_isInitialized || _state == VoiceCommandState.disabled) return;
    
    await _startCommandListening();
  }
  
  Future<void> stopListening() async {
    await _stopListening();
    _listeningMode = ListeningMode.none;
    _setState(VoiceCommandState.ready);
  }
  
  Future<void> _stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _currentTranscript = '';
    notifyListeners();
  }
  
  void _setState(VoiceCommandState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
  
  void _setError(String error) {
    _lastError = error;
    _setState(VoiceCommandState.error);
    debugPrint('VoiceCommandService error: $error');
  }
  
  Future<void> requestMicrophonePermission() async {
    final result = await Permission.microphone.request();
    if (result.isGranted) {
      await _initializeService();
    }
  }
  
  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _stopListening();
    _speechToText.cancel();
    super.dispose();
  }
}

// Command Processor class for handling command recognition
class CommandProcessor {
  final SettingsService _settingsService;
  
  CommandProcessor(this._settingsService);
  
  CommandResult? processCommand(String command) {
    final normalizedCommand = command.toLowerCase().trim();
    
    // Check multi-word commands first (order matters!)
    
    // Previous command variations (check "go back" before "go")
    if (_matchesAny(normalizedCommand, ['go back', 'previous drill', 'previous', 'back', 'last'])) {
      return CommandResult(
        type: CommandType.previous,
        confidence: 1.0,
      );
    }
    
    // Next command variations (check "next drill" before "next")
    if (_matchesAny(normalizedCommand, ['next drill', 'next', 'skip', 'forward'])) {
      return CommandResult(
        type: CommandType.next,
        confidence: 1.0,
      );
    }
    
    // Reset command variations (check "start over" before "start")
    if (_matchesAny(normalizedCommand, ['start over', 'reset', 'restart', 'again'])) {
      return CommandResult(
        type: CommandType.reset,
        confidence: 1.0,
      );
    }
    
    // Pause command variations
    if (_matchesAny(normalizedCommand, ['pause', 'stop', 'hold', 'wait'])) {
      return CommandResult(
        type: CommandType.pause,
        confidence: 1.0,
      );
    }
    
    // Resume command variations
    if (_matchesAny(normalizedCommand, ['resume', 'continue', 'start', 'go', 'play'])) {
      return CommandResult(
        type: CommandType.resume,
        confidence: 1.0,
      );
    }
    
    // Made shots command (e.g., "made 5 shots", "made 3")
    final madePattern = RegExp(r'made\s+(\d+)\s*(shots?)?');
    final madeMatch = madePattern.firstMatch(normalizedCommand);
    if (madeMatch != null) {
      final shots = int.tryParse(madeMatch.group(1) ?? '0') ?? 0;
      return CommandResult(
        type: CommandType.madeShots,
        data: shots,
        confidence: 1.0,
      );
    }
    
    // Make command for single shot
    if (_matchesAny(normalizedCommand, ['make', 'made', 'bucket', 'in', 'yes', 'yep', 'yup', 'good'])) {
      return CommandResult(
        type: CommandType.make,
        confidence: 1.0,
      );
    }
    
    // Miss command for single shot
    if (_matchesAny(normalizedCommand, ['miss', 'missed', 'brick', 'off', 'no', 'nope', 'out'])) {
      return CommandResult(
        type: CommandType.miss,
        confidence: 1.0,
      );
    }
    
    return null;
  }
  
  bool _matchesAny(String command, List<String> variations) {
    // Sort variations by length (descending) to check longer phrases first
    final sortedVariations = List<String>.from(variations)
      ..sort((a, b) => b.length.compareTo(a.length));
    
    for (final variation in sortedVariations) {
      if (command == variation) return true;
      if (command.contains(' $variation ')) return true;
      if (command.startsWith('$variation ')) return true;
      if (command.endsWith(' $variation')) return true;
    }
    return false;
  }
}