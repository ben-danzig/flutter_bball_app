// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    WorkoutSession(
      id: json['id'] as String,
      workoutBlueprint: WorkoutBlueprint.fromJson(
        json['workoutBlueprint'] as Map<String, dynamic>,
      ),
      results: (json['results'] as List<dynamic>)
          .map((e) => DrillResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      feeling: json['feeling'] as String?,
      notes: json['notes'] as String?,
      isPartial: json['isPartial'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkoutSessionToJson(WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workoutBlueprint': instance.workoutBlueprint.toJson(),
      'results': instance.results.map((e) => e.toJson()).toList(),
      'completedAt': instance.completedAt.toIso8601String(),
      'feeling': instance.feeling,
      'notes': instance.notes,
      'isPartial': instance.isPartial,
    };
