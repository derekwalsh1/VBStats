// Serve/Receive state
enum ServeReceiveState {
  serve,
  receive;

  String get label => this == ServeReceiveState.serve ? 'Serving' : 'Receiving';
}

// Rally outcome enums
enum RallyOutcome {
  // We scored (won the rally)
  ace('Ace', 'A'),
  kill('Kill', 'K'),
  block('Block', 'B'),
  opponentError('Opponent Error', 'OE'),
  opponentFault('Opponent Fault', 'OF'),

  // We lost the rally (opponent scored)
  serveError('Serve Error', 'SE'),
  receiveError('Receive Error', 'RE'),
  blockError('Block Error (Tooled)', 'BE'),
  digError('Dig Error', 'DE'),
  coverError('Cover Error', 'CE'),
  ruleViolation('Fault', 'F'),
  freeBallError('Free Ball Error', 'FBE'),
  attackError('Attack Error', 'AE');

  final String label;
  final String shortCode;

  const RallyOutcome(this.label, this.shortCode);

  // Returns true if this outcome means we won the rally
  bool get weWon => [
        RallyOutcome.ace,
        RallyOutcome.kill,
        RallyOutcome.block,
        RallyOutcome.opponentError,
        RallyOutcome.opponentFault,
      ].contains(this);

  // Group outcomes by type for UI
  static List<RallyOutcome> get weScoredOutcomes => [
        RallyOutcome.ace,
        RallyOutcome.kill,
        RallyOutcome.block,
        RallyOutcome.opponentError,
        RallyOutcome.opponentFault,
      ];

  static List<RallyOutcome> get weLostOutcomes => [
        RallyOutcome.serveError,
        RallyOutcome.receiveError,
        RallyOutcome.blockError,
        RallyOutcome.digError,
        RallyOutcome.coverError,
        RallyOutcome.ruleViolation,
        RallyOutcome.freeBallError,
        RallyOutcome.attackError,
      ];
}
