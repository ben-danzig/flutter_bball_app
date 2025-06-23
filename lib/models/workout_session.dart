import 'package:json_annotation/json_annotation.dart';
import 'drill_result.dart';
import 'workout_blueprint.dart';

part 'workout_session.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutSession {
  final String id;
  final WorkoutBlueprint workoutBlueprint;
  final List<DrillResult> results;
  final DateTime completedAt;
  final String? feeling;
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.workoutBlueprint,
    required this.results,
    required this.completedAt,
    this.feeling,
    this.notes,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);
}
