import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/domain/entities/enums.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/presentation/providers/live_set_provider.dart';
import 'package:vbstats/presentation/providers/match_providers.dart';
import 'package:vbstats/presentation/providers/color_scheme_provider.dart';
import 'package:vbstats/core/utils/stats_calculator.dart';
import 'package:vbstats/core/utils/set_logic.dart';
import 'package:vbstats/presentation/widgets/momentum_chart.dart';
import 'package:vbstats/presentation/widgets/sparkline.dart';
import 'package:vbstats/presentation/widgets/dot_sparkline.dart';

class LiveSetScreen extends ConsumerStatefulWidget {
  final Match match;
  final String setId;

  const LiveSetScreen({
    required this.match,
    required this.setId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<LiveSetScreen> createState() => _LiveSetScreenState();
}

class _LiveSetScreenState extends ConsumerState<LiveSetScreen> {
  bool _showingSixSevenOverlay = false;
  int? _lastOurScore;
  int? _lastOppScore;

  void _checkForSixSeven(int ourScore, int oppScore) {
    // Only show if we haven't seen this score before
    if (_lastOurScore == ourScore && _lastOppScore == oppScore) return;
    
    _lastOurScore = ourScore;
    _lastOppScore = oppScore;

    if ((ourScore == 6 && oppScore == 7) || (ourScore == 7 && oppScore == 6)) {
      if (!_showingSixSevenOverlay) {
        _showingSixSevenOverlay = true;
        _showSixSevenOverlay();
      }
    }
  }

  void _showSixSevenOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => const Center(
        child: Text(
          '🤷 🤷',
          style: TextStyle(fontSize: 120),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
        _showingSixSevenOverlay = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final liveSetState = ref.watch(liveSetProvider(widget.setId));

    if (liveSetState == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final set = liveSetState.set;
    final rallies = liveSetState.rallies;
    final statsComputer = SetStatsComputer(rallies);
    final rotationStats = RotationStatsComputer(rallies);

    // Check for 6-7 score
    _checkForSixSeven(set.ourScore, set.oppScore);

    return Scaffold(
      appBar: AppBar(
        title: Text('Set ${set.setIndex} - ${widget.match.opponentName}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Invalidate match sets provider to refresh scores
            ref.invalidate(matchSetsProvider(widget.match.id));
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _showColorSchemeDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: rallies.isEmpty
                ? null
                : () {
                    ref.read(liveSetProvider(widget.setId).notifier).undo();
                  },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 800;
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Score, rotation, and serve-receive status
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildScoreCard(liveSetState, ref),
                  ),
                  // Scoring buttons
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildScoringButtons(context, ref, liveSetState),
                  ),
                  // Scoring breakdown - Us
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildScoringBreakdownUs(context, ref, statsComputer),
                  ),
                  // Scoring breakdown - Them
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildScoringBreakdownThem(context, ref, statsComputer),
                  ),
                  // Error breakdown - Us
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildErrorBreakdownUs(context, ref, statsComputer),
                  ),
                  // Performance stats
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildPerformanceStats(context, ref, statsComputer),
                  ),
                  // Rotation stats - Us
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildRotationStatsUs(rotationStats),
                  ),
                  // Rotation stats - Them
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildRotationStatsThem(rotationStats),
                  ),
                  // Momentum chart - full width
                  SizedBox(
                    width: constraints.maxWidth - 24,
                    child: _buildMomentumChart(rallies),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(LiveSetState state, WidgetRef ref) {
    final ourT1Used = state.set.ourTimeoutsUsed >= 1;
    final ourT2Used = state.set.ourTimeoutsUsed >= 2;
    final oppT1Used = state.set.oppTimeoutsUsed >= 1;
    final oppT2Used = state.set.oppTimeoutsUsed >= 2;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Our timeout buttons (left of our score)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (ourT1Used) {
                          // Undo T1
                          ref.read(liveSetProvider(widget.setId).notifier).useTimeout(true, 0);
                        } else {
                          // Use T1
                          ref.read(liveSetProvider(widget.setId).notifier).useTimeout(true, 1);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ourT1Used ? Colors.grey.shade400 : Colors.blue,
                        foregroundColor: ourT1Used ? Colors.grey.shade600 : Colors.white,
                        fixedSize: const Size(60, 60),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('T1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: ourT1Used ? () {
                        if (ourT2Used) {
                          // Undo T2
                          ref.read(liveSetProvider(widget.setId).notifier).useTimeout(true, 1);
                        } else {
                          // Use T2
                          ref.read(liveSetProvider(widget.setId).notifier).useTimeout(true, 2);
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ourT2Used ? Colors.grey.shade400 : Colors.blue,
                        foregroundColor: ourT2Used ? Colors.grey.shade600 : Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        fixedSize: const Size(60, 60),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('T2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('US', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(
                      '${state.set.ourScore}',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const Text('-', style: TextStyle(fontSize: 24)),
                Column(
                  children: [
                    const Text('THEM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(
                      '${state.set.oppScore}',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                // Their timeout buttons (right of their score)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (oppT1Used) {
                          // Undo T1
                          ref.read(liveSetProvider(widget.setId).notifier).useTimeout(false, 0);
                        } else {
                          // Use T1
                          ref.read(liveSetProvider(widget.setId).notifier).useTimeout(false, 1);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: oppT1Used ? Colors.grey.shade400 : Colors.red,
                        foregroundColor: oppT1Used ? Colors.grey.shade600 : Colors.white,
                        fixedSize: const Size(60, 60),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('T1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: oppT1Used ? () {
                        if (oppT2Used) {
                          // Undo T2
                          ref.read(liveSetProvider(widget.setId).notifier).useTimeout(false, 1);
                        } else {
                          // Use T2
                          ref.read(liveSetProvider(widget.setId).notifier).useTimeout(false, 2);
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: oppT2Used ? Colors.grey.shade400 : Colors.red,
                        foregroundColor: oppT2Used ? Colors.grey.shade600 : Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        fixedSize: const Size(60, 60),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('T2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Rotation and Serve/Receive in row
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text('Rotation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            '${state.currentRotation}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: state.currentServeReceiveState == ServeReceiveState.serve
                        ? Colors.green.shade100
                        : Colors.blue.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            state.currentServeReceiveState.label,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            state.currentServeReceiveState == ServeReceiveState.serve
                                ? Icons.sports_handball
                                : Icons.sports_volleyball,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringButtons(
    BuildContext context,
    WidgetRef ref,
    LiveSetState state,
  ) {
    final setId = state.set.id;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // We scored buttons
            const Text(
              'We Scored',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: state.currentServeReceiveState == ServeReceiveState.serve
                          ? () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.ace)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Ace', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.kill),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Kill', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.block),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Block', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.opponentError),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Opp\nError', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.opponentFault),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Opp\nFault', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()), // Empty space
              ],
            ),
            const SizedBox(height: 12),
            // They scored buttons
            const Text(
              'They Scored (Our Errors)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: state.currentServeReceiveState == ServeReceiveState.serve
                          ? () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.serveError)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Serve\nError', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.attackError),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Attack\nError', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: state.currentServeReceiveState == ServeReceiveState.receive
                          ? () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.receiveError)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Receive\nError', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.digError),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Dig\nError', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.blockError),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Block\nError', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.coverError),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Cover\nError', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.ruleViolation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Fault', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: ElevatedButton(
                      onPressed: () => ref.read(liveSetProvider(widget.setId).notifier).addRally(RallyOutcome.freeBallError),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Free\nBall', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()), // Empty space
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringBreakdownUs(BuildContext context, WidgetRef ref, SetStatsComputer statsComputer) {
    ref.watch(colorSchemeProvider); // Watch for changes
    final colorScheme = ref.read(colorSchemeProvider.notifier).currentScheme;
    final totalRallies = statsComputer.rallies.length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scoring Breakdown - Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.5,
              children: [
                _buildErrorTile(
                  context,
                  'Aces',
                  statsComputer.countAces().toString(),
                  'Serve aces',
                  'Points scored from aces',
                  statsComputer.countAces() >= 2 ? colorScheme.greenColor : colorScheme.grayColor,
                  statsComputer.countAces() >= 2 ? colorScheme.greenTextColor : colorScheme.grayTextColor,
                  statsComputer.getAceIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Kills',
                  statsComputer.countKills().toString(),
                  'Attack kills',
                  'Points scored from kills',
                  statsComputer.countKills() >= 14 ? colorScheme.greenColor : colorScheme.grayColor,
                  statsComputer.countKills() >= 14 ? colorScheme.greenTextColor : colorScheme.grayTextColor,
                  statsComputer.getKillIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Blocks',
                  statsComputer.countBlocks().toString(),
                  'Block points',
                  'Points scored from blocks',
                  statsComputer.countBlocks() >= 1 ? colorScheme.greenColor : colorScheme.grayColor,
                  statsComputer.countBlocks() >= 1 ? colorScheme.greenTextColor : colorScheme.grayTextColor,
                  statsComputer.getBlockIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Opp Errors',
                  statsComputer.countOpponentErrors().toString(),
                  'Opponent errors',
                  'Points from opponent errors',
                  statsComputer.countOpponentErrors() >= 8 ? colorScheme.greenColor : colorScheme.grayColor,
                  statsComputer.countOpponentErrors() >= 8 ? colorScheme.greenTextColor : colorScheme.grayTextColor,
                  statsComputer.getOpponentErrorIndices(),
                  totalRallies,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringBreakdownThem(BuildContext context, WidgetRef ref, SetStatsComputer statsComputer) {
    ref.watch(colorSchemeProvider); // Watch for changes
    final colorScheme = ref.read(colorSchemeProvider.notifier).currentScheme;
    final totalRallies = statsComputer.rallies.length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scoring Breakdown - Them',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.5,
              children: [
                _buildErrorTile(
                  context,
                  'Aces',
                  statsComputer.countReceiveErrors().toString(),
                  'Our receive errors',
                  'Points from our receive errors',
                  statsComputer.countReceiveErrors() >= 2 ? colorScheme.redColor : colorScheme.grayColor,
                  statsComputer.countReceiveErrors() >= 2 ? colorScheme.redTextColor : colorScheme.grayTextColor,
                  statsComputer.getOpponentAceIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Kills',
                  statsComputer.countDigErrors().toString(),
                  'Our dig errors',
                  'Points from our dig errors',
                  statsComputer.countDigErrors() >= 14 ? colorScheme.redColor : colorScheme.grayColor,
                  statsComputer.countDigErrors() >= 14 ? colorScheme.redTextColor : colorScheme.grayTextColor,
                  statsComputer.getOpponentKillIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Blocks',
                  statsComputer.countCoverErrors().toString(),
                  'Our cover errors',
                  'Points from our cover errors',
                  statsComputer.countCoverErrors() >= 1 ? colorScheme.redColor : colorScheme.grayColor,
                  statsComputer.countCoverErrors() >= 1 ? colorScheme.redTextColor : colorScheme.grayTextColor,
                  statsComputer.getOpponentBlockIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Our Errors',
                  statsComputer.countOurOtherErrors().toString(),
                  'Other errors',
                  'Points from our other errors',
                  statsComputer.countOurOtherErrors() >= 8 ? colorScheme.redColor : colorScheme.grayColor,
                  statsComputer.countOurOtherErrors() >= 8 ? colorScheme.redTextColor : colorScheme.grayTextColor,
                  statsComputer.getOurOtherErrorIndices(),
                  totalRallies,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBreakdownUs(BuildContext context, WidgetRef ref, SetStatsComputer statsComputer) {
    ref.watch(colorSchemeProvider); // Watch for changes
    final colorScheme = ref.read(colorSchemeProvider.notifier).currentScheme;
    final totalRallies = statsComputer.rallies.length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error Breakdown - Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.5,
              children: [
                _buildErrorTile(
                  context,
                  'Attack',
                  statsComputer.countAttackErrors().toString(),
                  'Attack errors',
                  'Total attack errors committed',
                  colorScheme.grayColor,
                  colorScheme.grayTextColor,
                  statsComputer.getAttackErrorIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Service',
                  statsComputer.countServeErrors().toString(),
                  'Service errors',
                  'Total service errors committed',
                  colorScheme.grayColor,
                  colorScheme.grayTextColor,
                  statsComputer.getServeErrorIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Receive',
                  statsComputer.countReceiveErrors().toString(),
                  'Receive errors',
                  'Total receive errors committed',
                  colorScheme.grayColor,
                  colorScheme.grayTextColor,
                  statsComputer.getReceiveErrorIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Dig',
                  statsComputer.countDigErrors().toString(),
                  'Dig errors',
                  'Total dig errors committed',
                  colorScheme.grayColor,
                  colorScheme.grayTextColor,
                  statsComputer.getDigErrorIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Block',
                  statsComputer.countBlockErrors().toString(),
                  'Block errors',
                  'Total block errors committed',
                  colorScheme.grayColor,
                  colorScheme.grayTextColor,
                  statsComputer.getBlockErrorIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Cover',
                  statsComputer.countCoverErrors().toString(),
                  'Cover errors',
                  'Total cover errors committed',
                  colorScheme.grayColor,
                  colorScheme.grayTextColor,
                  statsComputer.getCoverErrorIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Faults',
                  statsComputer.countRuleViolations().toString(),
                  'Rule violations',
                  'Total faults/violations committed',
                  colorScheme.grayColor,
                  colorScheme.grayTextColor,
                  statsComputer.getRuleViolationIndices(),
                  totalRallies,
                ),
                _buildErrorTile(
                  context,
                  'Free Ball',
                  statsComputer.countFreeBallErrors().toString(),
                  'Free ball errors',
                  'Total free ball errors committed',
                  colorScheme.grayColor,
                  colorScheme.grayTextColor,
                  statsComputer.getFreeBallErrorIndices(),
                  totalRallies,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStats(BuildContext context, WidgetRef ref, SetStatsComputer statsComputer) {
    ref.watch(colorSchemeProvider); // Watch for changes
    final colorScheme = ref.read(colorSchemeProvider.notifier).currentScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.5,
              children: [
                _buildPerformanceTile(
                  context,
                  'SO %',
                  statsComputer.getSideoutPercentage().toStringAsFixed(0),
                  '${statsComputer.getSideoutCounts()['won']}/${statsComputer.getSideoutCounts()['total']}',
                  'Sideout percentage',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                  sparklineData: statsComputer.getSideoutPercentageHistory(),
                ),
                _buildPerformanceTile(
                  context,
                  'PS %',
                  statsComputer.getPointScoringPercentage().toStringAsFixed(0),
                  '${statsComputer.getPointScoringCounts()['won']}/${statsComputer.getPointScoringCounts()['total']}',
                  'Point-scoring percentage',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                  sparklineData: statsComputer.getPointScoringPercentageHistory(),
                ),
                _buildPerformanceTile(
                  context,
                  'Ace : Serve Error',
                  statsComputer.getAceToServiceErrorRatio(),
                  '${statsComputer.countAces()}:${statsComputer.countServeErrors()}',
                  'Ace to service error ratio',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                  sparklineData: statsComputer.getAceToServiceErrorRatioHistory(),
                ),
                _buildPerformanceTile(
                  context,
                  'Ace : Rec Error',
                  statsComputer.getAceToReceiveErrorRatio(),
                  '${statsComputer.countAces()}:${statsComputer.countReceiveErrors()}',
                  'Ace to receive error ratio',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                  sparklineData: statsComputer.getAceToReceiveErrorRatioHistory(),
                ),
                _buildPerformanceTile(
                  context,
                  'Kill : Attack Error',
                  statsComputer.getKillToAttackErrorRatio(),
                  '${statsComputer.countKills()}:${statsComputer.countAttackErrors()}',
                  'Kill to attack error ratio',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                  sparklineData: statsComputer.getKillToAttackErrorRatioHistory(),
                ),
                _buildPerformanceTile(
                  context,
                  '3+ Runs - Us',
                  statsComputer.countThreePlusPointRunsUs().toString(),
                  'Scoring runs',
                  'Number of 3+ point runs for us',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                  sparklineData: statsComputer.getThreePlusRunsUsHistory(),
                ),
                _buildPerformanceTile(
                  context,
                  '3+ Runs - Them',
                  statsComputer.countThreePlusPointRunsThem().toString(),
                  'Their runs',
                  'Number of 3+ point runs for them',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                  sparklineData: statsComputer.getThreePlusRunsThemHistory(),
                ),
                _buildPerformanceTile(
                  context,
                  'Points Ratio',
                  statsComputer.getPointsRatio(),
                  '${statsComputer.getTotalOurPoints()}:${statsComputer.getTotalOpponentPoints()}',
                  'Our points to their points ratio',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                  sparklineData: statsComputer.getPointsRatioHistory(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationStatsUs(RotationStatsComputer rotationStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rotation Stats - Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Header row
            Row(
              children: const [
                SizedBox(width: 50),
                Expanded(child: Text('SO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                Expanded(child: Text('PS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
              ],
            ),
            const Divider(),
            ...List.generate(6, (index) {
              final rotation = index + 1;
              final soCounts = rotationStats.getSideoutCounts(rotation);
              final psCounts = rotationStats.getPointScoringCounts(rotation);
              final soPercentage = rotationStats.getSideoutPercentage(rotation);
              final psPercentage = rotationStats.getPointScoringPercentage(rotation);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text('Rot $rotation', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text(
                        '${soPercentage.toStringAsFixed(0)}% (${soCounts['won']}/${soCounts['total']})',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${psPercentage.toStringAsFixed(0)}% (${psCounts['won']}/${psCounts['total']})',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationStatsThem(RotationStatsComputer rotationStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rotation Stats - Them',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Header row
            Row(
              children: const [
                SizedBox(width: 50),
                Expanded(child: Text('SO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                Expanded(child: Text('PS', style: TextStyle(fontSize: 12), textAlign: TextAlign.center)),
              ],
            ),
            const Divider(),
            ...List.generate(6, (index) {
              final rotation = index + 1;
              final soCounts = rotationStats.getOpponentSideoutCounts(rotation);
              final psCounts = rotationStats.getOpponentPointScoringCounts(rotation);
              final soPercentage = rotationStats.getOpponentSideoutPercentage(rotation);
              final psPercentage = rotationStats.getOpponentPointScoringPercentage(rotation);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text('Rot $rotation', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text(
                        '${soPercentage.toStringAsFixed(0)}% (${soCounts['won']}/${soCounts['total']})',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${psPercentage.toStringAsFixed(0)}% (${psCounts['won']}/${psCounts['total']})',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMomentumChart(List<Rally> rallies) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Momentum Chart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'A=Ace, K=Kill, B=Block, OE=Opp Error, OF=Opp Fault, SE=Serve Error, AE=Attack Error, RE=Receive Error, DE=Dig Error, BE=Block Error, CE=Cover Error, F=Fault, FBE=Free Ball Error',
              style: TextStyle(fontSize: 9),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 400,
              child: rallies.isEmpty
                  ? const Center(child: Text('No rallies yet'))
                  : MomentumChart(rallies: rallies),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, dynamic value, {bool bold = false, String? infoText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (infoText != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(label),
                        content: Text(infoText),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ],
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRowWithThreshold(
    String label,
    int value,
    int threshold,
    bool isUs, {
    bool bold = false,
  }) {
    final metThreshold = value >= threshold;
    final color = metThreshold ? (isUs ? Colors.green : Colors.red) : null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTile(
    BuildContext context,
    String label,
    String value,
    String subtitle,
    String infoText, {
    Color? color,
    Color? textColor,
    List<double>? sparklineData,
  }) {
    final tileColor = color ?? Colors.blue.shade100;
    final tileTextColor = textColor ?? Colors.black;
    
    return Card(
      color: tileColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: tileTextColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1.0,
                color: tileTextColor,
              ),
            ),
            if (sparklineData != null && sparklineData.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Sparkline(
                  data: sparklineData,
                  color: tileTextColor.withOpacity(0.6),
                  height: 20,
                  strokeWidth: 1.5,
                ),
              ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: tileTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorTile(
    BuildContext context,
    String label,
    String value,
    String subtitle,
    String infoText,
    Color color,
    Color textColor,
    List<int> errorIndices,
    int totalRallies,
  ) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1.0,
                color: textColor,
              ),
            ),
            if (totalRallies > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: DotSparkline(
                  occurrenceIndices: errorIndices,
                  totalRallies: totalRallies,
                  color: textColor.withOpacity(0.6),
                  height: 20,
                  dotSize: 3.0,
                ),
              ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorSchemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color Scheme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final scheme in ColorSchemeType.values)
              ListTile(
                title: Text(_getColorSchemeName(scheme)),
                trailing: _buildSchemePreview(ref, scheme),
                onTap: () {
                  ref.read(colorSchemeProvider.notifier).setColorScheme(scheme);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getColorSchemeName(ColorSchemeType type) {
    switch (type) {
      case ColorSchemeType.boldStadium:
        return 'Bold Stadium';
      case ColorSchemeType.neonCourt:
        return 'Neon Court';
      case ColorSchemeType.classicSports:
        return 'Classic Sports';
      case ColorSchemeType.volleyballArena:
        return 'Volleyball Arena';
    }
  }

  Widget _buildSchemePreview(WidgetRef ref, ColorSchemeType type) {
    final tempNotifier = ColorSchemeNotifier();
    tempNotifier.setColorScheme(type);
    final scheme = tempNotifier.currentScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: scheme.greenColor,
            border: Border.all(color: Colors.black),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: scheme.redColor,
            border: Border.all(color: Colors.black),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: scheme.performanceColor,
            border: Border.all(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
