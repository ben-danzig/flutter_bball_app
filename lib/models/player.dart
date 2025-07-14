import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  final String id;
  final String name;
  final DateTime registeredAt;

  Player({
    required this.id,
    required this.name,
    required this.registeredAt,
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
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      registeredAt: registeredAt,
    );
  }
}