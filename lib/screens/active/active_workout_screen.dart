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
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _isCheckingPermission = true;
  PorcupineManager? _porcupineManager;

  @override
  void initState() {
    super.initState();
    _checkAndRequestMicrophonePermission();
  }

  @override
  void dispose() {
    debugPrint("stopping porcupine manager");
    _porcupineManager?.stop();
    _porcupineManager?.delete();
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
    // placeholder
    debugPrint("Wake word detected: $keywordIndex");
  }

  void _createPorcupineManager() async {
    debugPrint("_createPorcupineManager");
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

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        backgroundColor: Color(0xFF111827),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_permissionStatus.isGranted) {
      return const WorkoutUI();
    }

    return PermissionDeniedScreen(
      onRequestPermission: _checkAndRequestMicrophonePermission,
    );
  }
}

class WorkoutUI extends StatelessWidget {
  const WorkoutUI({super.key});

  @override
  Widget build(BuildContext context) {
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
              MaterialPageRoute(builder: (context) => const InjuryLogScreen()),
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
          child: _buildDrillView(drill),
        );
      },
    );
  }

  Widget _buildDrillView(Drill drill) {
    switch (drill.type) {
      case 'TIMED':
        return TimedDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      case 'REP_BASED':
        return RepBasedDrillWidget(key: ValueKey(drill.drillId), drill: drill);
      case 'MAKE_TARGET_TIMED':
        return MakeTargetTimedDrillWidget(
            key: ValueKey(drill.drillId), drill: drill);
      default:
        return Center(child: Text('Unknown drill type: ${drill.type}'));
    }
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
