import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/repositories/workout_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // This is a special test setup function.
  // It's needed because our repository uses rootBundle to load assets,
  // which requires the Flutter framework to be initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('WorkoutRepository should load and parse all workout blueprints',
      () async {
    // 1. ARRANGE: Create an instance of our repository.
    final workoutRepository = WorkoutRepository();

    // 2. ACT: Call the method we want to test.
    final blueprints = await workoutRepository.getAllWorkoutBlueprints();

    // 3. ASSERT: Verify the result is what we expect.
    // We should have 4 workouts now: 3 from production and 1 from test.
    expect(blueprints, isA<List<WorkoutBlueprint>>());
    expect(blueprints.length, 4);

    // Check the production workout
    final prodWorkout =
        blueprints.firstWhere((b) => b.id == 'foundational_ball_control_and_finishing');
    expect(prodWorkout.name, 'Foundational Ball Control & Finishing');
    expect(prodWorkout.drills.length, 5);

    // Check the test workout
    final testWorkout =
        blueprints.firstWhere((b) => b.id == 'comprehensive_short_test');
    expect(testWorkout.name, 'Quick Test Workout (All Types)');
    expect(testWorkout.drills.length, 3);
  });
}
