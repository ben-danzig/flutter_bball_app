import 'package:json_annotation/json_annotation.dart';
import 'workout_blueprint.dart';
import 'drill.dart';

part 'custom_workout_blueprint.g.dart';

@JsonSerializable(explicitToJson: true)
class CustomWorkoutBlueprint extends WorkoutBlueprint {
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final String difficulty;
  final List<String> tags;
  final bool isPublic;
  final int likes;
  final int version;

  // Predefined categories
  static const List<String> validCategories = [
    'Ball Handling',
    'Shooting',
    'Defense',
    'Passing',
    'Conditioning',
    'Footwork',
    'Rebounding',
    'Mental Training',
    'Game Situations',
    'Mixed Skills'
  ];

  // Predefined difficulty levels
  static const List<String> validDifficulties = [
    'beginner',
    'intermediate',
    'advanced',
    'expert'
  ];

  CustomWorkoutBlueprint({
    required String id,
    required String name,
    required String objective,
    required int estimatedDuration,
    required List<Drill> drills,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.difficulty,
    required this.tags,
    required this.isPublic,
    required this.likes,
    required this.version,
  }) : super(
          id: id,
          name: name,
          objective: objective,
          estimatedDuration: estimatedDuration,
          drills: drills,
        ) {
    // Validate name length
    if (name.length < 3) {
      throw ArgumentError('Workout name must be at least 3 characters long');
    }
    if (name.length > 50) {
      throw ArgumentError('Workout name must not exceed 50 characters');
    }

    // Validate duration
    if (estimatedDuration < 5) {
      throw ArgumentError('Workout duration must be at least 5 minutes');
    }
    if (estimatedDuration > 120) {
      throw ArgumentError('Workout duration must not exceed 120 minutes');
    }

    // Validate drills
    if (drills.isEmpty) {
      throw ArgumentError('Workout must have at least 1 drill');
    }
    if (drills.length > 20) {
      throw ArgumentError('Workout must not exceed 20 drills');
    }

    // Validate difficulty
    if (!validDifficulties.contains(difficulty)) {
      throw ArgumentError('Invalid difficulty level. Must be one of: ${validDifficulties.join(', ')}');
    }

    // Validate category
    if (!validCategories.contains(category)) {
      throw ArgumentError('Invalid category. Must be one of: ${validCategories.join(', ')}');
    }

    // Validate tags
    if (tags.length > 10) {
      throw ArgumentError('Cannot have more than 10 tags');
    }
    if (tags.any((tag) => tag.isEmpty)) {
      throw ArgumentError('Tags must not be empty');
    }
  }

  factory CustomWorkoutBlueprint.fromJson(Map<String, dynamic> json) => 
      _$CustomWorkoutBlueprintFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CustomWorkoutBlueprintToJson(this);

  CustomWorkoutBlueprint copyWith({
    String? id,
    String? name,
    String? objective,
    int? estimatedDuration,
    List<Drill>? drills,
    String? authorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    String? difficulty,
    List<String>? tags,
    bool? isPublic,
    int? likes,
    int? version,
  }) {
    return CustomWorkoutBlueprint(
      id: id ?? this.id,
      name: name ?? this.name,
      objective: objective ?? this.objective,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      drills: drills ?? this.drills,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      likes: likes ?? this.likes,
      version: version ?? this.version,
    );
  }
}