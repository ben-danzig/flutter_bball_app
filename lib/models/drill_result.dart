import 'package:json_annotation/json_annotation.dart';

part 'drill_result.g.dart';

@JsonSerializable()
class DrillResult {
  final String drillId;
  final int? makes;
  final int? elapsedSeconds;

  DrillResult({
    required this.drillId,
    this.makes,
    this.elapsedSeconds,
  });

  factory DrillResult.fromJson(Map<String, dynamic> json) => _$DrillResultFromJson(json);
  Map<String, dynamic> toJson() => _$DrillResultToJson(this);
}
