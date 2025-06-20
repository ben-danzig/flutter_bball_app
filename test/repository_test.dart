import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/repositories/workout_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // This is a special test setup function.
  // It's needed because our repository uses rootBundle to load assets,
  // which requires the Flutter framework to be initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('WorkoutRepository should load and parse the workout blueprint correctly', () async {
    // 1. ARRANGE: Create an instance of our repository.
    final workoutRepository = WorkoutRepository();

    // 2. ACT: Call the method we want to test.
    final blueprint = await workoutRepository.getWorkoutBlueprint();

    // 3. ASSERT: Verify the result is what we expect.
    expect(blueprint, isA<WorkoutBlueprint>());
    expect(blueprint.name, 'Foundational Ball Control & Finishing');
    expect(blueprint.drills.length, 5);
    expect(blueprint.drills.first.name, 'Off-Hand Freestyle');
  });
}