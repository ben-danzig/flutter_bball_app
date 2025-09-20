import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_bball_app/providers/workout_builder_provider.dart';
import 'package:flutter_bball_app/repositories/custom_workout_repository.dart';
import 'package:flutter_bball_app/models/custom_workout_blueprint.dart';
import 'package:flutter_bball_app/models/drill.dart';

@GenerateMocks([CustomWorkoutRepository])
import 'workout_builder_provider_test.mocks.dart';

void main() {
  group('WorkoutBuilderProvider', () {
    late WorkoutBuilderProvider provider;
    late MockCustomWorkoutRepository mockRepository;

    setUp(() {
      mockRepository = MockCustomWorkoutRepository();
      provider = WorkoutBuilderProvider(repository: mockRepository);
    });

    tearDown(() {
      provider.dispose();
    });

    group('Initialization', () {
      test('starts with empty workout', () {
        expect(provider.name, '');
        expect(provider.objective, '');
        expect(provider.category, isNull);
        expect(provider.difficulty, 'beginner');
        expect(provider.tags, isEmpty);
        expect(provider.drills, isEmpty);
        expect(provider.isPublic, false);
      });

      test('loads draft if available', () async {
        final draftWorkout = CustomWorkoutBlueprint(
          id: 'draft_1',
          name: 'Draft Workout',
          objective: 'Draft objective',
          estimatedDuration: 30,
          drills: [
            Drill(
              drillId: 'drill_1',
              name: 'Test Drill',
              description: 'Test',
              type: 'TIMED',
              config: {'duration': 60, 'sets': 3},
            ),
          ],
          authorId: 'user123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Ball Handling',
          difficulty: 'intermediate',
          tags: ['draft'],
          isPublic: false,
          likes: 0,
          version: 1,
        );

        when(mockRepository.loadDraft())
            .thenAnswer((_) async => draftWorkout);

        await provider.loadDraft();

        expect(provider.name, 'Draft Workout');
        expect(provider.objective, 'Draft objective');
        expect(provider.category, 'Ball Handling');
        expect(provider.difficulty, 'intermediate');
        expect(provider.tags, ['draft']);
        expect(provider.drills.length, 1);
      });
    });

    group('Metadata Management', () {
      test('updates name', () {
        provider.updateName('My Workout');
        expect(provider.name, 'My Workout');
      });

      test('validates name length', () {
        // Too short
        provider.updateName('AB');
        expect(provider.nameError, 'Name must be at least 3 characters');
        
        // Too long
        provider.updateName('A' * 51);
        expect(provider.nameError, 'Name must not exceed 50 characters');
        
        // Valid
        provider.updateName('Valid Name');
        expect(provider.nameError, isNull);
      });

      test('updates objective', () {
        provider.updateObjective('Improve skills');
        expect(provider.objective, 'Improve skills');
      });

      test('updates category', () {
        provider.updateCategory('Shooting');
        expect(provider.category, 'Shooting');
      });

      test('updates difficulty', () {
        provider.updateDifficulty('advanced');
        expect(provider.difficulty, 'advanced');
      });

      test('manages tags', () {
        provider.addTag('tag1');
        expect(provider.tags, ['tag1']);
        
        provider.addTag('tag2');
        expect(provider.tags, ['tag1', 'tag2']);
        
        // Duplicate tag not added
        provider.addTag('tag1');
        expect(provider.tags, ['tag1', 'tag2']);
        
        provider.removeTag('tag1');
        expect(provider.tags, ['tag2']);
      });

      test('validates tag count', () {
        for (int i = 0; i < 10; i++) {
          provider.addTag('tag$i');
        }
        expect(provider.tags.length, 10);
        
        // Should not add 11th tag
        provider.addTag('tag11');
        expect(provider.tags.length, 10);
        expect(provider.tagsError, 'Maximum 10 tags allowed');
      });

      test('toggles public status', () {
        expect(provider.isPublic, false);
        
        provider.togglePublic();
        expect(provider.isPublic, true);
        
        provider.togglePublic();
        expect(provider.isPublic, false);
      });
    });

    group('Drill Management', () {
      final testDrill = Drill(
        drillId: 'drill_1',
        name: 'Test Drill',
        description: 'Test description',
        type: 'TIMED',
        config: {'duration': 60, 'sets': 3},
      );

      test('adds drill', () {
        provider.addDrill(testDrill);
        
        expect(provider.drills.length, 1);
        expect(provider.drills[0].drillId, 'drill_1');
      });

      test('removes drill', () {
        provider.addDrill(testDrill);
        expect(provider.drills.length, 1);
        
        provider.removeDrill(0);
        expect(provider.drills, isEmpty);
      });

      test('reorders drills', () {
        final drill1 = testDrill;
        final drill2 = testDrill.copyWith(drillId: 'drill_2', name: 'Drill 2');
        final drill3 = testDrill.copyWith(drillId: 'drill_3', name: 'Drill 3');
        
        provider.addDrill(drill1);
        provider.addDrill(drill2);
        provider.addDrill(drill3);
        
        provider.reorderDrills(0, 2);
        
        expect(provider.drills[0].drillId, 'drill_2');
        expect(provider.drills[1].drillId, 'drill_3');
        expect(provider.drills[2].drillId, 'drill_1');
      });

      test('validates drill count', () {
        // Add 20 drills (maximum)
        for (int i = 0; i < 20; i++) {
          provider.addDrill(testDrill.copyWith(drillId: 'drill_$i'));
        }
        expect(provider.drills.length, 20);
        
        // Should not add 21st drill
        provider.addDrill(testDrill.copyWith(drillId: 'drill_21'));
        expect(provider.drills.length, 20);
        expect(provider.drillsError, 'Maximum 20 drills allowed');
      });

      test('calculates total duration', () {
        final drill1 = Drill(
          drillId: 'drill_1',
          name: 'Drill 1',
          description: 'Test',
          type: 'TIMED',
          config: {'duration': 60, 'sets': 2}, // 2 minutes
        );
        
        final drill2 = Drill(
          drillId: 'drill_2',
          name: 'Drill 2',
          description: 'Test',
          type: 'REP_BASED',
          config: {'targetMakes': 10, 'sets': 3}, // Estimated 3 minutes
        );
        
        provider.addDrill(drill1);
        provider.addDrill(drill2);
        
        expect(provider.estimatedDuration, 5);
      });
    });

    group('Validation', () {
      test('validates complete workout', () {
        expect(provider.isValid, false);
        expect(provider.validationErrors, isNotEmpty);
        
        // Add required fields
        provider.updateName('Valid Workout');
        provider.updateObjective('Test objective');
        provider.updateCategory('Ball Handling');
        provider.addDrill(Drill(
          drillId: 'drill_1',
          name: 'Test Drill',
          description: 'Test',
          type: 'TIMED',
          config: {'duration': 60, 'sets': 1},
        ));
        
        expect(provider.isValid, true);
        expect(provider.validationErrors, isEmpty);
      });

      test('provides specific validation errors', () {
        final errors = provider.validationErrors;
        
        expect(errors, contains('Name is required'));
        expect(errors, contains('Objective is required'));
        expect(errors, contains('Category is required'));
        expect(errors, contains('At least one drill is required'));
      });

      test('validates duration constraints', () {
        provider.updateName('Test');
        provider.updateObjective('Test');
        provider.updateCategory('Ball Handling');
        
        // Add drill with total duration < 5 minutes
        provider.addDrill(Drill(
          drillId: 'drill_1',
          name: 'Short Drill',
          description: 'Test',
          type: 'TIMED',
          config: {'duration': 30, 'sets': 2}, // 1 minute
        ));
        
        expect(provider.validationErrors, contains('Workout must be at least 5 minutes'));
      });
    });

    group('Draft Management', () {
      test('saves draft automatically', () async {
        when(mockRepository.saveDraft(any))
            .thenAnswer((_) async => {});
        
        // Update triggers auto-save
        provider.updateName('Auto Save Test');
        
        // Wait for debounce
        await Future.delayed(const Duration(milliseconds: 600));
        
        verify(mockRepository.saveDraft(any)).called(1);
      });

      test('clears draft', () async {
        when(mockRepository.clearDraft())
            .thenAnswer((_) async => {});
        
        provider.updateName('Test');
        provider.addDrill(Drill(
          drillId: 'drill_1',
          name: 'Test Drill',
          description: 'Test',
          type: 'TIMED',
          config: {'duration': 60},
        ));
        
        await provider.clearDraft();
        
        expect(provider.name, '');
        expect(provider.drills, isEmpty);
        verify(mockRepository.clearDraft()).called(1);
      });
    });

    group('Workout Creation', () {
      test('creates workout from current state', () async {
        final expectedWorkout = CustomWorkoutBlueprint(
          id: 'new_workout',
          name: 'Test Workout',
          objective: 'Test objective',
          estimatedDuration: 30,
          drills: [
            Drill(
              drillId: 'drill_1',
              name: 'Test Drill',
              description: 'Test',
              type: 'TIMED',
              config: {'duration': 60, 'sets': 30},
            ),
          ],
          authorId: 'user123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Ball Handling',
          difficulty: 'intermediate',
          tags: ['test'],
          isPublic: false,
          likes: 0,
          version: 1,
        );
        
        when(mockRepository.createWorkout(any))
            .thenAnswer((_) async => expectedWorkout);
        when(mockRepository.clearDraft())
            .thenAnswer((_) async => {});
        
        // Set up provider state
        provider.updateName('Test Workout');
        provider.updateObjective('Test objective');
        provider.updateCategory('Ball Handling');
        provider.updateDifficulty('intermediate');
        provider.addTag('test');
        provider.addDrill(expectedWorkout.drills[0]);
        provider.setUserId('user123');
        
        final created = await provider.createWorkout();
        
        expect(created, isNotNull);
        expect(created!.name, 'Test Workout');
        verify(mockRepository.createWorkout(any)).called(1);
        verify(mockRepository.clearDraft()).called(1);
      });

      test('returns null if validation fails', () async {
        // Don't set required fields
        final created = await provider.createWorkout();
        
        expect(created, isNull);
        verifyNever(mockRepository.createWorkout(any));
      });
    });

    group('Step Navigation', () {
      test('tracks current step', () {
        expect(provider.currentStep, 0);
        
        provider.nextStep();
        expect(provider.currentStep, 1);
        
        provider.nextStep();
        expect(provider.currentStep, 2);
        
        provider.previousStep();
        expect(provider.currentStep, 1);
      });

      test('validates before moving to next step', () {
        // Step 0: Metadata
        expect(provider.canProceedToNextStep, false);
        
        provider.updateName('Valid Name');
        provider.updateObjective('Valid objective');
        provider.updateCategory('Ball Handling');
        
        expect(provider.canProceedToNextStep, true);
        
        provider.nextStep();
        
        // Step 1: Drills
        expect(provider.canProceedToNextStep, false);
        
        provider.addDrill(Drill(
          drillId: 'drill_1',
          name: 'Test Drill',
          description: 'Test',
          type: 'TIMED',
          config: {'duration': 300, 'sets': 1},
        ));
        
        expect(provider.canProceedToNextStep, true);
      });

      test('prevents navigation beyond bounds', () {
        provider.previousStep();
        expect(provider.currentStep, 0);
        
        // Navigate to last step
        provider.updateName('Test');
        provider.updateObjective('Test');
        provider.updateCategory('Ball Handling');
        provider.nextStep();
        provider.addDrill(Drill(
          drillId: 'drill_1',
          name: 'Test',
          description: 'Test',
          type: 'TIMED',
          config: {'duration': 300},
        ));
        provider.nextStep();
        
        // Try to go beyond last step
        provider.nextStep();
        expect(provider.currentStep, 2);
      });
    });

    group('State Persistence', () {
      test('converts to CustomWorkoutBlueprint', () {
        provider.updateName('Test Workout');
        provider.updateObjective('Test objective');
        provider.updateCategory('Shooting');
        provider.updateDifficulty('advanced');
        provider.addTag('tag1');
        provider.addTag('tag2');
        provider.togglePublic();
        provider.setUserId('user123');
        
        provider.addDrill(Drill(
          drillId: 'drill_1',
          name: 'Drill 1',
          description: 'Test',
          type: 'TIMED',
          config: {'duration': 300, 'sets': 1},
        ));
        
        final blueprint = provider.toBlueprint();
        
        expect(blueprint.name, 'Test Workout');
        expect(blueprint.objective, 'Test objective');
        expect(blueprint.category, 'Shooting');
        expect(blueprint.difficulty, 'advanced');
        expect(blueprint.tags, ['tag1', 'tag2']);
        expect(blueprint.isPublic, true);
        expect(blueprint.authorId, 'user123');
        expect(blueprint.drills.length, 1);
        expect(blueprint.estimatedDuration, 5);
      });

      test('loads from existing workout for editing', () {
        final existing = CustomWorkoutBlueprint(
          id: 'existing_1',
          name: 'Existing Workout',
          objective: 'Existing objective',
          estimatedDuration: 30,
          drills: [
            Drill(
              drillId: 'drill_1',
              name: 'Existing Drill',
              description: 'Test',
              type: 'TIMED',
              config: {'duration': 1800, 'sets': 1},
            ),
          ],
          authorId: 'user123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Defense',
          difficulty: 'expert',
          tags: ['existing', 'test'],
          isPublic: true,
          likes: 10,
          version: 2,
        );
        
        provider.loadFromExisting(existing);
        
        expect(provider.workoutId, 'existing_1');
        expect(provider.name, 'Existing Workout');
        expect(provider.objective, 'Existing objective');
        expect(provider.category, 'Defense');
        expect(provider.difficulty, 'expert');
        expect(provider.tags, ['existing', 'test']);
        expect(provider.isPublic, true);
        expect(provider.drills.length, 1);
      });
    });
  });
}