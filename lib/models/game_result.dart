class GameResult {
  final int gameNumber;
  final List<String> team1;
  final List<String> team2;
  final int? team1Score;
  final int? team2Score;
  final bool isCompleted;
  final DateTime? completedAt;

  GameResult({
    required this.gameNumber,
    required this.team1,
    required this.team2,
    this.team1Score,
    this.team2Score,
    this.isCompleted = false,
    this.completedAt,
  });

  GameResult copyWith({
    int? gameNumber,
    List<String>? team1,
    List<String>? team2,
    int? team1Score,
    int? team2Score,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return GameResult(
      gameNumber: gameNumber ?? this.gameNumber,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameNumber': gameNumber,
      'team1': team1,
      'team2': team2,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      gameNumber: json['gameNumber'],
      team1: List<String>.from(json['team1']),
      team2: List<String>.from(json['team2']),
      team1Score: json['team1Score'],
      team2Score: json['team2Score'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }
} 