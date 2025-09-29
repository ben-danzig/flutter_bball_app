// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrillTemplate _$DrillTemplateFromJson(Map<String, dynamic> json) =>
    DrillTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      defaultConfig: json['defaultConfig'] as Map<String, dynamic>,
      configOptions: (json['configOptions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, e as Map<String, dynamic>),
      ),
    );

Map<String, dynamic> _$DrillTemplateToJson(DrillTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'tags': instance.tags,
      'defaultConfig': instance.defaultConfig,
      'configOptions': instance.configOptions,
    };