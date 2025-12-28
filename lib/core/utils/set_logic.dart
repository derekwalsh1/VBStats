import 'package:vbstats/domain/entities/enums.dart';
import 'package:vbstats/domain/entities/match_entities.dart';

/// Manages rotation state (1-6)
class RotationManager {
  static int advance(int currentRotation) {
    // Rotate from 1-6, wrap to 1
    return currentRotation == 6 ? 1 : currentRotation + 1;
  }

  static String getPositionName(int rotation) {
    const positions = ['RB', 'CB', 'RF', 'CF', 'LF', 'LB'];
    return positions[rotation - 1];
  }
}

/// Manages serve/receive state and rotation after each rally
class SetStateManager {
  final Set currentSet;
  int currentRotation;
  ServeReceiveState currentServeReceiveState;

  SetStateManager({
    required this.currentSet,
    required this.currentRotation,
    required this.currentServeReceiveState,
  });

  /// Updates serve/receive and rotation after a rally outcome
  void processRallyOutcome(RallyOutcome outcome) {
    final weWon = outcome.weWon;

    if (currentServeReceiveState == ServeReceiveState.serve) {
      if (weWon) {
        // We won while serving: stay serving, no rotation
        // currentServeReceiveState = ServeReceiveState.serve;
        // No rotation change
      } else {
        // We lost while serving: switch to receive, no rotation
        currentServeReceiveState = ServeReceiveState.receive;
        // No rotation change
      }
    } else {
      // currentServeReceiveState == ServeReceiveState.receive
      if (weWon) {
        // We won while receiving (sideout): switch to serve, rotate
        currentServeReceiveState = ServeReceiveState.serve;
        currentRotation = RotationManager.advance(currentRotation);
      } else {
        // We lost while receiving: stay receiving, no rotation
        // currentServeReceiveState = ServeReceiveState.receive;
        // No rotation change
      }
    }
  }

  /// Returns next rotation without modifying state
  int peekNextRotation() {
    if (currentServeReceiveState == ServeReceiveState.receive) {
      return RotationManager.advance(currentRotation);
    }
    return currentRotation;
  }
}

/// Computes rotation-aware stats for a set
class RotationStatsComputer {
  final List<Rally> rallies;

  RotationStatsComputer(this.rallies);

  /// Returns sideout % for a given rotation
  /// Sideout % = rallies we start in receive AND win / all rallies we start in receive
  double getSideoutPercentage(int rotation) {
    final weLostInReceive = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        !r.weWereServing &&
        !r.weWon);
    final weWonInReceive = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        !r.weWereServing &&
        r.weWon);

    final totalInReceive = weLostInReceive.length + weWonInReceive.length;
    if (totalInReceive == 0) return 0;

    return (weWonInReceive.length / totalInReceive) * 100;
  }

  /// Get raw sideout counts for a rotation (won, total)
  Map<String, int> getSideoutCounts(int rotation) {
    final weLostInReceive = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        !r.weWereServing &&
        !r.weWon);
    final weWonInReceive = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        !r.weWereServing &&
        r.weWon);
    final totalInReceive = weLostInReceive.length + weWonInReceive.length;
    
    return {'won': weWonInReceive.length, 'total': totalInReceive};
  }

  /// Returns point-scoring % for a given rotation
  /// Point-scoring % = rallies we start serving AND win / all rallies we start serving
  double getPointScoringPercentage(int rotation) {
    final weLostWhileServing = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        r.weWereServing &&
        !r.weWon);
    final weWonWhileServing = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        r.weWereServing &&
        r.weWon);

    final totalWhileServing = weLostWhileServing.length + weWonWhileServing.length;
    if (totalWhileServing == 0) return 0;

    return (weWonWhileServing.length / totalWhileServing) * 100;
  }

  /// Get raw point scoring counts for a rotation (won, total)
  Map<String, int> getPointScoringCounts(int rotation) {
    final weLostWhileServing = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        r.weWereServing &&
        !r.weWon);
    final weWonWhileServing = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        r.weWereServing &&
        r.weWon);
    final totalWhileServing = weLostWhileServing.length + weWonWhileServing.length;
    
    return {'won': weWonWhileServing.length, 'total': totalWhileServing};
  }

  /// Returns opponent's sideout % for a given rotation
  /// Opponent Sideout % = when they're receiving (we're serving) and they win / all rallies where we're serving
  double getOpponentSideoutPercentage(int rotation) {
    final weWonWhileServing = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        r.weWereServing &&
        r.weWon);
    final weLostWhileServing = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        r.weWereServing &&
        !r.weWon);

    final totalWhileServing = weWonWhileServing.length + weLostWhileServing.length;
    if (totalWhileServing == 0) return 0;

    return (weLostWhileServing.length / totalWhileServing) * 100;
  }

  /// Get raw opponent sideout counts for a rotation (won, total)
  Map<String, int> getOpponentSideoutCounts(int rotation) {
    final weWonWhileServing = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        r.weWereServing &&
        r.weWon);
    final weLostWhileServing = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        r.weWereServing &&
        !r.weWon);
    final totalWhileServing = weWonWhileServing.length + weLostWhileServing.length;
    
    return {'won': weLostWhileServing.length, 'total': totalWhileServing};
  }

  /// Returns opponent's point-scoring % for a given rotation
  /// Opponent Point-scoring % = when they're serving (we're receiving) and they win / all rallies where they're serving
  double getOpponentPointScoringPercentage(int rotation) {
    final weLostInReceive = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        !r.weWereServing &&
        !r.weWon);
    final weWonInReceive = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        !r.weWereServing &&
        r.weWon);

    final totalInReceive = weLostInReceive.length + weWonInReceive.length;
    if (totalInReceive == 0) return 0;

    return (weLostInReceive.length / totalInReceive) * 100;
  }

  /// Get raw opponent point scoring counts for a rotation (won, total)
  Map<String, int> getOpponentPointScoringCounts(int rotation) {
    final weLostInReceive = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        !r.weWereServing &&
        !r.weWon);
    final weWonInReceive = rallies.where((r) =>
        r.rotationAtStart == rotation &&
        !r.weWereServing &&
        r.weWon);
    final totalInReceive = weLostInReceive.length + weWonInReceive.length;
    
    return {'won': weLostInReceive.length, 'total': totalInReceive};
  }

  /// Returns map of rotation -> sideout %
  Map<int, double> getAllSideoutPercentages() {
    final map = <int, double>{};
    for (int i = 1; i <= 6; i++) {
      map[i] = getSideoutPercentage(i);
    }
    return map;
  }

  /// Returns map of rotation -> point-scoring %
  Map<int, double> getAllPointScoringPercentages() {
    final map = <int, double>{};
    for (int i = 1; i <= 6; i++) {
      map[i] = getPointScoringPercentage(i);
    }
    return map;
  }
}
