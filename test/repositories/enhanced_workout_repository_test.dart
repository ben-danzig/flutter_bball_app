import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_bball_app/repositories/workout_repository.dart';
import 'package:flutter_bball_app/repositories/custom_workout_repository.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';
import 'package:flutter_bball_app/models/custom_workout_blueprint.dart';
import 'package:flutter_bball_app/models/drill.dart';

@GenerateMocks([CustomWorkoutRepository])
import 'enhanced_workout_repository_test.mocks.dart';

void main() {
  // Initialize Flutter test binding for asset loading
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Enhanced WorkoutRepository', () {
    late WorkoutRepository repository;
    late MockCustomWorkoutRepository mockCustomWorkoutRepository;
    late CustomWorkoutBlueprint testCustomWorkout;

    setUp(() {
      mockCustomWorkoutRepository = MockCustomWorkoutRepository();
      repository = WorkoutRepository(
        customWorkoutRepository: mockCustomWorkoutRepository,
      );

      testCustomWorkout = CustomWorkoutBlueprint(
        id: 'custom_1',
        name: 'Custom Ball Handling',
        objective: 'Improve dribbling skills',
        estimatedDuration: 30,
        drills: [
          Drill(
            drillId: 'drill_1',
            name: 'Crossover Practice',
            description: 'Practice crossover dribbles',
            type: 'TIMED',
            config: {'duration': 60, 'sets': 3},
          ),
        ],
        authorId: 'user123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'Ball Handling',
        difficulty: 'intermediate',
        tags: ['dribbling', 'skills'],
        isPublic: true,
        likes: 5,
        version: 1,
      );
    });

    group('getAllWorkoutBlueprints', () {
      test('returns combined list of pre-built and custom workouts', () async {
        // Mock custom workouts
        when(mockCustomWorkoutRepository.getAllWorkouts())
            .thenAnswer((_) async => [testCustomWorkout]);

        final blueprints = await repository.getAllWorkoutBlueprints();

        // Should have pre-built workouts + custom workouts
        expect(blueprints.length, greaterThan(1));
        expect(blueprints.any((b) => b.id == 'custom_1'), true);
        expect(blueprints.any((b) => b.id == 'foundational_ball_control_and_finishing'), true);
      });

      test('handles empty custom workouts gracefully', () async {
        when(mockCustomWorkoutRepository.getAllWorkouts())
            .thenAnswer((_) async => []);

        final blueprints = await repository.getAllWorkoutBlueprints();

        // Should still have pre-built workouts
        expect(blueprints.length, greaterThan(0));
        expect(blueprints.every((b) => b is WorkoutBlueprint), true);
      });

      test('handles custom repository errors gracefully', () async {
        when(mockCustomWorkoutRepository.getAllWorkouts())
            .thenThrow(Exception('Failed to load custom workouts'));

        final blueprints = await repository.getAllWorkoutBlueprints();

        // Should still return pre-built workouts
        expect(blueprints.length, greaterThan(0));
        expect(blueprints.every((b) => !(b is CustomWorkoutBlueprint)), true);
      });

      test('filters workouts by includeCustom parameter', () async {
        when(mockCustomWorkoutRepository.getAllWorkouts())
            .thenAnswer((_) async => [testCustomWorkout]);

        // Get only pre-built workouts
        final preBuiltOnly = await repository.getAllWorkoutBlueprints(includeCustom: false);
        expect(preBuiltOnly.any((b) => b.id == 'custom_1'), false);
        expect(preBuiltOnly.any((b) => b.id == 'foundational_ball_control_and_finishing'), true);

        // Get all workouts (default)
        final all = await repository.getAllWorkoutBlueprints();
        expect(all.any((b) => b.id == 'custom_1'), true);
        expect(all.any((b) => b.id == 'foundational_ball_control_and_finishing'), true);
      });

      test('filters workouts by includePreBuilt parameter', () async {
        when(mockCustomWorkoutRepository.getAllWorkouts())
            .thenAnswer((_) async => [testCustomWorkout]);

        // Get only custom workouts
        final customOnly = await repository.getAllWorkoutBlueprints(includePreBuilt: false);
        expect(customOnly.any((b) => b.id == 'custom_1'), true);
        expect(customOnly.any((b) => b.id == 'foundational_ball_control_and_finishing'), false);
      });
    });

    group('getWorkoutById', () {
      test('finds pre-built workout by ID', () async {
        final workout = await repository.getWorkoutById('foundational_ball_control_and_finishing');
        
        expect(workout, isNotNull);
        expect(workout!.id, 'foundational_ball_control_and_finishing');
        expect(workout.name, 'Foundational Ball Control & Finishing');
      });

      test('finds custom workout by ID', () async {
        when(mockCustomWorkoutRepository.getWorkoutById('custom_1'))
            .thenAnswer((_) async => testCustomWorkout);

        final workout = await repository.getWorkoutById('custom_1');
        
        expect(workout, isNotNull);
        expect(workout!.id, 'custom_1');
        expect(workout.name, 'Custom Ball Handling');
      });

      test('returns null for non-existent ID', () async {
        when(mockCustomWorkoutRepository.getWorkoutById('non_existent'))
            .thenAnswer((_) async => null);

        final workout = await repository.getWorkoutById('non_existent');
        
        expect(workout, isNull);
      });
    });

    group('searchWorkouts', () {
      test('searches across both pre-built and custom workouts', () async {
        when(mockCustomWorkoutRepository.searchWorkouts(any))
            .thenAnswer((_) async => [testCustomWorkout]);

        final results = await repository.searchWorkouts('ball');

        // Should find workouts from both sources
        expect(results.length, greaterThan(1));
        expect(results.any((w) => w.name.contains('Custom Ball Handling')), true);
        expect(results.any((w) => w.name.contains('Ball Control')), true);
      });

      test('returns empty list for no matches', () async {
        when(mockCustomWorkoutRepository.searchWorkouts(any))
            .thenAnswer((_) async => []);

        final results = await repository.searchWorkouts('xyz123notfound');

        expect(results, isEmpty);
      });

      test('handles case-insensitive search', () async {
        when(mockCustomWorkoutRepository.searchWorkouts(any))
            .thenAnswer((_) async => [testCustomWorkout]);

        final results = await repository.searchWorkouts('BALL');

        expect(results.length, greaterThan(0));
      });
    });

    group('getWorkoutsByCategory', () {
      test('returns workouts from specified category', () async {
        final customBallHandling = testCustomWorkout;
        final customShooting = testCustomWorkout.copyWith(
          id: 'custom_2',
          name: 'Custom Shooting',
          category: 'Shooting',
        );

        when(mockCustomWorkoutRepository.getWorkoutsByCategory('Ball Handling'))
            .thenAnswer((_) async => [customBallHandling]);
        when(mockCustomWorkoutRepository.getWorkoutsByCategory('Shooting'))
            .thenAnswer((_) async => [customShooting]);

        final ballHandlingWorkouts = await repository.getWorkoutsByCategory('Ball Handling');
        final shootingWorkouts = await repository.getWorkoutsByCategory('Shooting');

        expect(ballHandlingWorkouts.any((w) => w.name == 'Custom Ball Handling'), true);
        expect(shootingWorkouts.any((w) => w.name == 'Custom Shooting'), true);
      });

      test('returns empty list for non-existent category', () async {
        when(mockCustomWorkoutRepository.getWorkoutsByCategory(any))
            .thenAnswer((_) async => []);

        final results = await repository.getWorkoutsByCategory('NonExistent');

        expect(results, isEmpty);
      });
    });

    group('getWorkoutsByDifficulty', () {
      test('returns workouts from specified difficulty level', () async {
        final beginnerWorkout = testCustomWorkout.copyWith(
          id: 'custom_beginner',
          difficulty: 'beginner',
        );
        final advancedWorkout = testCustomWorkout.copyWith(
          id: 'custom_advanced',
          difficulty: 'advanced',
        );

        when(mockCustomWorkoutRepository.getWorkoutsByDifficulty('beginner'))
            .thenAnswer((_) async => [beginnerWorkout]);
        when(mockCustomWorkoutRepository.getWorkoutsByDifficulty('advanced'))
            .thenAnswer((_) async => [advancedWorkout]);

        final beginnerWorkouts = await repository.getWorkoutsByDifficulty('beginner');
        final advancedWorkouts = await repository.getWorkoutsByDifficulty('advanced');

        expect(beginnerWorkouts.any((w) => w.id == 'custom_beginner'), true);
        expect(advancedWorkouts.any((w) => w.id == 'custom_advanced'), true);
      });
    });

    group('getWorkoutsByAuthor', () {
      test('returns only custom workouts by specified author', () async {
        final authorWorkouts = [
          testCustomWorkout,
          testCustomWorkout.copyWith(id: 'custom_2', name: 'Another Custom Workout'),
        ];

        when(mockCustomWorkoutRepository.getWorkoutsByAuthor('user123'))
            .thenAnswer((_) async => authorWorkouts);

        final results = await repository.getWorkoutsByAuthor('user123');

        expect(results.length, 2);
        expect(results.every((w) => (w as CustomWorkoutBlueprint).authorId == 'user123'), true);
      });

      test('returns empty list for author with no workouts', () async {
        when(mockCustomWorkoutRepository.getWorkoutsByAuthor('no_workouts_user'))
            .thenAnswer((_) async => []);

        final results = await repository.getWorkoutsByAuthor('no_workouts_user');

        expect(results, isEmpty);
      });
    });

    group('getPublicWorkouts', () {
      test('returns only public custom workouts', () async {
        final publicWorkout = testCustomWorkout;
        final privateWorkout = testCustomWorkout.copyWith(
          id: 'private_1',
          isPublic: false,
        );

        when(mockCustomWorkoutRepository.getPublicWorkouts())
            .thenAnswer((_) async => [publicWorkout]);

        final results = await repository.getPublicWorkouts();

        expect(results.every((w) => (w as CustomWorkoutBlueprint).isPublic), true);
        expect(results.any((w) => w.id == 'private_1'), false);
      });
    });

    group('Type checking', () {
      test('can distinguish between pre-built and custom workouts', () async {
        when(mockCustomWorkoutRepository.getAllWorkouts())
            .thenAnswer((_) async => [testCustomWorkout]);

        final allWorkouts = await repository.getAllWorkoutBlueprints();

        for (final workout in allWorkouts) {
          if (workout is CustomWorkoutBlueprint) {
            // Custom workout specific properties
            expect(workout.authorId, isNotNull);
            expect(workout.isPublic, isNotNull);
          } else {
            // Pre-built workout (base WorkoutBlueprint)
            expect(workout.runtimeType, WorkoutBlueprint);
          }
        }
      });
    });

    group('Error handling', () {
      test('logs error when custom repository fails but continues with pre-built', () async {
        when(mockCustomWorkoutRepository.getAllWorkouts())
            .thenThrow(Exception('Database error'));

        // Should not throw, just return pre-built workouts
        final workouts = await repository.getAllWorkoutBlueprints();
        expect(workouts.length, greaterThan(0));
        expect(workouts.every((w) => w is! CustomWorkoutBlueprint), true);
      });

      test('handles null custom repository gracefully', () async {
        // Create repository without custom workout support
        final basicRepository = WorkoutRepository();

        final workouts = await basicRepository.getAllWorkoutBlueprints();
        
        // Should only return pre-built workouts
        expect(workouts.length, greaterThan(0));
        expect(workouts.every((w) => w is! CustomWorkoutBlueprint), true);
      });
    });

    group('Sorting and filtering', () {
      test('returns workouts sorted by name', () async {
        final workouts = [
          testCustomWorkout.copyWith(id: 'c', name: 'C Workout'),
          testCustomWorkout.copyWith(id: 'a', name: 'A Workout'),
          testCustomWorkout.copyWith(id: 'b', name: 'B Workout'),
        ];

        when(mockCustomWorkoutRepository.getAllWorkouts())
            .thenAnswer((_) async => workouts);

        final sorted = await repository.getAllWorkoutBlueprints(sortBy: 'name');

        // Check if sorted alphabetically
        for (int i = 1; i < sorted.length; i++) {
          expect(sorted[i].name.compareTo(sorted[i-1].name), greaterThanOrEqualTo(0));
        }
      });

      test('returns workouts sorted by duration', () async {
        final workouts = [
          testCustomWorkout.copyWith(id: 'long', estimatedDuration: 60),
          testCustomWorkout.copyWith(id: 'short', estimatedDuration: 15),
          testCustomWorkout.copyWith(id: 'medium', estimatedDuration: 30),
        ];

        when(mockCustomWorkoutRepository.getAllWorkouts())
            .thenAnswer((_) async => workouts);

        final sorted = await repository.getAllWorkoutBlueprints(sortBy: 'duration');

        // Check if sorted by duration
        for (int i = 1; i < sorted.length; i++) {
          expect(sorted[i].estimatedDuration, greaterThanOrEqualTo(sorted[i-1].estimatedDuration));
        }
      });
    });
  });
}