import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/models/custom_workout_blueprint.dart';
import 'package:flutter_bball_app/models/drill.dart';

void main() {
  group('CustomWorkoutBlueprint', () {
    test('can be created with all required fields', () {
      final now = DateTime.now();
      final blueprint = CustomWorkoutBlueprint(
        id: 'custom_1',
        name: 'My Custom Workout',
        objective: 'Improve ball handling skills',
        estimatedDuration: 30,
        drills: [
          Drill(
            drillId: 'drill_1',
            name: 'Crossover Dribble',
            description: 'Practice crossover moves',
            type: 'TIMED',
            config: {'duration': 60, 'sets': 3},
          ),
        ],
        authorId: 'user123',
        createdAt: now,
        updatedAt: now,
        category: 'Ball Handling',
        difficulty: 'intermediate',
        tags: ['dribbling', 'fundamentals'],
        isPublic: false,
        likes: 0,
        version: 1,
      );

      expect(blueprint.id, 'custom_1');
      expect(blueprint.name, 'My Custom Workout');
      expect(blueprint.objective, 'Improve ball handling skills');
      expect(blueprint.estimatedDuration, 30);
      expect(blueprint.drills.length, 1);
      expect(blueprint.authorId, 'user123');
      expect(blueprint.createdAt, now);
      expect(blueprint.updatedAt, now);
      expect(blueprint.category, 'Ball Handling');
      expect(blueprint.difficulty, 'intermediate');
      expect(blueprint.tags, ['dribbling', 'fundamentals']);
      expect(blueprint.isPublic, false);
      expect(blueprint.likes, 0);
      expect(blueprint.version, 1);
    });

    test('can be serialized to and from JSON', () {
      final now = DateTime.now();
      final blueprint = CustomWorkoutBlueprint(
        id: 'custom_2',
        name: 'Shooting Practice',
        objective: 'Improve shooting accuracy',
        estimatedDuration: 45,
        drills: [
          Drill(
            drillId: 'drill_2',
            name: 'Free Throws',
            description: 'Practice free throw shots',
            type: 'MAKE_TARGET',
            config: {'targetMakes': 10, 'sets': 5},
          ),
        ],
        authorId: 'user456',
        createdAt: now,
        updatedAt: now,
        category: 'Shooting',
        difficulty: 'beginner',
        tags: ['shooting', 'accuracy'],
        isPublic: true,
        likes: 5,
        version: 2,
      );

      // Convert to JSON and back
      final json = blueprint.toJson();
      final decoded = CustomWorkoutBlueprint.fromJson(json);

      expect(decoded.id, blueprint.id);
      expect(decoded.name, blueprint.name);
      expect(decoded.objective, blueprint.objective);
      expect(decoded.estimatedDuration, blueprint.estimatedDuration);
      expect(decoded.drills.length, blueprint.drills.length);
      expect(decoded.authorId, blueprint.authorId);
      expect(decoded.createdAt.millisecondsSinceEpoch, 
             blueprint.createdAt.millisecondsSinceEpoch);
      expect(decoded.updatedAt.millisecondsSinceEpoch, 
             blueprint.updatedAt.millisecondsSinceEpoch);
      expect(decoded.category, blueprint.category);
      expect(decoded.difficulty, blueprint.difficulty);
      expect(decoded.tags, blueprint.tags);
      expect(decoded.isPublic, blueprint.isPublic);
      expect(decoded.likes, blueprint.likes);
      expect(decoded.version, blueprint.version);
    });

    test('validates difficulty level', () {
      final now = DateTime.now();
      
      // Valid difficulty levels
      final validDifficulties = ['beginner', 'intermediate', 'advanced', 'expert'];
      
      for (final difficulty in validDifficulties) {
        expect(
          () => CustomWorkoutBlueprint(
            id: 'test',
            name: 'Test',
            objective: 'Test',
            estimatedDuration: 30,
            drills: [],
            authorId: 'user',
            createdAt: now,
            updatedAt: now,
            category: 'Test',
            difficulty: difficulty,
            tags: [],
            isPublic: false,
            likes: 0,
            version: 1,
          ),
          returnsNormally,
        );
      }
    });

    test('validates workout name length', () {
      final now = DateTime.now();
      
      // Test minimum length (3 characters)
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'AB',  // Too short
          objective: 'Test',
          estimatedDuration: 30,
          drills: [],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Test maximum length (50 characters)
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'A' * 51,  // Too long
          objective: 'Test',
          estimatedDuration: 30,
          drills: [],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Valid name
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Valid Workout Name',
          objective: 'Test',
          estimatedDuration: 30,
          drills: [],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        returnsNormally,
      );
    });

    test('validates duration constraints', () {
      final now = DateTime.now();
      
      // Test minimum duration (5 minutes)
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 4,  // Too short
          drills: [],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Test maximum duration (120 minutes)
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 121,  // Too long
          drills: [],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Valid duration
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 30,
          drills: [],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        returnsNormally,
      );
    });

    test('validates drills list constraints', () {
      final now = DateTime.now();
      final drill = Drill(
        drillId: 'drill_1',
        name: 'Test Drill',
        description: 'Test description',
        type: 'TIMED',
        config: {'duration': 60},
      );
      
      // Must have at least 1 drill
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 30,
          drills: [],  // Empty drills
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Cannot exceed 20 drills
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 30,
          drills: List.generate(21, (_) => drill),  // Too many drills
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Valid number of drills
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 30,
          drills: [drill],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        returnsNormally,
      );
    });

    test('validates tags constraints', () {
      final now = DateTime.now();
      final drill = Drill(
        drillId: 'drill_1',
        name: 'Test Drill',
        description: 'Test description',
        type: 'TIMED',
        config: {'duration': 60},
      );
      
      // Cannot exceed 10 tags
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 30,
          drills: [drill],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: List.generate(11, (i) => 'tag$i'),  // Too many tags
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Tags must be non-empty
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 30,
          drills: [drill],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: ['valid', ''],  // Empty tag
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Valid tags
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 30,
          drills: [drill],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Test',
          difficulty: 'beginner',
          tags: ['shooting', 'fundamentals'],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        returnsNormally,
      );
    });

    test('copyWith creates new instance with updated fields', () {
      final now = DateTime.now();
      final original = CustomWorkoutBlueprint(
        id: 'custom_1',
        name: 'Original Workout',
        objective: 'Original objective',
        estimatedDuration: 30,
        drills: [
          Drill(
            drillId: 'drill_1',
            name: 'Original Drill',
            description: 'Original description',
            type: 'TIMED',
            config: {'duration': 60},
          ),
        ],
        authorId: 'user123',
        createdAt: now,
        updatedAt: now,
        category: 'Ball Handling',
        difficulty: 'beginner',
        tags: ['original'],
        isPublic: false,
        likes: 0,
        version: 1,
      );

      final updated = original.copyWith(
        name: 'Updated Workout',
        difficulty: 'intermediate',
        tags: ['updated', 'modified'],
        likes: 10,
        version: 2,
      );

      // Check that specified fields are updated
      expect(updated.name, 'Updated Workout');
      expect(updated.difficulty, 'intermediate');
      expect(updated.tags, ['updated', 'modified']);
      expect(updated.likes, 10);
      expect(updated.version, 2);

      // Check that unspecified fields remain the same
      expect(updated.id, original.id);
      expect(updated.objective, original.objective);
      expect(updated.estimatedDuration, original.estimatedDuration);
      expect(updated.drills, original.drills);
      expect(updated.authorId, original.authorId);
      expect(updated.createdAt, original.createdAt);
      expect(updated.category, original.category);
      expect(updated.isPublic, original.isPublic);
    });

    test('validates category from predefined list', () {
      final now = DateTime.now();
      final drill = Drill(
        drillId: 'drill_1',
        name: 'Test Drill',
        description: 'Test description',
        type: 'TIMED',
        config: {'duration': 60},
      );
      
      // Valid categories
      final validCategories = [
        'Ball Handling',
        'Shooting',
        'Defense',
        'Passing',
        'Conditioning',
        'Footwork',
        'Rebounding',
        'Mental Training',
        'Game Situations',
        'Mixed Skills'
      ];
      
      for (final category in validCategories) {
        expect(
          () => CustomWorkoutBlueprint(
            id: 'test',
            name: 'Test Workout',
            objective: 'Test',
            estimatedDuration: 30,
            drills: [drill],
            authorId: 'user',
            createdAt: now,
            updatedAt: now,
            category: category,
            difficulty: 'beginner',
            tags: [],
            isPublic: false,
            likes: 0,
            version: 1,
          ),
          returnsNormally,
        );
      }

      // Invalid category
      expect(
        () => CustomWorkoutBlueprint(
          id: 'test',
          name: 'Test Workout',
          objective: 'Test',
          estimatedDuration: 30,
          drills: [drill],
          authorId: 'user',
          createdAt: now,
          updatedAt: now,
          category: 'Invalid Category',
          difficulty: 'beginner',
          tags: [],
          isPublic: false,
          likes: 0,
          version: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}