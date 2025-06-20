// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Drill _$DrillFromJson(Map<String, dynamic> json) => Drill(
  drillId: json['drillId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: json['type'] as String,
  config: Map<String, int>.from(json['config'] as Map),
);

Map<String, dynamic> _$DrillToJson(Drill instance) => <String, dynamic>{
  'drillId': instance.drillId,
  'name': instance.name,
  'description': instance.description,
  'type': instance.type,
  'config': instance.config,
};
