import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';

class RepBasedDrillWidget extends StatelessWidget {
  final Drill drill;

  const RepBasedDrillWidget({Key? key, required this.drill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          drill.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Complete ${drill.config['targetMakes']} makes.',
          style: const TextStyle(fontSize: 18, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            _showLogSetModal(context);
          },
          child: const Text('LOG SET'),
        ),
      ],
    );
  }

  void _showLogSetModal(BuildContext context) {
    final TextEditingController makesController = TextEditingController();
    final workoutState = Provider.of<WorkoutState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Log Your Set', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: makesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Makes (out of ${drill.config['targetMakes']})',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final makes = int.tryParse(makesController.text) ?? 0;
                // We'll need a method on WorkoutState to handle this
                // workoutState.logRepBasedSet(makes: makes);
                print('Logged $makes makes for ${drill.name}');
                Navigator.of(ctx).pop();
                workoutState.nextDrill(); // For now, just advance
              },
              child: const Text('Save Set'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
