// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutBlueprint _$WorkoutBlueprintFromJson(Map<String, dynamic> json) =>
    WorkoutBlueprint(
      id: json['id'] as String,
      name: json['name'] as String,
      objective: json['objective'] as String,
      estimatedDuration: (json['estimatedDuration'] as num).toInt(),
      drills: (json['drills'] as List<dynamic>)
          .map((e) => Drill.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutBlueprintToJson(WorkoutBlueprint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'objective': instance.objective,
      'estimatedDuration': instance.estimatedDuration,
      'drills': instance.drills.map((e) => e.toJson()).toList(),
    };
