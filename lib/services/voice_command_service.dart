import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:flutter_bball_app/services/sound_effects_service.dart';

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
  final SoundEffectsService _soundService = SoundEffectsService();
  
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
  
  // Method to clear the last recognized command (prevents duplicate processing)
  void clearLastCommand() {
    _lastRecognizedCommand = null;
  }
  
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
    bool playErrorSound = false;
    switch (error.errorMsg) {
      case 'error_speech_timeout':
        userFriendlyMessage = 'No speech detected. Please try again.';
        overrideRetry = true;
        // Don't play error sound for timeout in wake word mode
        playErrorSound = _listeningMode == ListeningMode.command;
        break;
      case 'error_no_match':
        userFriendlyMessage = 'Could not understand. Please speak clearly.';
        overrideRetry = true;
        playErrorSound = true;
        break;
      case 'error_audio':
        userFriendlyMessage = 'Audio recording error. Please check your microphone.';
        overrideRetry = true;
        playErrorSound = true;
        break;
      case 'error_network':
        userFriendlyMessage = 'Network error. Please check your connection.';
        playErrorSound = true;
        break;
      case 'error_permission':
        userFriendlyMessage = 'Microphone permission denied.';
        playErrorSound = true;
        break;
      case 'error_busy':
        userFriendlyMessage = 'Speech recognition is busy. Please wait a moment.';
        overrideRetry = true;
        break;
      default:
        userFriendlyMessage = 'Voice command error: ${error.errorMsg}';
        overrideRetry = true; // Default to retry for unknown errors
        playErrorSound = true;
    }
    
    _setError(userFriendlyMessage);
    
    // Play error sound if appropriate and enabled
    if (playErrorSound && _settingsService.audioCommandFeedback) {
      _soundService.playCommandErrorSound();
    }
    
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
      _currentTranscript = '';
      _lastRecognizedCommand = null;
      notifyListeners();
      
      await _speechToText.listen(
        onResult: _handleWakeWordResult,
        localeId: _currentLocaleId,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation,
        // Use continuous listening for wake word
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: (level) {
          // Can be used for visual feedback of sound level
        },
      );
      
      // Set a safety timeout to restart wake word listening periodically
      // This helps with battery optimization and prevents getting stuck
      Future.delayed(const Duration(seconds: 60), () {
        if (_state == VoiceCommandState.listening && _listeningMode == ListeningMode.wakeWord) {
          debugPrint('Wake word listening cycle complete, restarting');
          _restartWakeWordListening();
        }
      });
    } catch (e) {
      debugPrint('Failed to start wake word listening: $e');
      _setError('Failed to start wake word listening: $e');
    }
  }
  
  Future<void> _restartWakeWordListening() async {
    if (!_settingsService.voiceCommandsEnabled || _isDebugListening) return;
    
    await _stopListening();
    _setState(VoiceCommandState.ready);
    
    // Small delay before restarting
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_settingsService.voiceCommandsEnabled && !_isDebugListening) {
      await _startWakeWordListening();
    }
  }
  
  void _handleWakeWordResult(SpeechRecognitionResult result) {
    final transcript = result.recognizedWords.toLowerCase();
    debugPrint('Wake word transcript: "$transcript" (final: ${result.finalResult}, confidence: ${result.confidence})');
    
    // Update transcript for UI feedback
    if (transcript != _currentTranscript) {
      _currentTranscript = transcript;
      notifyListeners();
    }
    
    // Check for wake word with flexible matching
    if (_containsWakeWord(transcript)) {
      debugPrint('🎯 Wake word detected!');
      
      // Play wake word detection sound if audio feedback is enabled
      if (_settingsService.audioCommandFeedback) {
        _soundService.playWakeWordDetectedSound();
      }
      
      // Stop wake word listening and switch to command mode
      _stopListening();
      _currentTranscript = ''; // Clear transcript for command mode
      notifyListeners();
      
      // Small delay to ensure clean transition
      Future.delayed(const Duration(milliseconds: 200), () {
        _startCommandListening();
      });
    }
    
    // Clear transcript if it's getting too long (prevents memory issues)
    if (transcript.length > 100) {
      _currentTranscript = '';
      notifyListeners();
    }
  }
  
  bool _containsWakeWord(String transcript) {
    // List of wake word variations
    final wakeWords = ['hey coach', 'hey coach', 'a coach', 'hey couch', 'hey code'];
    
    for (final word in wakeWords) {
      if (transcript.contains(word)) {
        return true;
      }
    }
    
    // Also check for phonetic similarity using fuzzy matching
    // This handles slight pronunciation variations
    final words = transcript.split(' ');
    for (int i = 0; i < words.length - 1; i++) {
      if (words[i] == 'hey' || words[i] == 'a' || words[i] == 'hey') {
        final nextWord = words[i + 1];
        if (_isSimilarToCoach(nextWord)) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  bool _isSimilarToCoach(String word) {
    // Simple phonetic similarity check
    final coachVariants = ['coach', 'couch', 'code', 'coaching', 'koach'];
    return coachVariants.contains(word);
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
      _lastRecognizedCommand = null;
      notifyListeners();
      
      // Play listening start sound if audio feedback is enabled
      if (_settingsService.audioCommandFeedback) {
        _soundService.playListeningStartSound();
      }
      
      await _speechToText.listen(
        onResult: _handleCommandResult,
        localeId: _currentLocaleId,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.confirmation, 
        listenFor: const Duration(seconds: 3), // 3-second timeout as per spec
        pauseFor: const Duration(seconds: 2), // Allow brief pauses
        onSoundLevelChange: (level) {
          // Can be used for visual feedback
        },
      );
      
      // Set a safety timeout with proper state transition
      Future.delayed(const Duration(seconds: 4), () {
        if (_state == VoiceCommandState.listening && _listeningMode == ListeningMode.command) {
          debugPrint('Command timeout - returning to wake word mode');
          
          // Play end sound if enabled
          if (_settingsService.audioCommandFeedback) {
            _soundService.playListeningEndSound();
          }
          
          _stopListening();
          _setState(VoiceCommandState.ready);
          
          // Return to wake word listening unless in debug mode
          if (_settingsService.voiceCommandsEnabled && !_isDebugListening) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _startWakeWordListening();
            });
          } else if (_isDebugListening) {
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
    debugPrint('=== PROCESSING COMMAND START ===');
    debugPrint('Raw command: "$command"');
    _setState(VoiceCommandState.processing);
    
    final processor = CommandProcessor(_settingsService);
    final result = processor.processCommand(command);
    
    if (result != null) {
      debugPrint('✅ Command recognized: ${result.type} - ${result.data} (confidence: ${result.confidence})');
      
      // Reset failed attempts on successful recognition
      _failedAttempts = 0;
      
      // Store the command for handling
      _lastRecognizedCommand = result;
      notifyListeners();
      
      // Play success sound if enabled
      if (_settingsService.audioCommandFeedback) {
        _soundService.playCommandRecognizedSound();
      }
      
      // Clear transcript after successful command
      _currentTranscript = '';
    } else {
      debugPrint('❌ Command not recognized: $command');
      _currentTranscript = "Didn't understand: \"$command\"";
      notifyListeners();
      
      // Play error sound if enabled
      if (_settingsService.audioCommandFeedback) {
        _soundService.playCommandErrorSound();
      }
    }
    
    debugPrint('=== PROCESSING COMMAND END ===');
    
    // Return to wake word listening after processing
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_state == VoiceCommandState.processing || _state == VoiceCommandState.error) {
        _setState(VoiceCommandState.ready);
        
        // Return to wake word listening unless in debug mode
        if (_settingsService.voiceCommandsEnabled && !_isDebugListening) {
          _startWakeWordListening();
        } else if (_isDebugListening) {
          _isDebugListening = false;
        }
      }
    });
  }
  
  Future<void> startListening() async {
    debugPrint('startListening called');
    if (!_isInitialized || _state == VoiceCommandState.disabled) {
      debugPrint('Cannot start listening - initialized: $_isInitialized, state: $_state');
      return;
    }
    
    // Clear any debug flags
    _isDebugListening = false;
    _failedAttempts = 0;
    
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
  
  // Command history for debugging
  static final List<String> _commandHistory = [];
  static const int _maxHistorySize = 50;
  
  // Command variations with fuzzy matching support
  static final Map<CommandType, List<String>> _commandVariations = {
    CommandType.previous: [
      'go back', 'previous drill', 'previous', 'back', 'last', 'last drill',
      'go to previous', 'prior', 'backward', 'backwards', 'before',
    ],
    CommandType.next: [
      'next drill', 'next', 'skip', 'forward', 'forwards', 'advance',
      'go to next', 'move on', 'continue to next',
    ],
    CommandType.reset: [
      'start over', 'reset', 'restart', 'again', 'do over', 'redo',
      'from the beginning', 'from the start', 'repeat',
    ],
    CommandType.pause: [
      'pause', 'stop', 'hold', 'wait', 'freeze', 'halt',
      'pause workout', 'stop workout', 'take a break',
    ],
    CommandType.resume: [
      'resume', 'continue', 'start', 'go', 'play', 'unpause',
      'keep going', 'resume workout', 'continue workout',
    ],
    CommandType.make: [
      'make', 'made', 'bucket', 'in', 'yes', 'yep', 'yup', 'good',
      'got it', 'swish', 'score', 'basket', 'made it',
    ],
    CommandType.miss: [
      'miss', 'missed', 'brick', 'off', 'no', 'nope', 'out',
      'missed it', 'no good', 'failed', 'fail',
    ],
  };
  
  CommandProcessor(this._settingsService) {
    debugPrint('CommandProcessor initialized');
  }
  
  CommandResult? processCommand(String command) {
    final normalizedCommand = command.toLowerCase().trim();
    debugPrint('Processing command: "$normalizedCommand"');
    
    // Add to command history
    _addToHistory(normalizedCommand);
    
    // Try exact matching first
    final exactMatch = _findExactMatch(normalizedCommand);
    if (exactMatch != null) {
      debugPrint('✅ Exact match found: ${exactMatch.type}');
      return exactMatch;
    }
    
    // Try fuzzy matching
    final fuzzyMatch = _findFuzzyMatch(normalizedCommand);
    if (fuzzyMatch != null && fuzzyMatch.confidence >= _settingsService.voiceConfidenceThreshold) {
      debugPrint('✅ Fuzzy match found: ${fuzzyMatch.type} (confidence: ${fuzzyMatch.confidence})');
      return fuzzyMatch;
    }
    
    // Check for made shots pattern
    final madeShotsResult = _checkMadeShotsPattern(normalizedCommand);
    if (madeShotsResult != null) {
      return madeShotsResult;
    }
    
    debugPrint('❌ No match found for: "$normalizedCommand"');
    return null;
  }
  
  void _addToHistory(String command) {
    _commandHistory.add('${DateTime.now().toIso8601String()}: $command');
    if (_commandHistory.length > _maxHistorySize) {
      _commandHistory.removeAt(0);
    }
  }
  
  static List<String> getCommandHistory() {
    return List.from(_commandHistory);
  }
  
  CommandResult? _findExactMatch(String command) {
    for (final entry in _commandVariations.entries) {
      if (_matchesAny(command, entry.value)) {
        return CommandResult(
          type: entry.key,
          confidence: 1.0,
        );
      }
    }
    return null;
  }
  
  CommandResult? _findFuzzyMatch(String command) {
    CommandType? bestMatch;
    double bestScore = 0.0;
    
    for (final entry in _commandVariations.entries) {
      for (final variation in entry.value) {
        final score = _calculateSimilarity(command, variation);
        if (score > bestScore) {
          bestScore = score;
          bestMatch = entry.key;
        }
      }
    }
    
    if (bestMatch != null && bestScore > 0.6) {
      return CommandResult(
        type: bestMatch,
        confidence: bestScore,
      );
    }
    
    return null;
  }
  
  CommandResult? _checkMadeShotsPattern(String command) {
    // Enhanced pattern to handle more variations
    final patterns = [
      RegExp(r'made\s+(\d+)\s*(shots?)?'),
      RegExp(r'(\d+)\s*made'),
      RegExp(r'got\s+(\d+)'),
      RegExp(r'scored\s+(\d+)'),
      RegExp(r'made\s+(\w+)\s*shots?'), // handles "made five shots"
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(command);
      if (match != null) {
        final group1 = match.group(1);
        if (group1 != null) {
          // Try to parse as number
          final shots = int.tryParse(group1) ?? _parseWordNumber(group1);
          if (shots != null && shots > 0) {
            return CommandResult(
              type: CommandType.madeShots,
              data: shots,
              confidence: 1.0,
            );
          }
        }
      }
    }
    
    return null;
  }
  
  int? _parseWordNumber(String word) {
    final wordNumbers = {
      'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
      'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
    };
    return wordNumbers[word.toLowerCase()];
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
      if (command == variation.replaceAll(' ', '')) return true; // Handle run-together words
    }
    return false;
  }
  
  double _calculateSimilarity(String s1, String s2) {
    // Simple similarity calculation based on:
    // 1. Levenshtein distance
    // 2. Common word matching
    // 3. Phonetic similarity
    
    // Normalize strings
    s1 = s1.toLowerCase().trim();
    s2 = s2.toLowerCase().trim();
    
    // Exact match
    if (s1 == s2) return 1.0;
    
    // Check if one contains the other
    if (s1.contains(s2) || s2.contains(s1)) {
      return 0.8;
    }
    
    // Word-based similarity
    final words1 = s1.split(' ').toSet();
    final words2 = s2.split(' ').toSet();
    final commonWords = words1.intersection(words2).length;
    final totalWords = words1.union(words2).length;
    
    if (totalWords > 0) {
      final wordSimilarity = commonWords / totalWords;
      if (wordSimilarity > 0.5) return wordSimilarity;
    }
    
    // Levenshtein distance for short strings
    if (s1.length < 10 && s2.length < 10) {
      final distance = _levenshteinDistance(s1, s2);
      final maxLength = s1.length > s2.length ? s1.length : s2.length;
      return 1.0 - (distance / maxLength);
    }
    
    return 0.0;
  }
  
  int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    
    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }
    
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]]
              .reduce((a, b) => a < b ? a : b);
        }
      }
    }
    
    return dp[m][n];
  }
}
