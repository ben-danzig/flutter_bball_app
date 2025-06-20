import 'package:json_annotation/json_annotation.dart';
import 'drill.dart';

part 'workout_blueprint.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutBlueprint {
  final String id;
  final String name;
  final String objective;
  final int estimatedDuration;
  final List<Drill> drills;

  WorkoutBlueprint({
    required this.id,
    required this.name,
    required this.objective,
    required this.estimatedDuration,
    required this.drills,
  });

  factory WorkoutBlueprint.fromJson(Map<String, dynamic> json) => _$WorkoutBlueprintFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutBlueprintToJson(this);
}