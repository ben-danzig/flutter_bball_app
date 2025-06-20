import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/models/workout_blueprint.dart';

void main() {
  test('WorkoutBlueprint can be deserialized from JSON', () {
    // 1. The Input JSON from the previous step
    const workoutJsonString = '''
    {
      "id": "foundational_ball_control_and_finishing",
      "name": "Foundational Ball Control & Finishing",
      "objective": "Develop adaptable dribble control and master finishing through contact and in chaotic situations.",
      "estimatedDuration": 25,
      "drills": [
        {
          "drillId": "off_hand_freestyle",
          "name": "Off-Hand Freestyle",
          "description": "Dribble continuously with your weak hand, using any moves you want. Stay low and keep your eyes up.",
          "type": "TIMED",
          "config": { "sets": 2, "duration": 60 }
        },
        {
          "drillId": "finishers_gauntlet",
          "name": "The Finisher's Gauntlet",
          "description": "Make 20 layups from various angles around the hoop as quickly as you can. The clock stops when you hit 20 makes.",
          "type": "MAKE_TARGET_TIMED",
          "config": { "targetMakes": 20 }
        }
      ]
    }
    ''';

    // 2. Decode the JSON string into a Map
    final Map<String, dynamic> jsonMap = jsonDecode(workoutJsonString);

    // 3. Create the WorkoutBlueprint object using our factory
    final blueprint = WorkoutBlueprint.fromJson(jsonMap);

    // 4. Assert and Validate
    expect(blueprint.id, 'foundational_ball_control_and_finishing');
    expect(blueprint.name, 'Foundational Ball Control & Finishing');
    expect(blueprint.drills.length, 2);
    expect(blueprint.drills[0].name, 'Off-Hand Freestyle');
    expect(blueprint.drills[0].type, 'TIMED');
    expect(blueprint.drills[1].config['targetMakes'], 20);
  });
}