import 'package:json_annotation/json_annotation.dart';

part 'drill.g.dart';

@JsonSerializable(explicitToJson: true)
class Drill {
  final String drillId;
  final String name;
  final String description;
  final String type;
  final Map<String, dynamic> config;

  Drill({
    required this.drillId,
    required this.name,
    required this.description,
    required this.type,
    required this.config,
  });

  factory Drill.fromJson(Map<String, dynamic> json) => _$DrillFromJson(json);
  Map<String, dynamic> toJson() => _$DrillToJson(this);
}