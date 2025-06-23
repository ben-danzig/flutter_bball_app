// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrillResult _$DrillResultFromJson(Map<String, dynamic> json) => DrillResult(
  drillId: json['drillId'] as String,
  makes: (json['makes'] as num?)?.toInt(),
  elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$DrillResultToJson(DrillResult instance) =>
    <String, dynamic>{
      'drillId': instance.drillId,
      'makes': instance.makes,
      'elapsedSeconds': instance.elapsedSeconds,
    };
