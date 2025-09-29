import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_bball_app/services/drill_library_service.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/drill_template.dart';

@GenerateMocks([DrillLibraryService])
void main() {
  group('DrillLibraryService', () {
    late DrillLibraryService service;
    late List<DrillTemplate> testTemplates;

    setUp(() {
      service = DrillLibraryService();
      
      // Create test drill templates
      testTemplates = [
        DrillTemplate(
          id: 'template_1',
          name: 'Basic Dribbling',
          description: 'Basic dribbling practice',
          type: 'TIMED',
          category: 'Ball Handling',
          difficulty: 'beginner',
          tags: ['dribbling', 'basics'],
          defaultConfig: {'duration': 60, 'sets': 3},
          configOptions: {
            'duration': {'min': 30, 'max': 300, 'step': 15},
            'sets': {'min': 1, 'max': 5, 'step': 1},
          },
        ),
        DrillTemplate(
          id: 'template_2',
          name: 'Free Throw Practice',
          description: 'Practice free throws',
          type: 'REP_BASED',
          category: 'Shooting',
          difficulty: 'beginner',
          tags: ['shooting', 'free throws'],
          defaultConfig: {'targetMakes': 10, 'sets': 5},
          configOptions: {
            'targetMakes': {'min': 5, 'max': 50, 'step': 5},
            'sets': {'min': 1, 'max': 10, 'step': 1},
          },
        ),
        DrillTemplate(
          id: 'template_3',
          name: 'Layup Challenge',
          description: 'Make layups as fast as possible',
          type: 'MAKE_TARGET_TIMED',
          category: 'Finishing',
          difficulty: 'intermediate',
          tags: ['finishing', 'layups', 'speed'],
          defaultConfig: {'targetMakes': 20},
          configOptions: {
            'targetMakes': {'min': 10, 'max': 50, 'step': 5},
          },
        ),
        DrillTemplate(
          id: 'template_4',
          name: 'Wing Decision Making',
          description: 'React to cues from the wing',
          type: 'READ_AND_REACT',
          category: 'Game Situations',
          difficulty: 'advanced',
          tags: ['decision making', 'reaction'],
          defaultConfig: {'reps': 10, 'intervalSeconds': 15},
          configOptions: {
            'reps': {'min': 5, 'max': 20, 'step': 1},
            'intervalSeconds': {'min': 10, 'max': 30, 'step': 5},
          },
        ),
        DrillTemplate(
          id: 'template_5',
          name: 'Advanced Ball Control',
          description: 'Complex dribbling combinations',
          type: 'TIMED',
          category: 'Ball Handling',
          difficulty: 'advanced',
          tags: ['dribbling', 'advanced'],
          defaultConfig: {'duration': 120, 'sets': 2},
          configOptions: {
            'duration': {'min': 60, 'max': 300, 'step': 30},
            'sets': {'min': 1, 'max': 4, 'step': 1},
          },
        ),
      ];
    });

    group('getAllTemplates', () {
      test('returns all drill templates', () async {
        final templates = await service.getAllTemplates();
        
        expect(templates.length, greaterThan(0));
        expect(templates.every((t) => t.id.isNotEmpty), true);
        expect(templates.every((t) => t.name.isNotEmpty), true);
      });

      test('templates have valid drill types', () async {
        final templates = await service.getAllTemplates();
        final validTypes = ['TIMED', 'REP_BASED', 'MAKE_TARGET_TIMED', 'READ_AND_REACT'];
        
        expect(templates.every((t) => validTypes.contains(t.type)), true);
      });

      test('templates have valid categories', () async {
        final templates = await service.getAllTemplates();
        final validCategories = [
          'Ball Handling',
          'Shooting',
          'Finishing',
          'Defense',
          'Passing',
          'Conditioning',
          'Footwork',
          'Rebounding',
          'Game Situations',
        ];
        
        expect(templates.every((t) => validCategories.contains(t.category)), true);
      });
    });

    group('getTemplatesByCategory', () {
      test('returns templates for specific category', () async {
        // Initialize service with test templates
        service = DrillLibraryService(templates: testTemplates);
        
        final ballHandlingTemplates = await service.getTemplatesByCategory('Ball Handling');
        
        expect(ballHandlingTemplates.length, 2);
        expect(ballHandlingTemplates.every((t) => t.category == 'Ball Handling'), true);
      });

      test('returns empty list for non-existent category', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final templates = await service.getTemplatesByCategory('NonExistent');
        
        expect(templates, isEmpty);
      });
    });

    group('getTemplatesByType', () {
      test('returns templates for specific drill type', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final timedTemplates = await service.getTemplatesByType('TIMED');
        
        expect(timedTemplates.length, 2);
        expect(timedTemplates.every((t) => t.type == 'TIMED'), true);
      });

      test('returns empty list for invalid type', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final templates = await service.getTemplatesByType('INVALID_TYPE');
        
        expect(templates, isEmpty);
      });
    });

    group('searchTemplates', () {
      test('searches by name', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final results = await service.searchTemplates('dribbling');
        
        expect(results.length, 2);
        expect(results.every((t) => 
          t.name.toLowerCase().contains('dribbling') ||
          t.description.toLowerCase().contains('dribbling')), true);
      });

      test('searches by description', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final results = await service.searchTemplates('practice');
        
        expect(results.length, 2);
        expect(results.every((t) => 
          t.name.toLowerCase().contains('practice') ||
          t.description.toLowerCase().contains('practice')), true);
      });

      test('searches by tags', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final results = await service.searchTemplates('basics');
        
        expect(results.length, 1);
        expect(results[0].tags.contains('basics'), true);
      });

      test('returns empty list for no matches', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final results = await service.searchTemplates('xyz123notfound');
        
        expect(results, isEmpty);
      });

      test('handles case-insensitive search', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final results = await service.searchTemplates('DRIBBLING');
        
        expect(results.length, 2);
      });
    });

    group('filterTemplates', () {
      test('filters by multiple criteria', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final filtered = await service.filterTemplates(
          category: 'Ball Handling',
          difficulty: 'advanced',
        );
        
        expect(filtered.length, 1);
        expect(filtered[0].name, 'Advanced Ball Control');
      });

      test('filters by category only', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final filtered = await service.filterTemplates(category: 'Shooting');
        
        expect(filtered.length, 1);
        expect(filtered[0].category, 'Shooting');
      });

      test('filters by difficulty only', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final filtered = await service.filterTemplates(difficulty: 'beginner');
        
        expect(filtered.length, 2);
        expect(filtered.every((t) => t.difficulty == 'beginner'), true);
      });

      test('filters by type only', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final filtered = await service.filterTemplates(type: 'MAKE_TARGET_TIMED');
        
        expect(filtered.length, 1);
        expect(filtered[0].type, 'MAKE_TARGET_TIMED');
      });

      test('filters by tags', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final filtered = await service.filterTemplates(tags: ['finishing']);
        
        expect(filtered.length, 1);
        expect(filtered[0].tags.contains('finishing'), true);
      });

      test('returns all templates when no filters applied', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final filtered = await service.filterTemplates();
        
        expect(filtered.length, testTemplates.length);
      });
    });

    group('getTemplateById', () {
      test('returns template by ID', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final template = await service.getTemplateById('template_2');
        
        expect(template, isNotNull);
        expect(template!.id, 'template_2');
        expect(template.name, 'Free Throw Practice');
      });

      test('returns null for non-existent ID', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final template = await service.getTemplateById('non_existent');
        
        expect(template, isNull);
      });
    });

    group('createDrillFromTemplate', () {
      test('creates drill with default config', () async {
        service = DrillLibraryService(templates: testTemplates);
        final template = testTemplates[0];
        
        final drill = await service.createDrillFromTemplate(template);
        
        expect(drill.drillId, isNotEmpty);
        expect(drill.name, template.name);
        expect(drill.description, template.description);
        expect(drill.type, template.type);
        expect(drill.config, template.defaultConfig);
      });

      test('creates drill with custom config', () async {
        service = DrillLibraryService(templates: testTemplates);
        final template = testTemplates[0];
        final customConfig = {'duration': 90, 'sets': 2};
        
        final drill = await service.createDrillFromTemplate(
          template,
          customConfig: customConfig,
        );
        
        expect(drill.config, customConfig);
      });

      test('validates custom config against options', () async {
        service = DrillLibraryService(templates: testTemplates);
        final template = testTemplates[0];
        final invalidConfig = {'duration': 500, 'sets': 10}; // Exceeds max values
        
        expect(
          () => service.createDrillFromTemplate(template, customConfig: invalidConfig),
          throwsException,
        );
      });

      test('generates unique drill IDs', () async {
        service = DrillLibraryService(templates: testTemplates);
        final template = testTemplates[0];
        
        final drill1 = await service.createDrillFromTemplate(template);
        final drill2 = await service.createDrillFromTemplate(template);
        
        expect(drill1.drillId, isNot(equals(drill2.drillId)));
      });
    });

    group('getCategories', () {
      test('returns all unique categories', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final categories = await service.getCategories();
        
        expect(categories.length, 4);
        expect(categories.contains('Ball Handling'), true);
        expect(categories.contains('Shooting'), true);
        expect(categories.contains('Finishing'), true);
        expect(categories.contains('Game Situations'), true);
      });

      test('returns categories in alphabetical order', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final categories = await service.getCategories();
        final sorted = List<String>.from(categories)..sort();
        
        expect(categories, equals(sorted));
      });
    });

    group('getDrillTypes', () {
      test('returns all unique drill types', () async {
        service = DrillLibraryService(templates: testTemplates);
        
        final types = await service.getDrillTypes();
        
        expect(types.length, 4);
        expect(types.contains('TIMED'), true);
        expect(types.contains('REP_BASED'), true);
        expect(types.contains('MAKE_TARGET_TIMED'), true);
        expect(types.contains('READ_AND_REACT'), true);
      });
    });

    group('getDifficulties', () {
      test('returns all difficulty levels', () async {
        service = DrillLibraryService();
        
        final difficulties = await service.getDifficulties();
        
        expect(difficulties, ['beginner', 'intermediate', 'advanced']);
      });
    });

    group('validateDrillConfig', () {
      test('validates TIMED drill config', () async {
        service = DrillLibraryService();
        
        // Valid config
        expect(
          await service.validateDrillConfig('TIMED', {'duration': 60, 'sets': 3}),
          true,
        );
        
        // Missing required field
        expect(
          await service.validateDrillConfig('TIMED', {'duration': 60}),
          false,
        );
        
        // Invalid value type
        expect(
          await service.validateDrillConfig('TIMED', {'duration': '60', 'sets': 3}),
          false,
        );
      });

      test('validates REP_BASED drill config', () async {
        service = DrillLibraryService();
        
        // Valid config
        expect(
          await service.validateDrillConfig('REP_BASED', {'targetMakes': 10, 'sets': 5}),
          true,
        );
        
        // Missing required field
        expect(
          await service.validateDrillConfig('REP_BASED', {'targetMakes': 10}),
          false,
        );
      });

      test('validates MAKE_TARGET_TIMED drill config', () async {
        service = DrillLibraryService();
        
        // Valid config
        expect(
          await service.validateDrillConfig('MAKE_TARGET_TIMED', {'targetMakes': 20}),
          true,
        );
        
        // Missing required field
        expect(
          await service.validateDrillConfig('MAKE_TARGET_TIMED', {}),
          false,
        );
      });

      test('validates READ_AND_REACT drill config', () async {
        service = DrillLibraryService();
        
        // Valid config
        expect(
          await service.validateDrillConfig('READ_AND_REACT', {'reps': 10, 'intervalSeconds': 15}),
          true,
        );
        
        // Missing required field
        expect(
          await service.validateDrillConfig('READ_AND_REACT', {'reps': 10}),
          false,
        );
      });

      test('returns false for invalid drill type', () async {
        service = DrillLibraryService();
        
        expect(
          await service.validateDrillConfig('INVALID_TYPE', {'some': 'config'}),
          false,
        );
      });
    });

    group('getDefaultConfig', () {
      test('returns default config for each drill type', () async {
        service = DrillLibraryService();
        
        expect(
          await service.getDefaultConfig('TIMED'),
          {'duration': 60, 'sets': 1},
        );
        
        expect(
          await service.getDefaultConfig('REP_BASED'),
          {'targetMakes': 10, 'sets': 1},
        );
        
        expect(
          await service.getDefaultConfig('MAKE_TARGET_TIMED'),
          {'targetMakes': 10},
        );
        
        expect(
          await service.getDefaultConfig('READ_AND_REACT'),
          {'reps': 10, 'intervalSeconds': 20},
        );
      });

      test('returns empty map for invalid type', () async {
        service = DrillLibraryService();
        
        expect(
          await service.getDefaultConfig('INVALID_TYPE'),
          {},
        );
      });
    });
  });
}