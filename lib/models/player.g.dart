// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as String,
  name: json['name'] as String,
  registeredAt: DateTime.parse(json['registeredAt'] as String),
  preferredPartnerId: json['preferredPartnerId'] as String?,
  heightFeet: (json['heightFeet'] as num?)?.toInt(),
  heightInches: (json['heightInches'] as num?)?.toInt(),
  highestLevelPlayed: json['highestLevelPlayed'] as String?,
  layupAbility: json['layupAbility'] as String?,
  lastTimePlayed: json['lastTimePlayed'] as String?,
  additionalNotes: json['additionalNotes'] as String?,
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'registeredAt': instance.registeredAt.toIso8601String(),
  'preferredPartnerId': instance.preferredPartnerId,
  'heightFeet': instance.heightFeet,
  'heightInches': instance.heightInches,
  'highestLevelPlayed': instance.highestLevelPlayed,
  'layupAbility': instance.layupAbility,
  'lastTimePlayed': instance.lastTimePlayed,
  'additionalNotes': instance.additionalNotes,
};
