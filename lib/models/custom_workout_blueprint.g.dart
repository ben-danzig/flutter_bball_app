// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_workout_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomWorkoutBlueprint _$CustomWorkoutBlueprintFromJson(
        Map<String, dynamic> json) =>
    CustomWorkoutBlueprint(
      id: json['id'] as String,
      name: json['name'] as String,
      objective: json['objective'] as String,
      estimatedDuration: (json['estimatedDuration'] as num).toInt(),
      drills: (json['drills'] as List<dynamic>)
          .map((e) => Drill.fromJson(e as Map<String, dynamic>))
          .toList(),
      authorId: json['authorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isPublic: json['isPublic'] as bool,
      likes: (json['likes'] as num).toInt(),
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$CustomWorkoutBlueprintToJson(
        CustomWorkoutBlueprint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'objective': instance.objective,
      'estimatedDuration': instance.estimatedDuration,
      'drills': instance.drills.map((e) => e.toJson()).toList(),
      'authorId': instance.authorId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'category': instance.category,
      'difficulty': instance.difficulty,
      'tags': instance.tags,
      'isPublic': instance.isPublic,
      'likes': instance.likes,
      'version': instance.version,
    };