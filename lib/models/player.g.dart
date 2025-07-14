// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as String,
  name: json['name'] as String,
  registeredAt: DateTime.parse(json['registeredAt'] as String),
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'registeredAt': instance.registeredAt.toIso8601String(),
};
