class Tournament {
  final String id;
  final String name;
  final String teamConfigId;
  final DateTime createdAt;
  final Map<String, dynamic>? teamConfigSnapshot;

  Tournament({
    required this.id,
    required this.name,
    required this.teamConfigId,
    required this.createdAt,
    this.teamConfigSnapshot,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teamConfigId': teamConfigId,
      'createdAt': createdAt.toIso8601String(),
      'teamConfigSnapshot': teamConfigSnapshot,
    };
  }

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      teamConfigId: json['teamConfigId'],
      createdAt: DateTime.parse(json['createdAt']),
      teamConfigSnapshot: json['teamConfigSnapshot'],
    );
  }
} 