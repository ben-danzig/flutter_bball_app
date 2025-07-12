import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  final String id;
  final String name;
  final DateTime registeredAt;
  
  // Questionnaire data
  final String? preferredPartnerId;
  final int? heightFeet;
  final int? heightInches;
  final String? highestLevelPlayed;
  final String? layupAbility;
  final String? lastTimePlayed;
  final String? additionalNotes;

  Player({
    required this.id,
    required this.name,
    required this.registeredAt,
    this.preferredPartnerId,
    this.heightFeet,
    this.heightInches,
    this.highestLevelPlayed,
    this.layupAbility,
    this.lastTimePlayed,
    this.additionalNotes,
  });

  /// Factory constructor for creating a new player with auto-generated ID
  factory Player.create({required String name}) {
    return Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      registeredAt: DateTime.now(),
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  /// Creates a copy of the player with updated fields
  Player copyWith({
    String? name,
    String? preferredPartnerId,
    int? heightFeet,
    int? heightInches,
    String? highestLevelPlayed,
    String? layupAbility,
    String? lastTimePlayed,
    String? additionalNotes,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      registeredAt: registeredAt,
      preferredPartnerId: preferredPartnerId ?? this.preferredPartnerId,
      heightFeet: heightFeet ?? this.heightFeet,
      heightInches: heightInches ?? this.heightInches,
      highestLevelPlayed: highestLevelPlayed ?? this.highestLevelPlayed,
      layupAbility: layupAbility ?? this.layupAbility,
      lastTimePlayed: lastTimePlayed ?? this.lastTimePlayed,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }

  /// Get total height in inches
  int? get totalHeightInches {
    if (heightFeet == null || heightInches == null) return null;
    return (heightFeet! * 12) + heightInches!;
  }

  /// Check if player has completed questionnaire
  bool get hasCompletedQuestionnaire {
    return heightFeet != null && 
           heightInches != null && 
           highestLevelPlayed != null && 
           layupAbility != null && 
           lastTimePlayed != null;
  }
}