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
  bool _isDebugListening = false; // Track if listening was started via debug button
  int _failedAttempts = 0; // Track consecutive failed recognition attempts
  
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
    debugPrint('VoiceCommandService constructor called with _settingsService: $_settingsService');
    _settingsService.addListener(_onSettingsChanged);
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    debugPrint('_initializeService called');
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
    debugPrint('_onSettingsChanged called');
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
    debugPrint('_handleStatus called with status: $status');
    debugPrint('Speech recognition status: $status');
    
    if (status == 'done' || status == 'notListening') {
      if (_listeningMode == ListeningMode.command) {
        // Command mode ended, return to wake word listening if enabled
        // BUT only if not in debug mode
        if (_settingsService.voiceCommandsEnabled && !_isDebugListening) {
          _startWakeWordListening();
        }
      }
    }
  }
  
  void _handleError(SpeechRecognitionError error) {
    debugPrint('_handleError called with error: $error');
    debugPrint('Speech recognition error: ${error.errorMsg} - is this a permanent error? ${error.permanent}');
    
    // Increment failed attempts counter
    _failedAttempts++;
    debugPrint('Failed attempts: $_failedAttempts');
    
    // If we've had too many failures, try reinitializing
    if (_failedAttempts >= 3) {
      debugPrint('Too many failed attempts, attempting to reinitialize');
      _failedAttempts = 0;
      Future.delayed(const Duration(seconds: 1), () async {
        await _resetFromError();
      });
    }
    
    String userFriendlyMessage;
    bool overrideRetry = false;
    switch (error.errorMsg) {
      case 'error_speech_timeout':
        userFriendlyMessage = 'No speech detected. Please try again.';
        overrideRetry = true;
        break;
      case 'error_no_match':
        userFriendlyMessage = 'Could not understand. Please speak clearly.';
        overrideRetry = true;
        break;
      case 'error_audio':
        userFriendlyMessage = 'Audio recording error. Please check your microphone.';
        overrideRetry = true;
        break;
      case 'error_network':
        userFriendlyMessage = 'Network error. Please check your connection.';
        break;
      case 'error_permission':
        userFriendlyMessage = 'Microphone permission denied.';
        break;
      case 'error_busy':
        userFriendlyMessage = 'Speech recognition is busy. Please wait a moment.';
        overrideRetry = true;
        break;
      default:
        userFriendlyMessage = 'Voice command error: ${error.errorMsg}';
        overrideRetry = true; // Default to retry for unknown errors
    }
    
    _setError(userFriendlyMessage);
    
    // For non-permanent errors or retryable errors, try to recover
    if ((!error.permanent || overrideRetry) && _settingsService.voiceCommandsEnabled && !_isDebugListening) {
      debugPrint('The error was non-permanent or retryable, so we will try to start listening again. _listeningMode=${_listeningMode}');
      
      // Stop any current listening and reset state before retrying
      _stopListening();
      _setState(VoiceCommandState.ready);
      
      Future.delayed(const Duration(seconds: 2), () {
        if (_settingsService.voiceCommandsEnabled && _state == VoiceCommandState.ready && !_isDebugListening) {
          if (_listeningMode == ListeningMode.wakeWord) {
            _startWakeWordListening();
          } else if (_listeningMode == ListeningMode.command) {
            _startCommandListening();
          }
        }
      });
    } else if (_isDebugListening) {
      // In debug mode, just reset to ready state
      debugPrint('Error in debug mode, resetting to ready state');
      _stopListening();
      _setState(VoiceCommandState.ready);
    }
  }
  
  Future<void> _startWakeWordListening() async {
    debugPrint('_startWakeWordListening called');
    if (!_isInitialized || !_settingsService.voiceCommandsEnabled) return;
    
    // If already listening, stop first
    if (_speechToText.isListening) {
      debugPrint('Already listening, stopping first');
      await _speechToText.stop();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
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
      
      // Set a safety timeout to prevent getting stuck in listening state
      Future.delayed(const Duration(seconds: 30), () {
        if (_state == VoiceCommandState.listening && _listeningMode == ListeningMode.wakeWord) {
          debugPrint('Wake word listening timeout reached, restarting');
          _stopListening();
          _setState(VoiceCommandState.ready);
          // Restart wake word listening after timeout, but not in debug mode
          if (_settingsService.voiceCommandsEnabled && !_isDebugListening) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _startWakeWordListening();
            });
          }
        }
      });
    } catch (e) {
      debugPrint('Failed to start wake word listening: $e');
      _setError('Failed to start wake word listening: $e');
    }
  }
  
  void _handleWakeWordResult(SpeechRecognitionResult result) {
    debugPrint('_handleWakeWordResult called with result: $result');
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
    debugPrint('_startCommandListening called');
    if (!_isInitialized) return;
    
    // If already listening, stop first
    if (_speechToText.isListening) {
      debugPrint('Already listening, stopping first');
      await _speechToText.stop();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    try {
      _listeningMode = ListeningMode.command;
      _setState(VoiceCommandState.listening);
      _currentTranscript = '';
      notifyListeners();
      
      await _speechToText.listen(
        onResult: _handleCommandResult,
        localeId: _currentLocaleId,
        cancelOnError: false, // Don't cancel on error to be more resilient
        listenOptions: SpeechListenOptions(listenMode: ListenMode.confirmation, partialResults: true), 
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 3), // Allow pauses in speech
      );
      
      // Set a safety timeout to prevent getting stuck in listening state
      Future.delayed(const Duration(seconds: 8), () {
        if (_state == VoiceCommandState.listening && _listeningMode == ListeningMode.command) {
          debugPrint('Command listening timeout reached, stopping');
          _stopListening();
          _setState(VoiceCommandState.ready);
          // Reset debug flag on timeout
          if (_isDebugListening) {
            _isDebugListening = false;
          }
        }
      });
    } catch (e) {
      debugPrint('Failed to start command listening: $e');
      _setError('Failed to start command listening: $e');
    }
  }
  
  void _handleCommandResult(SpeechRecognitionResult result) {
    debugPrint('_handleCommandResult called with result: $result');
    _currentTranscript = result.recognizedWords;
    notifyListeners();
    
    debugPrint('Command transcript: $_currentTranscript (final: ${result.finalResult})');
    debugPrint('Command confidence: ${result.confidence}, threshold: ${_settingsService.voiceConfidenceThreshold}');
    debugPrint('Current listening mode: $_listeningMode');
    
    // Process command if it's final and either:
    // 1. Confidence is above threshold
    // 2. Confidence is -1.0 but we have recognized words (Android sometimes returns -1.0)
    if (result.finalResult) {
      if (result.confidence >= _settingsService.voiceConfidenceThreshold ||
          (result.confidence == -1.0 && _currentTranscript.isNotEmpty)) {
        debugPrint('Processing command: $_currentTranscript');
        _processCommand(_currentTranscript);
      } else {
        debugPrint('Command not processed - confidence too low: ${result.confidence}');
        // Still try to process if we have a transcript
        if (_currentTranscript.isNotEmpty) {
          debugPrint('Attempting to process low-confidence command: $_currentTranscript');
          _processCommand(_currentTranscript);
        }
      }
    } else {
      debugPrint('Command not processed - not final result');
    }
  }
  
  void _processCommand(String command) {
    debugPrint('_processCommand called with command: $command');
    debugPrint('=== PROCESSING COMMAND START ===');
    debugPrint('Raw command: "$command"');
    _setState(VoiceCommandState.processing);
    
    final processor = CommandProcessor(_settingsService);
    final result = processor.processCommand(command);
    
    if (result != null) {
      debugPrint('✅ Command recognized: ${result.type} - ${result.data} (confidence: ${result.confidence})');
      
      // Reset failed attempts on successful recognition
      _failedAttempts = 0;
      
      // Notify listeners about the recognized command
      _lastRecognizedCommand = result;
      debugPrint('Set lastRecognizedCommand to: ${_lastRecognizedCommand?.type}');
      notifyListeners();
      debugPrint('Notified listeners about command');
      
      // Play audio feedback if enabled
      if (_settingsService.audioCommandFeedback) {
        // Audio feedback will be implemented with AudioService integration
      }
    } else {
      debugPrint('❌ Command not recognized: $command');
      _setError('Command not recognized. Please try again.');
    }
    
    debugPrint('=== PROCESSING COMMAND END ===');
    
    // Return to appropriate listening mode
    Future.delayed(const Duration(milliseconds: 500), () {
      // Check if we're still in a processing/error state before changing
      if (_state == VoiceCommandState.processing || _state == VoiceCommandState.error) {
        // Only start wake word listening if not in debug mode
        if (_settingsService.voiceCommandsEnabled && !_isDebugListening) {
          _startWakeWordListening();
        } else {
          // In debug mode, just return to ready state
          _setState(VoiceCommandState.ready);
        }
      }
    });
  }
  
  Future<void> startListening() async {
    debugPrint('startListening called');
    if (!_isInitialized || _state == VoiceCommandState.disabled) return;
    
    await _startWakeWordListening();
  }
  
  // Debug method for testing single command listening without wake word
  Future<void> startSingleCommandListening() async {
    debugPrint('startSingleCommandListening called');
    debugPrint('=== START SINGLE COMMAND LISTENING ===');
    debugPrint('Initialized: $_isInitialized, State: $_state');
    if (!_isInitialized || _state == VoiceCommandState.disabled) return;
    
    // Mark this as debug listening to prevent auto wake word listening
    _isDebugListening = true;
    
    // Reset failed attempts counter for fresh start
    _failedAttempts = 0;
    
    // If we're in error state, reset and try again
    if (_state == VoiceCommandState.error) {
      debugPrint('Resetting from error state before starting command listening');
      await _resetFromError();
    }
    
    await _startCommandListening();
  }
  
  // Method to reset from error state
  Future<void> _resetFromError() async {
    debugPrint('_resetFromError called');
    await _stopListening();
    
    // Cancel any pending speech recognition operations
    try {
      await _speechToText.cancel();
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('Error canceling speech recognition: $e');
    }
    
    // Reset the speech recognition instance to ensure clean state
    try {
      await _speechToText.stop();
      await Future.delayed(const Duration(milliseconds: 500));
      // Re-initialize to ensure fresh state
      if (_isInitialized) {
        await _speechToText.initialize(
          onStatus: _handleStatus,
          onError: _handleError,
          debugLogging: kDebugMode,
        );
      }
    } catch (e) {
      debugPrint('Error resetting speech recognition: $e');
    }
    
    _lastError = '';
    _listeningMode = ListeningMode.none;
    _currentTranscript = '';
    _isDebugListening = false; // Reset debug flag
    _setState(VoiceCommandState.ready);
    
    // Small delay to ensure clean state
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  // Public method to reset service state (useful for debugging)
  Future<void> resetService() async {
    debugPrint('resetService called');
    await _resetFromError();
  }
  
  Future<void> stopListening() async {
    debugPrint('stopListening called');
    await _stopListening();
    _listeningMode = ListeningMode.none;
    _isDebugListening = false; // Reset debug flag when stopping
    _setState(VoiceCommandState.ready);
  }
  
  Future<void> _stopListening() async {
    debugPrint('_stopListening called');
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
        // Give it a moment to fully stop
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
    }
    _currentTranscript = '';
    notifyListeners();
  }
  
  void _setState(VoiceCommandState newState) {
    debugPrint('_setState called with newState: $newState');
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
  
  void _setError(String error) {
    debugPrint('_setError called with error: $error');
    _lastError = error;
    _setState(VoiceCommandState.error);
    debugPrint('VoiceCommandService error: $error');
  }
  
  Future<void> requestMicrophonePermission() async {
    debugPrint('requestMicrophonePermission called');
    final result = await Permission.microphone.request();
    if (result.isGranted) {
      await _initializeService();
    }
  }
  
  @override
  void dispose() {
    debugPrint('dispose called');
    _settingsService.removeListener(_onSettingsChanged);
    _stopListening();
    _speechToText.cancel();
    super.dispose();
  }
}

// Command Processor class for handling command recognition
class CommandProcessor {
  final SettingsService _settingsService;
  
  CommandProcessor(this._settingsService) {
    debugPrint('CommandProcessor constructor called with _settingsService: $_settingsService');
  }
  
  CommandResult? processCommand(String command) {
    debugPrint('processCommand called with command: $command');
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
    debugPrint('_matchesAny called with command: $command, variations: $variations');
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
