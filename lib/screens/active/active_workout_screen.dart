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
import 'package:flutter_bball_app/services/audio_service.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    // Start wake word listening when screen opens if voice commands are enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voiceService = Provider.of<VoiceCommandService>(context, listen: false);
      if (voiceService.state == VoiceCommandState.ready) {
        voiceService.startListening();
      }
    });
  }

  @override
  void dispose() {
    // Stop listening when leaving the screen
    final voiceService = Provider.of<VoiceCommandService>(context, listen: false);
    voiceService.stopListening();
    super.dispose();
  }

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

        // Listen for voice commands and update UI
        if (voiceService.lastRecognizedCommand != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleVoiceCommand(voiceService, workoutState, soundService);
          });
        }

        // Drill widgets now handle their own complete layout via SplitPriorityLayout
        // No need for ActiveDrillLayout wrapper anymore
        return Stack(
          children: [
            _buildDrillView(drill),
            // Voice command status indicator
            if (voiceService.state != VoiceCommandState.disabled)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: _buildVoiceStatusIndicator(voiceService),
              ),
            // Active listening overlay
            if (voiceService.state == VoiceCommandState.listening && 
                voiceService.listeningMode == ListeningMode.command)
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 20,
                right: 20,
                child: _buildActiveListeningOverlay(voiceService),
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
  
  Widget _buildVoiceStatusIndicator(VoiceCommandService voiceService) {
    IconData icon;
    Color color;
    String tooltip;
    bool showPulse = false;
    
    switch (voiceService.state) {
      case VoiceCommandState.listening:
        if (voiceService.listeningMode == ListeningMode.wakeWord) {
          icon = Icons.mic_none;
          color = const Color(0xFF3b82f6);
          tooltip = 'Say "Hey Coach" to give a command';
        } else {
          icon = Icons.mic;
          color = const Color(0xFFef4444);
          tooltip = 'Listening for command...';
          showPulse = true;
        }
        break;
      case VoiceCommandState.processing:
        icon = Icons.hearing;
        color = const Color(0xFFf59e0b);
        tooltip = 'Processing...';
        break;
      case VoiceCommandState.error:
        icon = Icons.mic_off;
        color = const Color(0xFFef4444);
        tooltip = voiceService.lastError;
        break;
      case VoiceCommandState.ready:
        icon = Icons.mic_none;
        color = const Color(0xFF6b7280);
        tooltip = 'Voice commands ready';
        break;
      default:
        icon = Icons.mic_off;
        color = const Color(0xFF374151);
        tooltip = 'Voice commands unavailable';
    }
    
    return GestureDetector(
      onTap: () {
        // Show voice command help or status
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tooltip),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF1f2937),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showPulse)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              Icon(
                icon,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActiveListeningOverlay(VoiceCommandService voiceService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFef4444), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFef4444).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          if (voiceService.currentTranscript.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '"${voiceService.currentTranscript}"',
              style: const TextStyle(
                color: Color(0xFF9ca3af),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Commands: pause, resume, next, previous, reset',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleVoiceCommand(VoiceCommandService voiceService, WorkoutState workoutState, SoundEffectsService soundService) {
    final command = voiceService.lastRecognizedCommand;
    if (command == null) return;
    
    debugPrint('🎯 Processing voice command: ${command.type}');
    
    // Clear the command to prevent duplicate processing
    voiceService.clearLastCommand();
    
    // Get services
    final audioService = AudioService();
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    
    // Check for valid workout state
    if (!workoutState.isWorkoutStarted) {
      _showCommandFeedback('No active workout', isError: true);
      return;
    }
    
    if (workoutState.isWorkoutComplete) {
      _showCommandFeedback('Workout already complete', isError: true);
      return;
    }
    
    // Process the command with error handling
    try {
      switch (command.type) {
        case CommandType.pause:
          if (!workoutState.isPaused) {
            workoutState.togglePause();
            soundService.playPauseSound();
            _showCommandFeedback('Workout paused');
            if (settingsService.audioCommandFeedback) {
              audioService.speak('Workout paused');
            }
          } else {
            _showCommandFeedback('Already paused', isError: true);
          }
          break;
          
        case CommandType.resume:
          if (workoutState.isPaused) {
            workoutState.togglePause();
            soundService.playResumeSound();
            _showCommandFeedback('Workout resumed');
            if (settingsService.audioCommandFeedback) {
              audioService.speak('Workout resumed');
            }
          } else {
            _showCommandFeedback('Not paused', isError: true);
          }
          break;
          
        case CommandType.next:
          if (workoutState.currentDrillIndex < workoutState.totalDrills - 1) {
            workoutState.nextDrill();
            soundService.playNextSound();
            final nextDrillName = workoutState.currentDrill?.name ?? 'Next drill';
            _showCommandFeedback('Next: $nextDrillName');
            if (settingsService.audioCommandFeedback && settingsService.announceDrillName) {
              audioService.speak('Next drill: $nextDrillName');
            }
          } else {
            _showCommandFeedback('Already on last drill', isError: true);
            if (settingsService.audioCommandFeedback) {
              audioService.speak('This is the last drill');
            }
          }
          break;
          
        case CommandType.previous:
          if (workoutState.currentDrillIndex > 0) {
            workoutState.previousDrill();
            soundService.playPreviousSound();
            final drillName = workoutState.currentDrill?.name ?? 'Previous drill';
            _showCommandFeedback('Back to: $drillName');
            if (settingsService.audioCommandFeedback && settingsService.announceDrillName) {
              audioService.speak('Previous drill: $drillName');
            }
          } else {
            _showCommandFeedback('Already on first drill', isError: true);
            if (settingsService.audioCommandFeedback) {
              audioService.speak('This is the first drill');
            }
          }
          break;
          
        case CommandType.reset:
          workoutState.resetCurrentDrill();
          soundService.playResetSound();
          _showCommandFeedback('Drill reset');
          if (settingsService.audioCommandFeedback) {
            final drillName = workoutState.currentDrill?.name ?? 'Drill';
            audioService.speak('$drillName reset');
          }
          break;
          
        case CommandType.madeShots:
          if (command.data != null && command.data is int) {
            final shots = command.data as int;
            // Check if current drill supports shot counting
            final drillType = workoutState.currentDrill?.type;
            if (drillType == 'REP_BASED') {
              // This will be handled by the drill widget
              _showCommandFeedback('Made $shots shots');
              if (settingsService.audioCommandFeedback) {
                audioService.speak('Logged $shots makes');
              }
            } else {
              _showCommandFeedback('Current drill doesn\'t track shots', isError: true);
            }
          }
          break;
          
        case CommandType.make:
        case CommandType.miss:
          // These will be handled in Phase 4 for always-listening mode
          final drillType = workoutState.currentDrill?.type;
          if (drillType == 'MAKE_TARGET_TIMED') {
            _showCommandFeedback('Shot tracking coming soon');
          } else {
            _showCommandFeedback('Current drill doesn\'t track shots', isError: true);
          }
          break;
          
        default:
          debugPrint('Unhandled command type: ${command.type}');
          _showCommandFeedback('Command not available', isError: true);
      }
    } catch (e) {
      debugPrint('Error processing voice command: $e');
      _showCommandFeedback('Command failed', isError: true);
    }
  }
  
  void _showCommandFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: Duration(seconds: isError ? 2 : 1),
        backgroundColor: isError ? const Color(0xFFdc2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
}
