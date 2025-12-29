import 'package:vbstats/domain/entities/enums.dart';
import 'package:vbstats/domain/entities/match_entities.dart';

/// Computes stats aggregates and ratios for a set
class SetStatsComputer {
  final List<Rally> rallies;

  SetStatsComputer(this.rallies);

  /// Count outcomes where we won
  int countAces() => rallies
      .where((r) => r.outcome == RallyOutcome.ace && r.weWon)
      .length;

  int countKills() => rallies
      .where((r) => r.outcome == RallyOutcome.kill && r.weWon)
      .length;

  int countBlocks() => rallies
      .where((r) => r.outcome == RallyOutcome.block && r.weWon)
      .length;

  int countOpponentErrors() => rallies
      .where((r) =>
          (r.outcome == RallyOutcome.opponentError ||
              r.outcome == RallyOutcome.opponentFault) &&
          r.weWon)
      .length;

  /// Count outcomes where opponent won
  int countServeErrors() =>
      rallies.where((r) => r.outcome == RallyOutcome.serveError && !r.weWon).length;

  int countReceiveErrors() =>
      rallies.where((r) => r.outcome == RallyOutcome.receiveError && !r.weWon).length;

  int countBlockErrors() =>
      rallies.where((r) => r.outcome == RallyOutcome.blockError && !r.weWon).length;

  int countDigErrors() =>
      rallies.where((r) => r.outcome == RallyOutcome.digError && !r.weWon).length;

  int countCoverErrors() =>
      rallies.where((r) => r.outcome == RallyOutcome.coverError && !r.weWon).length;

  int countRuleViolations() =>
      rallies.where((r) => r.outcome == RallyOutcome.ruleViolation && !r.weWon).length;

  int countFreeBallErrors() =>
      rallies.where((r) => r.outcome == RallyOutcome.freeBallError && !r.weWon).length;

  int countAttackErrors() =>
      rallies.where((r) => r.outcome == RallyOutcome.attackError && !r.weWon).length;

  /// Compute our total points (should match Set.ourScore)
  int getTotalOurPoints() =>
      countAces() +
      countKills() +
      countBlocks() +
      countOpponentErrors();

  /// Compute opponent total points (should match Set.oppScore)
  int getTotalOppPoints() =>
      countServeErrors() +
      countReceiveErrors() +
      countBlockErrors() +
      countDigErrors() +
      countCoverErrors() +
      countRuleViolations() +
      countFreeBallErrors() +
      countAttackErrors();

  /// Alias for getTotalOppPoints for consistency in UI
  int getTotalOpponentPoints() => getTotalOppPoints();

  /// Count other errors (not aces/kills/blocks for opponent)
  int countOurOtherErrors() =>
      countServeErrors() +
      countAttackErrors() +
      countBlockErrors() +
      countRuleViolations() +
      countFreeBallErrors();

  /// Sideout % across all rallies (not rotation-specific)
  double getSideoutPercentage() {
    final weLostInReceive =
        rallies.where((r) => !r.weWereServing && !r.weWon).length;
    final weWonInReceive =
        rallies.where((r) => !r.weWereServing && r.weWon).length;

    final totalInReceive = weLostInReceive + weWonInReceive;
    if (totalInReceive == 0) return 0;

    return (weWonInReceive / totalInReceive) * 100;
  }

  /// Get raw sideout counts (won, total)
  Map<String, int> getSideoutCounts() {
    final weLostInReceive =
        rallies.where((r) => !r.weWereServing && !r.weWon).length;
    final weWonInReceive =
        rallies.where((r) => !r.weWereServing && r.weWon).length;
    final totalInReceive = weLostInReceive + weWonInReceive;
    
    return {'won': weWonInReceive, 'total': totalInReceive};
  }

  /// Point-scoring % across all rallies
  double getPointScoringPercentage() {
    final weLostWhileServing =
        rallies.where((r) => r.weWereServing && !r.weWon).length;
    final weWonWhileServing =
        rallies.where((r) => r.weWereServing && r.weWon).length;

    final totalWhileServing = weLostWhileServing + weWonWhileServing;
    if (totalWhileServing == 0) return 0;

    return (weWonWhileServing / totalWhileServing) * 100;
  }

  /// Get raw point scoring counts (won, total)
  Map<String, int> getPointScoringCounts() {
    final weLostWhileServing =
        rallies.where((r) => r.weWereServing && !r.weWon).length;
    final weWonWhileServing =
        rallies.where((r) => r.weWereServing && r.weWon).length;
    final totalWhileServing = weLostWhileServing + weWonWhileServing;
    
    return {'won': weWonWhileServing, 'total': totalWhileServing};
  }

  /// Ace:Service Error ratio
  String getAceToServiceErrorRatio() {
    final aces = countAces();
    final serveErrors = countServeErrors();
    if (serveErrors == 0) return '—';
    return (aces / serveErrors).toStringAsFixed(2);
  }

  /// Ace:Receive Error ratio
  String getAceToReceiveErrorRatio() {
    final aces = countAces();
    final receiveErrors = countReceiveErrors();
    if (receiveErrors == 0) return '—';
    return (aces / receiveErrors).toStringAsFixed(2);
  }

  /// Kill:Attack Error ratio
  String getKillToAttackErrorRatio() {
    final kills = countKills();
    final attackErrors = countAttackErrors();
    if (attackErrors == 0) return '—';
    return (kills / attackErrors).toStringAsFixed(2);
  }

  /// Count 3+ point runs for us
  int countThreePlusPointRunsUs() {
    int runs = 0;
    int currentRun = 0;
    
    for (var rally in rallies) {
      if (rally.weWon) {
        currentRun++;
      } else {
        if (currentRun >= 3) {
          runs++;
        }
        currentRun = 0;
      }
    }
    // Check final run
    if (currentRun >= 3) {
      runs++;
    }
    return runs;
  }

  /// Count 3+ point runs for them
  int countThreePlusPointRunsThem() {
    int runs = 0;
    int currentRun = 0;
    
    for (var rally in rallies) {
      if (!rally.weWon) {
        currentRun++;
      } else {
        if (currentRun >= 3) {
          runs++;
        }
        currentRun = 0;
      }
    }
    // Check final run
    if (currentRun >= 3) {
      runs++;
    }
    return runs;
  }

  /// Points scored ratio (our points : their points)
  String getPointsRatio() {
    final ourPoints = getTotalOurPoints();
    final theirPoints = getTotalOpponentPoints();
    if (theirPoints == 0) return '—';
    return (ourPoints / theirPoints).toStringAsFixed(2);
  }

  // ===== Historical/Sparkline Data Methods =====

  /// Get sideout percentage history (after each rally)
  List<double> getSideoutPercentageHistory() {
    final history = <double>[];
    int weWonInReceive = 0;
    int totalInReceive = 0;

    for (var rally in rallies) {
      if (!rally.weWereServing) {
        totalInReceive++;
        if (rally.weWon) {
          weWonInReceive++;
        }
      }
      
      if (totalInReceive == 0) {
        history.add(0);
      } else {
        history.add((weWonInReceive / totalInReceive) * 100);
      }
    }
    
    return history;
  }

  /// Get point-scoring percentage history (after each rally)
  List<double> getPointScoringPercentageHistory() {
    final history = <double>[];
    int weWonWhileServing = 0;
    int totalWhileServing = 0;

    for (var rally in rallies) {
      if (rally.weWereServing) {
        totalWhileServing++;
        if (rally.weWon) {
          weWonWhileServing++;
        }
      }
      
      if (totalWhileServing == 0) {
        history.add(0);
      } else {
        history.add((weWonWhileServing / totalWhileServing) * 100);
      }
    }
    
    return history;
  }

  /// Get ace:serve error ratio history
  List<double> getAceToServiceErrorRatioHistory() {
    final history = <double>[];
    int aces = 0;
    int serveErrors = 0;

    for (var rally in rallies) {
      if (rally.outcome == RallyOutcome.ace && rally.weWon) {
        aces++;
      } else if (rally.outcome == RallyOutcome.serveError && !rally.weWon) {
        serveErrors++;
      }
      
      if (serveErrors == 0) {
        history.add(aces.toDouble());
      } else {
        history.add(aces / serveErrors);
      }
    }
    
    return history;
  }

  /// Get ace:receive error ratio history
  List<double> getAceToReceiveErrorRatioHistory() {
    final history = <double>[];
    int aces = 0;
    int receiveErrors = 0;

    for (var rally in rallies) {
      if (rally.outcome == RallyOutcome.ace && rally.weWon) {
        aces++;
      } else if (rally.outcome == RallyOutcome.receiveError && !rally.weWon) {
        receiveErrors++;
      }
      
      if (receiveErrors == 0) {
        history.add(aces.toDouble());
      } else {
        history.add(aces / receiveErrors);
      }
    }
    
    return history;
  }

  /// Get kill:attack error ratio history
  List<double> getKillToAttackErrorRatioHistory() {
    final history = <double>[];
    int kills = 0;
    int attackErrors = 0;

    for (var rally in rallies) {
      if (rally.outcome == RallyOutcome.kill && rally.weWon) {
        kills++;
      } else if (rally.outcome == RallyOutcome.attackError && !rally.weWon) {
        attackErrors++;
      }
      
      if (attackErrors == 0) {
        history.add(kills.toDouble());
      } else {
        history.add(kills / attackErrors);
      }
    }
    
    return history;
  }

  /// Get 3+ runs for us history (cumulative)
  List<double> getThreePlusRunsUsHistory() {
    final history = <double>[];
    int runs = 0;
    int currentRun = 0;

    for (var rally in rallies) {
      if (rally.weWon) {
        currentRun++;
      } else {
        if (currentRun >= 3) {
          runs++;
        }
        currentRun = 0;
      }
      history.add(runs.toDouble());
    }
    
    return history;
  }

  /// Get 3+ runs for them history (cumulative)
  List<double> getThreePlusRunsThemHistory() {
    final history = <double>[];
    int runs = 0;
    int currentRun = 0;

    for (var rally in rallies) {
      if (!rally.weWon) {
        currentRun++;
      } else {
        if (currentRun >= 3) {
          runs++;
        }
        currentRun = 0;
      }
      history.add(runs.toDouble());
    }
    
    return history;
  }

  /// Get points ratio history
  List<double> getPointsRatioHistory() {
    final history = <double>[];
    int ourPoints = 0;
    int theirPoints = 0;

    for (var rally in rallies) {
      if (rally.weWon) {
        ourPoints++;
      } else {
        theirPoints++;
      }
      
      if (theirPoints == 0) {
        history.add(ourPoints.toDouble());
      } else {
        history.add(ourPoints / theirPoints);
      }
    }
    
    return history;
  }

  /// Returns all stats as a map
  Map<String, dynamic> getStatsMap() => {
        'aces': countAces(),
        'kills': countKills(),
        'blocks': countBlocks(),
        'opponentErrors': countOpponentErrors(),
        'totalOurPoints': getTotalOurPoints(),
        'serveErrors': countServeErrors(),
        'receiveErrors': countReceiveErrors(),
        'blockErrors': countBlockErrors(),
        'digErrors': countDigErrors(),
        'coverErrors': countCoverErrors(),
        'ruleViolations': countRuleViolations(),
        'freeBallErrors': countFreeBallErrors(),
        'attackErrors': countAttackErrors(),
        'totalOppPoints': getTotalOppPoints(),
        'sideoutPercent': getSideoutPercentage(),
        'pointScoringPercent': getPointScoringPercentage(),
        'aceToServiceErrorRatio': getAceToServiceErrorRatio(),
        'aceToReceiveErrorRatio': getAceToReceiveErrorRatio(),
      };
}
