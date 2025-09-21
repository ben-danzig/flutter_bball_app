import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/screens/active/injury_log_screen.dart';
import 'package:flutter_bball_app/screens/active/widgets/make_target_timed_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/rep_based_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/timed_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/read_and_react_drill_widget.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:flutter_bball_app/services/voice_command_service.dart';
import 'package:flutter_bball_app/services/sound_effects_service.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  bool _isListening = false;
  String _transcript = '';

  @override
  Widget build(BuildContext context) {
    return Consumer3<WorkoutState, VoiceCommandService, SoundEffectsService>(
      builder: (context, workoutState, voiceService, soundService, child) {
        if (!workoutState.isWorkoutStarted) {
          return const Scaffold(
            backgroundColor: Color(0xFF111827),
            body: Center(
              child: Text(
                'No active workout.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        if (workoutState.isWorkoutComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const InjuryLogScreen()),
            );
          });
          return const Scaffold(
            backgroundColor: Color(0xFF111827),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final drill = workoutState.currentDrill!;

        // Drill widgets now handle their own complete layout via SplitPriorityLayout
        // No need for ActiveDrillLayout wrapper anymore
        return Stack(
          children: [
            _buildDrillView(drill),
            // Debug voice command button (temporary for Phase 1)
            if (voiceService.state != VoiceCommandState.disabled)
              Positioned(
                right: 20,
                bottom: 100,
                child: _buildVoiceCommandDebugButton(voiceService, workoutState, soundService),
              ),
            // Listening indicator
            if (_isListening)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: _buildListeningIndicator(),
              ),
          ],
        );
      },
    );
  }

  // This method acts as a router to select the correct UI for the drill type
  Widget _buildDrillView(Drill drill) {
    switch (drill.type) {
      case 'TIMED':
        return TimedDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      case 'REP_BASED':
        return RepBasedDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      case 'MAKE_TARGET_TIMED':
        return MakeTargetTimedDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      case 'READ_AND_REACT':
        return ReadAndReactDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      default:
        return const Scaffold(
          backgroundColor: Color(0xFF111827),
          body: Center(
            child: Text(
              'Unknown drill type. Please check your workout configuration.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
  }
  
  Widget _buildVoiceCommandDebugButton(VoiceCommandService voiceService, WorkoutState workoutState, SoundEffectsService soundService) {
    return FloatingActionButton(
      onPressed: (!_isListening) ? () async {
        setState(() {
          _isListening = true;
          _transcript = '';
        });
        
        // If not in ready state, reset the service first
        if (voiceService.state != VoiceCommandState.ready) {
          debugPrint("Voice service in state ${voiceService.state}, resetting first");
          await voiceService.resetService();
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        // Start single command listening
        await voiceService.startSingleCommandListening();
        
        // Listen for command results
        voiceService.addListener(_handleVoiceCommand);
        
        // Auto-stop after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _isListening) {
            _stopListening(voiceService);
          }
        });
      } : () async {
        debugPrint("Debug button pressed but it does nothing ,lastError=${voiceService.lastError} voiceService.state=${voiceService.state}, isListening=${_isListening}");
      },
      backgroundColor: _isListening ? const Color(0xFFef4444) : const Color(0xFF3b82f6),
      child: Icon(
        _isListening ? Icons.mic : Icons.mic_none,
        color: Colors.white,
      ),
    );
  }
  
  Widget _buildListeningIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3b82f6), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFef4444),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFef4444).withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Listening for command...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (_transcript.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"$_transcript"',
              style: const TextStyle(
                color: Color(0xFF9ca3af),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  void _handleVoiceCommand() {
    debugPrint('=== HANDLE VOICE COMMAND CALLED ===');
    final voiceService = Provider.of<VoiceCommandService>(context, listen: false);
    final workoutState = Provider.of<WorkoutState>(context, listen: false);
    final soundService = Provider.of<SoundEffectsService>(context, listen: false);
    
    debugPrint('Voice service state: ${voiceService.state}');
    debugPrint('Current transcript: "${voiceService.currentTranscript}"');
    debugPrint('Last recognized command: ${voiceService.lastRecognizedCommand?.type}');
    
    // Update transcript
    if (voiceService.currentTranscript.isNotEmpty) {
      debugPrint('Updating transcript to: "${voiceService.currentTranscript}"');
      setState(() {
        _transcript = voiceService.currentTranscript;
      });
    }
    
    // Handle recognized command
    final command = voiceService.lastRecognizedCommand;
    if (command != null) {
      debugPrint('🎯 Processing command: ${command.type} with data: ${command.data}');
      setState(() {
        _isListening = false;
      });
      _stopListening(voiceService);
      
      // Process the command
      switch (command.type) {
        case CommandType.pause:
          if (!workoutState.isPaused) {
            workoutState.togglePause();
            soundService.playPauseSound();
          }
          break;
        case CommandType.resume:
          if (workoutState.isPaused) {
            workoutState.togglePause();
            soundService.playResumeSound();
          }
          break;
        case CommandType.next:
          debugPrint('✅ Executing NEXT command');
          workoutState.nextDrill();
          soundService.playNextSound();
          break;
        case CommandType.previous:
          debugPrint('✅ Executing PREVIOUS command');
          workoutState.previousDrill();
          soundService.playPreviousSound();
          break;
        case CommandType.reset:
          debugPrint('✅ Executing RESET command');
          workoutState.resetCurrentDrill();
          soundService.playResetSound();
          break;
        case CommandType.madeShots:
          if (command.data != null && command.data is int) {
            // This will be implemented in drill-specific widgets
            debugPrint('Made ${command.data} shots');
          }
          break;
        default:
          debugPrint('❌ Unhandled command type: ${command.type}');
      }
    } else {
      debugPrint('⚠️ No command to process (command is null)');
    }
    debugPrint('=== HANDLE VOICE COMMAND END ===');
  }
  
  void _stopListening(VoiceCommandService voiceService) {
    if (mounted) {
      setState(() {
        _isListening = false;
        _transcript = '';
      });
    }
    voiceService.removeListener(_handleVoiceCommand);
    voiceService.stopListening(); // Ensure voice service stops
  }
}
