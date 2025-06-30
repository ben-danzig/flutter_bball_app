import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/screens/active/injury_log_screen.dart';
import 'package:flutter_bball_app/screens/active/widgets/active_drill_layout.dart';
import 'package:flutter_bball_app/screens/active/widgets/make_target_timed_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/rep_based_drill_widget.dart';
import 'package:flutter_bball_app/screens/active/widgets/timed_drill_widget.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:rhino_flutter/rhino_manager.dart';
import 'package:rhino_flutter/rhino.dart';
import 'package:rhino_flutter/rhino_error.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _isCheckingPermission = true;
  PorcupineManager? _porcupineManager;
  RhinoManager? _rhinoManager;
  bool _isListeningForCommand = false;
  Timer? _timer;
  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _checkAndRequestMicrophonePermission();
    _startTimer();
    _initTts();
  }

  @override
  void dispose() {
    _porcupineManager?.stop();
    _porcupineManager?.delete();
    _rhinoManager?.delete();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndRequestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (mounted) {
      setState(() {
        _permissionStatus = status;
        _isCheckingPermission = false;
      });
      if (status.isGranted) {
        _createPorcupineManager();
      }
    }
  }

  void _wakeWordCallback(int keywordIndex) {
    debugPrint("Wake word detected: $keywordIndex");
    if (keywordIndex == 0) {
      setState(() {
        _isListeningForCommand = true;
      });
      _porcupineManager?.stop();
      _createRhinoManager();
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _inferenceCallback(RhinoInference inference) {
    debugPrint("Rhino inference: $inference, understood? ${inference.isUnderstood}, intent: ${inference.intent}");
    if (inference.isUnderstood!) {
      final intent = inference.intent;
      final workoutState = Provider.of<WorkoutState>(context, listen: false);
      debugPrint("");
      if (intent == 'madeShot') {
        workoutState.logMake();
        _speak("Make");
      } else if (intent == 'missedShot') {
        debugPrint("No Missed Shot action yet");
        _speak("Miss");
      } else if (intent == 'nextDrill') {
        final drill = workoutState.currentDrill;
        if (drill != null) {
          if (drill.type == 'TIMED') {
            workoutState.logTimedDrill();
          } else if (drill.type == 'MAKE_TARGET_TIMED') {
            workoutState.logMakeTargetTimedDrill(
                elapsedSeconds: workoutState.currentDrillElapsedSeconds);
          }
        }
        workoutState.nextDrill();
        _speak("Next Drill");
      } else if (intent == 'pause' && !workoutState.isPaused) {
        workoutState.togglePause();
        _speak("Paused");
      }
      else if (intent == 'resume' && workoutState.isPaused) {
        workoutState.togglePause();
        _speak("Resuming");
      }
    }

    setState(() {
      _isListeningForCommand = false;
    });
    _rhinoManager?.delete();
    _porcupineManager?.start();
  }

  void _createPorcupineManager() async {
    final accessKey = dotenv.env['PICOVOICE_ACCESS_KEY'];
    if (accessKey == null) {
      debugPrint("PICOVOICE_ACCESS_KEY not found in .env file");
      return;
    }

    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
          accessKey,
          ['assets/models/register_en_android_v3_0_0.ppn'],
          _wakeWordCallback);
      await _porcupineManager?.start();
    } on PorcupineException catch (err) {
      debugPrint("Failed to initialize Porcupine: ${err.message}");
    }
  }

  void _createRhinoManager() async {
    final accessKey = dotenv.env['PICOVOICE_ACCESS_KEY'];
    if (accessKey == null) {
      debugPrint("PICOVOICE_ACCESS_KEY not found in .env file");
      return;
    }

    try {
      _rhinoManager = await RhinoManager.create(accessKey,
          'assets/models/basketball-app-actions_en_android_v3_0_0.rhn',
          _inferenceCallback);
      await _rhinoManager?.process();
    } on RhinoException catch (err) {
      debugPrint("Failed to initialize Rhino: ${err.message}");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final workoutState = Provider.of<WorkoutState>(context, listen: false);
      if (workoutState.isWorkoutStarted && !workoutState.isWorkoutComplete) {
        workoutState.tick();
      }
    });
  }

  Widget _buildDrillView(Drill drill, WorkoutState workoutState) {
    switch (drill.type) {
      case 'TIMED':
        return TimedDrillWidget(
          key: ValueKey(drill.drillId),
          drill: drill,
        );
      case 'REP_BASED':
        return RepBasedDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      case 'MAKE_TARGET_TIMED':
        return MakeTargetTimedDrillWidget(
          key: ValueKey(drill.drillId),
          drill: drill,
          onMake: workoutState.logMake,
        );
      default:
        return Center(child: Text('Unknown drill type: ${drill.type}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        backgroundColor: Color(0xFF111827),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_permissionStatus.isGranted) {
      return Consumer<WorkoutState>(
        builder: (context, workoutState, child) {
          if (!workoutState.isWorkoutStarted) {
            return const Scaffold(
              backgroundColor: Color(0xFF111827),
              body: Center(
                  child: Text('No active workout.',
                      style: TextStyle(color: Colors.white))),
            );
          }

          if (workoutState.isWorkoutComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const InjuryLogScreen()),
              );
            });
            return const Scaffold(
              backgroundColor: Color(0xFF111827),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final drill = workoutState.currentDrill!;

          return ActiveDrillLayout(
            drillName: drill.name,
            nextDrillName: workoutState.nextDrillName,
            progress: workoutState.workoutProgress,
            child: _buildDrillView(drill, workoutState),
          );
        },
      );
    }

    return PermissionDeniedScreen(
      onRequestPermission: _checkAndRequestMicrophonePermission,
    );
  }
}

class PermissionDeniedScreen extends StatelessWidget {
  final VoidCallback onRequestPermission;
  const PermissionDeniedScreen({super.key, required this.onRequestPermission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Microphone Access Required',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This app uses the microphone for voice commands to control the workout hands-free. Please grant permission to continue.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  // Check if the permission is permanently denied
                  if (await Permission.microphone.isPermanentlyDenied) {
                    // If so, open app settings
                    await openAppSettings();
                  } else {
                    // Otherwise, request permission again
                    onRequestPermission();
                  }
                },
                child: const Text(
                  'Grant Permission',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
