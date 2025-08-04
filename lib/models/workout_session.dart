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
  final String? userId; // Made nullable to handle existing sessions

  WorkoutSession({
    required this.id,
    required this.workoutBlueprint,
    required this.results,
    required this.completedAt,
    this.feeling,
    this.notes,
    this.isPartial = false,
    required this.deviceId, // New param
    this.userId, // Made optional to handle existing sessions
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  // Helper method to get userId with fallback
  String get effectiveUserId => userId ?? 'legacy_user';
  
  // Helper method to create a copy with userId
  WorkoutSession copyWithUserId(String newUserId) {
    return WorkoutSession(
      id: id,
      workoutBlueprint: workoutBlueprint,
      results: results,
      completedAt: completedAt,
      feeling: feeling,
      notes: notes,
      isPartial: isPartial,
      deviceId: deviceId,
      userId: newUserId,
    );
  }
}
