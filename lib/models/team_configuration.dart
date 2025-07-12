import 'package:cloud_firestore/cloud_firestore.dart';

class TeamConfiguration {
  final String id;
  String name;
  final DateTime createdAt;
  final List<List<String>> teams; // List of teams, each team is a list of player IDs

  TeamConfiguration({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.teams,
  });

  factory TeamConfiguration.fromJson(Map<String, dynamic> json, String id) {
    return TeamConfiguration(
      id: id,
      name: json['name'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      teams: (json['teams'] as List)
          .map((team) => List<String>.from((team as Map<String, dynamic>)['players'] as List))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'teams': teams.map((team) => {'players': team}).toList(),
    };
  }
} 