import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bball_app/models/drill_result.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';

class MakeTargetTimedDrillWidget extends StatelessWidget {
  final Drill drill;
  final VoidCallback? onMake;

  const MakeTargetTimedDrillWidget(
      {super.key, required this.drill, this.onMake});

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = Provider.of<WorkoutState>(context);
    final makes = workoutState.results
        .firstWhere((r) => r.drillId == drill.drillId,
            orElse: () => DrillResult(drillId: drill.drillId, makes: 0))
        .makes;
    final targetMakes = drill.config['targetMakes']!;
    final isComplete = (makes ?? 0) >= targetMakes;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          drill.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFf9fafb),
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          _formatDuration(workoutState.currentDrillElapsedSeconds),
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.w900,
            color: isComplete ? Colors.greenAccent : Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'MAKES',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[400],
          ),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
            children: [
              TextSpan(
                text: '${makes ?? 0}',
                style:
                    const TextStyle(fontSize: 72, fontWeight: FontWeight.w900),
              ),
              TextSpan(
                text: ' / $targetMakes',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          drill.description,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF9ca3af),
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        if (!isComplete)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1f2937),
                  minimumSize: const Size(120, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: onMake,
                child: const Text('+1 MAKE',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  minimumSize: const Size(120, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  workoutState.logMakeTargetTimedDrill(
                      elapsedSeconds: workoutState.currentDrillElapsedSeconds);
                  workoutState.nextDrill();
                },
                child: const Text('LOG ALL',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(150, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () {
              workoutState.logMakeTargetTimedDrill(
                  elapsedSeconds: workoutState.currentDrillElapsedSeconds);
              workoutState.nextDrill();
            },
            child: const Text('FINISH DRILL',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
