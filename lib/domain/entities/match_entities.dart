import 'enums.dart';

class Match {
  final String id;
  final String opponentName;
  final String? eventName;
  final DateTime date;
  final DateTime createdAt;

  Match({
    required this.id,
    required this.opponentName,
    this.eventName,
    required this.date,
    required this.createdAt,
  });

  String get displayName => eventName ?? opponentName;
}

class Set {
  final String id;
  final String matchId;
  final int setIndex;
  final int startRotation; // 1-6
  final ServeReceiveState startServeReceiveState;
  final int ourScore;
  final int oppScore;
  final DateTime createdAt;

  Set({
    required this.id,
    required this.matchId,
    required this.setIndex,
    required this.startRotation,
    required this.startServeReceiveState,
    required this.ourScore,
    required this.oppScore,
    required this.createdAt,
  });

  bool get isComplete => ourScore > 0 || oppScore > 0;
  int get totalPoints => ourScore + oppScore;
}

class Rally {
  final String id;
  final String setId;
  final int rallyIndex;
  final int rotationAtStart; // 1-6
  final bool weWereServing;
  final RallyOutcome outcome;
  final bool weWon;
  final DateTime timestamp;

  Rally({
    required this.id,
    required this.setId,
    required this.rallyIndex,
    required this.rotationAtStart,
    required this.weWereServing,
    required this.outcome,
    required this.weWon,
    required this.timestamp,
  });
}
