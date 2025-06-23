import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/drill.dart';
import '../../../services/workout_state.dart';

class RepBasedDrillWidget extends StatelessWidget {
  final Drill drill;

  const RepBasedDrillWidget({Key? key, required this.drill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final targetMakes = drill.config['targetMakes'];
    // We'll need to get the current makes from workoutState later
    const currentMakes = 0;

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
          'MAKES',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[400],
          ),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
            ),
            children: [
              const TextSpan(
                text: '$currentMakes',
                style: TextStyle(fontSize: 96, fontWeight: FontWeight.w900),
              ),
              TextSpan(
                text: ' / $targetMakes',
                style: TextStyle(
                  fontSize: 60,
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          onPressed: () {
            _showLogSetModal(context);
          },
          child: const Text(
            'LOG SET >',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showLogSetModal(BuildContext context) {
    final TextEditingController makesController = TextEditingController();
    final workoutState = Provider.of<WorkoutState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1f2937), // Medium Gray
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log Your Set',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text('How many shots did you make?',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[400])),
            const SizedBox(height: 20),
            TextField(
              controller: makesController,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[700]),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                final makes = int.tryParse(makesController.text) ?? 0;
                // TODO: workoutState.logRepBasedSet(makes: makes);
                print('Logged $makes makes for ${drill.name}');
                Navigator.of(ctx).pop();
                workoutState.nextDrill(); // For now, just advance
              },
              child: const Text('SAVE & CONTINUE',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
