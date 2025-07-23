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
  final bool isPartial;
  final String deviceId; // New field
  final String userId; // New field for user identification

  WorkoutSession({
    required this.id,
    required this.workoutBlueprint,
    required this.results,
    required this.completedAt,
    this.feeling,
    this.notes,
    this.isPartial = false,
    required this.deviceId, // New param
    required this.userId, // New param
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);
}
