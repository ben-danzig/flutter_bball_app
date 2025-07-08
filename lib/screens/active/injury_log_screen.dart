import 'package:flutter/material.dart';
import 'package:flutter_bball_app/screens/summary/workout_summary_screen.dart';
import 'package:flutter_bball_app/services/storage_service.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/workout_session.dart';

class InjuryLogScreen extends StatefulWidget {
  const InjuryLogScreen({super.key});

  @override
  _InjuryLogScreenState createState() => _InjuryLogScreenState();
}

class _InjuryLogScreenState extends State<InjuryLogScreen> {
  String? _selectedFeeling;
  final TextEditingController _notesController = TextEditingController();
  final StorageService _storageService = StorageService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How are you feeling?',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Logging this helps you train smarter and avoid overtraining.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildFeelingOption('😌 Feeling Great'),
              const SizedBox(height: 12),
              _buildFeelingOption('🤕 Minor Soreness'),
              const SizedBox(height: 12),
              _buildFeelingOption('😩 Significant Pain'),
              const SizedBox(height: 24),
              TextField(
                controller: _notesController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Optional notes...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1f2937),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: _saveWorkout,
                child: const Text('FINISH & SAVE WORKOUT',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeelingOption(String feeling) {
    final isSelected = _selectedFeeling == feeling;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFeeling = feeling;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1f2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          feeling,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  void _saveWorkout() {
    final workoutState = Provider.of<WorkoutState>(context, listen: false);
    final session = WorkoutSession(
      id: const Uuid().v4(),
      workoutBlueprint: workoutState.workoutBlueprint!,
      results: workoutState.results,
      completedAt: DateTime.now(),
      feeling: _selectedFeeling,
      notes: _notesController.text,
    );

    _storageService.saveSession(session).then((_) {
      workoutState.endWorkout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => WorkoutSummaryScreen(session: session),
        ),
        (route) => route.isFirst,
      );
    });
  }
}
