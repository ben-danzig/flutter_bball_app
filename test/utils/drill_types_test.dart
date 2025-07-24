import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/utils/drill_types.dart';
import 'package:flutter_bball_app/models/drill.dart';

void main() {
  group('DrillTypes', () {
    test('should have correct constant values', () {
      expect(DrillTypes.timed, 'TIMED');
      expect(DrillTypes.repBased, 'REP_BASED');
      expect(DrillTypes.makeTargetTimed, 'MAKE_TARGET_TIMED');
      expect(DrillTypes.readAndReact, 'READ_AND_REACT');
    });

    test('should include all drill types in all list', () {
      expect(DrillTypes.all, hasLength(4));
      expect(DrillTypes.all, contains(DrillTypes.timed));
      expect(DrillTypes.all, contains(DrillTypes.repBased));
      expect(DrillTypes.all, contains(DrillTypes.makeTargetTimed));
      expect(DrillTypes.all, contains(DrillTypes.readAndReact));
    });
  });

  group('DrillTypeUtils', () {
    group('fromString', () {
      test('should convert valid string types to DrillType enum', () {
        expect(DrillTypeUtils.fromString('TIMED'), DrillType.timed);
        expect(DrillTypeUtils.fromString('REP_BASED'), DrillType.repBased);
        expect(DrillTypeUtils.fromString('MAKE_TARGET_TIMED'), DrillType.makeTargetTimed);
        expect(DrillTypeUtils.fromString('READ_AND_REACT'), DrillType.readAndReact);
      });

      test('should be case insensitive', () {
        expect(DrillTypeUtils.fromString('timed'), DrillType.timed);
        expect(DrillTypeUtils.fromString('rep_based'), DrillType.repBased);
        expect(DrillTypeUtils.fromString('make_target_timed'), DrillType.makeTargetTimed);
        expect(DrillTypeUtils.fromString('read_and_react'), DrillType.readAndReact);
      });

      test('should return null for invalid or null input', () {
        expect(DrillTypeUtils.fromString(null), isNull);
        expect(DrillTypeUtils.fromString(''), isNull);
        expect(DrillTypeUtils.fromString('INVALID_TYPE'), isNull);
        expect(DrillTypeUtils.fromString('unknown'), isNull);
      });
    });

    group('typeToString', () {
      test('should convert DrillType enum to string', () {
        expect(DrillTypeUtils.typeToString(DrillType.timed), 'TIMED');
        expect(DrillTypeUtils.typeToString(DrillType.repBased), 'REP_BASED');
        expect(DrillTypeUtils.typeToString(DrillType.makeTargetTimed), 'MAKE_TARGET_TIMED');
        expect(DrillTypeUtils.typeToString(DrillType.readAndReact), 'READ_AND_REACT');
      });
    });

    group('fromDrill', () {
      test('should extract DrillType from Drill model', () {
        final timedDrill = Drill(
          drillId: '1',
          name: 'Test Drill',
          description: 'Test',
          type: 'TIMED',
          config: {},
        );
        expect(DrillTypeUtils.fromDrill(timedDrill), DrillType.timed);

        final repBasedDrill = Drill(
          drillId: '2',
          name: 'Rep Drill',
          description: 'Test',
          type: 'REP_BASED',
          config: {},
        );
        expect(DrillTypeUtils.fromDrill(repBasedDrill), DrillType.repBased);
      });

      test('should return null for null drill or invalid type', () {
        expect(DrillTypeUtils.fromDrill(null), isNull);
        
        final invalidDrill = Drill(
          drillId: '1',
          name: 'Invalid Drill',
          description: 'Test',
          type: 'INVALID_TYPE',
          config: {},
        );
        expect(DrillTypeUtils.fromDrill(invalidDrill), isNull);
      });
    });

    group('hasPrimaryAction', () {
      test('should return true for drill types with primary actions', () {
        expect(DrillTypeUtils.hasPrimaryAction(DrillType.makeTargetTimed), isTrue);
        expect(DrillTypeUtils.hasPrimaryAction(DrillType.repBased), isTrue);
      });

      test('should return false for drill types without primary actions', () {
        expect(DrillTypeUtils.hasPrimaryAction(DrillType.timed), isFalse);
        expect(DrillTypeUtils.hasPrimaryAction(DrillType.readAndReact), isFalse);
        expect(DrillTypeUtils.hasPrimaryAction(null), isFalse);
      });
    });

    group('getPrimaryActionText', () {
      test('should return correct text for drill types with actions', () {
        expect(DrillTypeUtils.getPrimaryActionText(DrillType.makeTargetTimed), 'FINISH DRILL');
        expect(DrillTypeUtils.getPrimaryActionText(DrillType.repBased), 'LOG SET');
      });

      test('should return null for drill types without actions', () {
        expect(DrillTypeUtils.getPrimaryActionText(DrillType.timed), isNull);
        expect(DrillTypeUtils.getPrimaryActionText(DrillType.readAndReact), isNull);
      });
    });

    group('getPrimaryActionColor', () {
      test('should return correct colors for drill types with actions', () {
        expect(DrillTypeUtils.getPrimaryActionColor(DrillType.makeTargetTimed), 0xFF10B981); // Green
        expect(DrillTypeUtils.getPrimaryActionColor(DrillType.repBased), 0xFF3B82F6); // Blue
      });

      test('should return null for drill types without actions', () {
        expect(DrillTypeUtils.getPrimaryActionColor(DrillType.timed), isNull);
        expect(DrillTypeUtils.getPrimaryActionColor(DrillType.readAndReact), isNull);
      });
    });

    group('needsCompletionState', () {
      test('should return true for drill types needing completion tracking', () {
        expect(DrillTypeUtils.needsCompletionState(DrillType.makeTargetTimed), isTrue);
      });

      test('should return false for drill types not needing completion tracking', () {
        expect(DrillTypeUtils.needsCompletionState(DrillType.repBased), isFalse);
        expect(DrillTypeUtils.needsCompletionState(DrillType.timed), isFalse);
        expect(DrillTypeUtils.needsCompletionState(DrillType.readAndReact), isFalse);
      });
    });
  });
} 