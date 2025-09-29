import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bball_app/repositories/custom_workout_repository.dart';
import 'package:flutter_bball_app/models/custom_workout_blueprint.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'dart:convert';

@GenerateMocks([SharedPreferences, FirebaseFirestore, CollectionReference, DocumentReference, DocumentSnapshot, QuerySnapshot, QueryDocumentSnapshot])
import 'custom_workout_repository_test.mocks.dart';

void main() {
  group('CustomWorkoutRepository', () {
    late CustomWorkoutRepository repository;
    late MockSharedPreferences mockSharedPreferences;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late CustomWorkoutBlueprint testWorkout;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();

      when(mockFirestore.collection(any)).thenReturn(mockCollection);

      repository = CustomWorkoutRepository(
        sharedPreferences: mockSharedPreferences,
        firestore: mockFirestore,
      );

      testWorkout = CustomWorkoutBlueprint(
        id: 'test_workout_1',
        name: 'Test Workout',
        objective: 'Test objective',
        estimatedDuration: 30,
        drills: [
          Drill(
            drillId: 'drill_1',
            name: 'Test Drill',
            description: 'Test description',
            type: 'TIMED',
            config: {'duration': 60},
          ),
        ],
        authorId: 'user123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: 'Ball Handling',
        difficulty: 'beginner',
        tags: ['test'],
        isPublic: false,
        likes: 0,
        version: 1,
      );
    });

    group('Create', () {
      test('creates workout in local storage', () async {
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final createdWorkout = await repository.createWorkout(testWorkout);

        expect(createdWorkout.id, isNotEmpty);
        expect(createdWorkout.name, testWorkout.name);
        verify(mockSharedPreferences.setString(
          'custom_workouts',
          argThat(contains(testWorkout.name)),
        )).called(1);
      });

      test('creates workout in Firestore when online', () async {
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        when(mockCollection.doc(any)).thenReturn(mockDoc);
        when(mockDoc.set(any)).thenAnswer((_) async => {});

        final createdWorkout = await repository.createWorkout(testWorkout);

        verify(mockDoc.set(argThat(containsPair('name', testWorkout.name))))
            .called(1);
      });

      test('generates unique ID for new workout', () async {
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final workout1 = await repository.createWorkout(testWorkout);
        final workout2 = await repository.createWorkout(testWorkout);

        expect(workout1.id, isNot(equals(workout2.id)));
      });

      test('handles offline mode gracefully', () async {
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        // Simulate Firestore offline error
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        when(mockCollection.doc(any)).thenReturn(mockDoc);
        when(mockDoc.set(any)).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        ));

        // Should still create locally
        final createdWorkout = await repository.createWorkout(testWorkout);
        expect(createdWorkout.id, isNotEmpty);
      });
    });

    group('Read', () {
      test('gets all workouts from local storage', () async {
        final workouts = [testWorkout];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);

        final result = await repository.getAllWorkouts();

        expect(result.length, 1);
        expect(result[0].name, testWorkout.name);
      });

      test('gets single workout by ID', () async {
        final workouts = [testWorkout];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);

        final result = await repository.getWorkoutById(testWorkout.id);

        expect(result, isNotNull);
        expect(result!.id, testWorkout.id);
        expect(result.name, testWorkout.name);
      });

      test('returns null for non-existent workout ID', () async {
        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn('[]');

        final result = await repository.getWorkoutById('non_existent');

        expect(result, isNull);
      });

      test('gets workouts by author', () async {
        final workout1 = testWorkout;
        final workout2 = testWorkout.copyWith(
          id: 'test_workout_2',
          authorId: 'user456',
        );
        final workouts = [workout1, workout2];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);

        final result = await repository.getWorkoutsByAuthor('user123');

        expect(result.length, 1);
        expect(result[0].authorId, 'user123');
      });

      test('gets public workouts', () async {
        final workout1 = testWorkout;
        final workout2 = testWorkout.copyWith(
          id: 'test_workout_2',
          isPublic: true,
        );
        final workouts = [workout1, workout2];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);

        final result = await repository.getPublicWorkouts();

        expect(result.length, 1);
        expect(result[0].isPublic, true);
      });

      test('searches workouts by name', () async {
        final workout1 = testWorkout.copyWith(
          id: 'workout_1',
          name: 'Ball Handling Basics',
        );
        final workout2 = testWorkout.copyWith(
          id: 'workout_2',
          name: 'Shooting Fundamentals',
        );
        final workouts = [workout1, workout2];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);

        final result = await repository.searchWorkouts('ball');

        expect(result.length, 1);
        expect(result[0].name.toLowerCase(), contains('ball'));
      });

      test('filters workouts by category', () async {
        final workout1 = testWorkout.copyWith(
          id: 'workout_1',
          category: 'Ball Handling',
        );
        final workout2 = testWorkout.copyWith(
          id: 'workout_2',
          category: 'Shooting',
        );
        final workouts = [workout1, workout2];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);

        final result = await repository.getWorkoutsByCategory('Shooting');

        expect(result.length, 1);
        expect(result[0].category, 'Shooting');
      });

      test('filters workouts by difficulty', () async {
        final workout1 = testWorkout.copyWith(
          id: 'workout_1',
          difficulty: 'beginner',
        );
        final workout2 = testWorkout.copyWith(
          id: 'workout_2',
          difficulty: 'advanced',
        );
        final workouts = [workout1, workout2];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);

        final result = await repository.getWorkoutsByDifficulty('advanced');

        expect(result.length, 1);
        expect(result[0].difficulty, 'advanced');
      });

      test('filters workouts by tags', () async {
        final workout1 = testWorkout.copyWith(
          id: 'workout_1',
          tags: ['dribbling', 'fundamentals'],
        );
        final workout2 = testWorkout.copyWith(
          id: 'workout_2',
          tags: ['shooting', 'accuracy'],
        );
        final workouts = [workout1, workout2];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);

        final result = await repository.getWorkoutsByTags(['dribbling']);

        expect(result.length, 1);
        expect(result[0].tags, contains('dribbling'));
      });
    });

    group('Update', () {
      test('updates workout in local storage', () async {
        final workouts = [testWorkout];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final updatedWorkout = testWorkout.copyWith(
          name: 'Updated Workout Name',
          updatedAt: DateTime.now(),
        );

        final result = await repository.updateWorkout(updatedWorkout);

        expect(result.name, 'Updated Workout Name');
        verify(mockSharedPreferences.setString(
          'custom_workouts',
          argThat(contains('Updated Workout Name')),
        )).called(1);
      });

      test('updates workout in Firestore when online', () async {
        final workouts = [testWorkout];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        when(mockCollection.doc(testWorkout.id)).thenReturn(mockDoc);
        when(mockDoc.update(any)).thenAnswer((_) async => {});

        final updatedWorkout = testWorkout.copyWith(
          name: 'Updated Workout Name',
        );

        await repository.updateWorkout(updatedWorkout);

        verify(mockDoc.update(argThat(containsPair('name', 'Updated Workout Name'))))
            .called(1);
      });

      test('throws error if workout does not exist', () async {
        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn('[]');

        expect(
          () => repository.updateWorkout(testWorkout),
          throwsException,
        );
      });

      test('increments version on update', () async {
        final workouts = [testWorkout];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final updatedWorkout = testWorkout.copyWith(name: 'Updated');
        final result = await repository.updateWorkout(updatedWorkout);

        expect(result.version, testWorkout.version + 1);
      });
    });

    group('Delete', () {
      test('deletes workout from local storage', () async {
        final workouts = [testWorkout];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        await repository.deleteWorkout(testWorkout.id);

        verify(mockSharedPreferences.setString(
          'custom_workouts',
          argThat(equals('[]')),
        )).called(1);
      });

      test('deletes workout from Firestore when online', () async {
        final workouts = [testWorkout];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        when(mockCollection.doc(testWorkout.id)).thenReturn(mockDoc);
        when(mockDoc.delete()).thenAnswer((_) async => {});

        await repository.deleteWorkout(testWorkout.id);

        verify(mockDoc.delete()).called(1);
      });

      test('does not throw if workout does not exist', () async {
        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn('[]');
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        // Should not throw
        await repository.deleteWorkout('non_existent');
      });
    });

    group('Sync', () {
      test('syncs local workouts to Firestore', () async {
        final workouts = [testWorkout];
        final json = jsonEncode(
            workouts.map((w) => w.toJson()).toList());

        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(json);

        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        when(mockCollection.where('authorId', isEqualTo: testWorkout.authorId))
            .thenReturn(mockCollection);
        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        when(mockCollection.doc(testWorkout.id)).thenReturn(mockDoc);
        when(mockDoc.set(any)).thenAnswer((_) async => {});

        await repository.syncToFirestore(testWorkout.authorId);

        verify(mockDoc.set(any)).called(1);
      });

      test('syncs Firestore workouts to local storage', () async {
        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn('[]');
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockQueryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        
        when(mockCollection.where('authorId', isEqualTo: testWorkout.authorId))
            .thenReturn(mockCollection);
        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
        when(mockQueryDoc.data()).thenReturn(testWorkout.toJson());

        await repository.syncFromFirestore(testWorkout.authorId);

        verify(mockSharedPreferences.setString(
          'custom_workouts',
          argThat(contains(testWorkout.name)),
        )).called(1);
      });

      test('handles sync conflicts by keeping newer version', () async {
        final localWorkout = testWorkout.copyWith(
          version: 1,
          updatedAt: DateTime(2024, 1, 1),
        );
        final remoteWorkout = testWorkout.copyWith(
          version: 2,
          updatedAt: DateTime(2024, 1, 2),
          name: 'Remote Updated Name',
        );

        final localJson = jsonEncode([localWorkout.toJson()]);
        when(mockSharedPreferences.getString('custom_workouts'))
            .thenReturn(localJson);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockQueryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        
        when(mockCollection.where('authorId', isEqualTo: testWorkout.authorId))
            .thenReturn(mockCollection);
        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
        when(mockQueryDoc.data()).thenReturn(remoteWorkout.toJson());

        await repository.syncFromFirestore(testWorkout.authorId);

        // Should keep the remote version (newer)
        verify(mockSharedPreferences.setString(
          'custom_workouts',
          argThat(contains('Remote Updated Name')),
        )).called(1);
      });
    });

    group('Draft Management', () {
      test('saves draft workout', () async {
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        await repository.saveDraft(testWorkout);

        verify(mockSharedPreferences.setString(
          'workout_draft',
          argThat(contains(testWorkout.name)),
        )).called(1);
      });

      test('loads draft workout', () async {
        final json = jsonEncode(testWorkout.toJson());
        when(mockSharedPreferences.getString('workout_draft'))
            .thenReturn(json);

        final draft = await repository.loadDraft();

        expect(draft, isNotNull);
        expect(draft!.name, testWorkout.name);
      });

      test('clears draft workout', () async {
        when(mockSharedPreferences.remove(any))
            .thenAnswer((_) async => true);

        await repository.clearDraft();

        verify(mockSharedPreferences.remove('workout_draft')).called(1);
      });

      test('returns null if no draft exists', () async {
        when(mockSharedPreferences.getString('workout_draft'))
            .thenReturn(null);

        final draft = await repository.loadDraft();

        expect(draft, isNull);
      });
    });
  });
}