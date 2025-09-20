import 'package:json_annotation/json_annotation.dart';

part 'drill_template.g.dart';

/// Represents a template for creating drills with predefined configurations
@JsonSerializable(explicitToJson: true)
class DrillTemplate {
  final String id;
  final String name;
  final String description;
  final String type; // TIMED, REP_BASED, MAKE_TARGET_TIMED, READ_AND_REACT
  final String category;
  final String difficulty; // beginner, intermediate, advanced
  final List<String> tags;
  final Map<String, dynamic> defaultConfig;
  final Map<String, Map<String, dynamic>> configOptions; // Configuration constraints

  DrillTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.tags,
    required this.defaultConfig,
    required this.configOptions,
  });

  factory DrillTemplate.fromJson(Map<String, dynamic> json) => 
      _$DrillTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$DrillTemplateToJson(this);

  /// Creates a copy of this template with optional overrides
  DrillTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? category,
    String? difficulty,
    List<String>? tags,
    Map<String, dynamic>? defaultConfig,
    Map<String, Map<String, dynamic>>? configOptions,
  }) {
    return DrillTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      defaultConfig: defaultConfig ?? this.defaultConfig,
      configOptions: configOptions ?? this.configOptions,
    );
  }
}