import 'package:vbstats/domain/entities/match_entities.dart';

/// Represents a single point on the momentum chart
class MomentumPoint {
  final int rallyIndex; // 0-based
  final int cumulativeScoreDiff; // positive = we're ahead, negative = opponent ahead
  final String outcome; // short code or label
  final bool weScored;
  final int rotation; // 1-6
  final bool weWereServing;

  MomentumPoint({
    required this.rallyIndex,
    required this.cumulativeScoreDiff,
    required this.outcome,
    required this.weScored,
    required this.rotation,
    required this.weWereServing,
  });
}

/// Represents a run of 3+ consecutive points in same direction
class MomentumRun {
  final int startIndex;
  final int endIndex;
  final bool isUp; // true for our points, false for opponent

  MomentumRun({
    required this.startIndex,
    required this.endIndex,
    required this.isUp,
  });

  int get length => endIndex - startIndex + 1;
}

class MomentumComputer {
  final List<Rally> rallies;

  MomentumComputer(this.rallies);

  /// Computes momentum points (chart data) for a set
  List<MomentumPoint> computeMomentumPoints() {
    final points = <MomentumPoint>[];
    int cumulativeScoreDiff = 0;

    for (int i = 0; i < rallies.length; i++) {
      final rally = rallies[i];
      if (rally.weWon) {
        cumulativeScoreDiff++;
      } else {
        cumulativeScoreDiff--;
      }

      points.add(MomentumPoint(
        rallyIndex: i,
        cumulativeScoreDiff: cumulativeScoreDiff,
        outcome: rally.outcome.shortCode,
        weScored: rally.weWon,
        rotation: rally.rotationAtStart,
        weWereServing: rally.weWereServing,
      ));
    }

    return points;
  }

  /// Detects runs of 3+ consecutive points in same direction
  List<MomentumRun> detectRuns() {
    final points = computeMomentumPoints();
    final runs = <MomentumRun>[];

    if (points.isEmpty) return runs;

    int? currentRunStart;
    bool? currentRunIsUp;

    for (int i = 0; i < points.length; i++) {
      final isUp = points[i].weScored;

      if (currentRunStart == null) {
        currentRunStart = i;
        currentRunIsUp = isUp;
      } else if (isUp == currentRunIsUp) {
        // Continue current run
        continue;
      } else {
        // Direction changed; check if current run is 3+
        final runLength = i - currentRunStart;
        if (runLength >= 3) {
          runs.add(MomentumRun(
            startIndex: currentRunStart,
            endIndex: i - 1,
            isUp: currentRunIsUp!,
          ));
        }
        // Start new run
        currentRunStart = i;
        currentRunIsUp = isUp;
      }
    }

    // Check final run
    if (currentRunStart != null) {
      final runLength = points.length - currentRunStart;
      if (runLength >= 3) {
        runs.add(MomentumRun(
          startIndex: currentRunStart,
          endIndex: points.length - 1,
          isUp: currentRunIsUp!,
        ));
      }
    }

    return runs;
  }
}
