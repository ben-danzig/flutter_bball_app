import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/services/workout_state.dart';
//import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A mock blueprint for testing purposes
  final mockBlueprint = WorkoutBlueprint(
    id: 'test_id',
    name: 'Test Workout',
    objective: 'Test objective',
    estimatedDuration: 10,
    drills: [
      Drill(drillId: 'd1', name: 'Drill 1', description: '', type: 'TIMED', config: {}),
      Drill(drillId: 'd2', name: 'Drill 2', description: '', type: 'REP_BASED', config: {}),
    ],
  );

  test('startWorkout should initialize the state correctly', () {
    // ARRANGE
    final workoutState = WorkoutState();

    // ACT
    workoutState.startWorkout(mockBlueprint);

    // ASSERT
    expect(workoutState.isWorkoutStarted, isTrue);
    expect(workoutState.currentDrillIndex, 0);
    expect(workoutState.currentDrill?.name, 'Drill 1');
    expect(workoutState.totalDrills, 2);
  });

  test('nextDrill should advance the drill index', () {
    // ARRANGE
    final workoutState = WorkoutState();
    workoutState.startWorkout(mockBlueprint);

    // ACT
    workoutState.nextDrill();

    // ASSERT
    expect(workoutState.currentDrillIndex, 1);
    expect(workoutState.currentDrill?.name, 'Drill 2');
  });

   test('endWorkout should reset the state', () {
    // ARRANGE
    final workoutState = WorkoutState();
    workoutState.startWorkout(mockBlueprint);
    workoutState.nextDrill(); // Move state forward

    // ACT
    workoutState.endWorkout();

    // ASSERT
    expect(workoutState.isWorkoutStarted, isFalse);
    expect(workoutState.currentDrillIndex, 0);
    expect(workoutState.currentDrill, isNull);
  });
}