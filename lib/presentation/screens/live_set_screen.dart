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

class LiveSetScreen extends ConsumerWidget {
  final Match match;
  final String setId;

  const LiveSetScreen({
    required this.match,
    required this.setId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveSetState = ref.watch(liveSetProvider(setId));

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Set ${set.setIndex} - ${match.opponentName}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Invalidate match sets provider to refresh scores
            ref.invalidate(matchSetsProvider(match.id));
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
                    ref.read(liveSetProvider(setId).notifier).undo();
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
                    child: _buildScoreCard(liveSetState),
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

  Widget _buildScoreCard(LiveSetState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('US', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(
                      '${state.set.ourScore}',
                      style: const TextStyle(
                        fontSize: 36,
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
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
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
                          ? () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.ace)
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.kill),
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.block),
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.opponentError),
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.opponentFault),
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
                          ? () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.serveError)
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.attackError),
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
                          ? () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.receiveError)
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.digError),
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.blockError),
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.coverError),
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.ruleViolation),
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
                      onPressed: () => ref.read(liveSetProvider(setId).notifier).addRally(RallyOutcome.freeBallError),
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
    final colorScheme = ref.read(colorSchemeProvider.notifier).currentScheme;
    
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
                _buildPerformanceTile(
                  context,
                  'Aces',
                  statsComputer.countAces().toString(),
                  'Serve aces',
                  'Points scored from aces',
                  color: statsComputer.countAces() >= 2 ? colorScheme.greenColor : colorScheme.grayColor,
                  textColor: statsComputer.countAces() >= 2 ? colorScheme.greenTextColor : colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Kills',
                  statsComputer.countKills().toString(),
                  'Attack kills',
                  'Points scored from kills',
                  color: statsComputer.countKills() >= 14 ? colorScheme.greenColor : colorScheme.grayColor,
                  textColor: statsComputer.countKills() >= 14 ? colorScheme.greenTextColor : colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Blocks',
                  statsComputer.countBlocks().toString(),
                  'Block points',
                  'Points scored from blocks',
                  color: statsComputer.countBlocks() >= 1 ? colorScheme.greenColor : colorScheme.grayColor,
                  textColor: statsComputer.countBlocks() >= 1 ? colorScheme.greenTextColor : colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Opp Errors',
                  statsComputer.countOpponentErrors().toString(),
                  'Opponent errors',
                  'Points from opponent errors',
                  color: statsComputer.countOpponentErrors() >= 8 ? colorScheme.greenColor : colorScheme.grayColor,
                  textColor: statsComputer.countOpponentErrors() >= 8 ? colorScheme.greenTextColor : colorScheme.grayTextColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringBreakdownThem(BuildContext context, WidgetRef ref, SetStatsComputer statsComputer) {
    final colorScheme = ref.read(colorSchemeProvider.notifier).currentScheme;
    
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
                _buildPerformanceTile(
                  context,
                  'Aces',
                  statsComputer.countReceiveErrors().toString(),
                  'Our receive errors',
                  'Points from our receive errors',
                  color: statsComputer.countReceiveErrors() >= 2 ? colorScheme.redColor : colorScheme.grayColor,
                  textColor: statsComputer.countReceiveErrors() >= 2 ? colorScheme.redTextColor : colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Kills',
                  statsComputer.countDigErrors().toString(),
                  'Our dig errors',
                  'Points from our dig errors',
                  color: statsComputer.countDigErrors() >= 14 ? colorScheme.redColor : colorScheme.grayColor,
                  textColor: statsComputer.countDigErrors() >= 14 ? colorScheme.redTextColor : colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Blocks',
                  statsComputer.countCoverErrors().toString(),
                  'Our cover errors',
                  'Points from our cover errors',
                  color: statsComputer.countCoverErrors() >= 1 ? colorScheme.redColor : colorScheme.grayColor,
                  textColor: statsComputer.countCoverErrors() >= 1 ? colorScheme.redTextColor : colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Our Errors',
                  statsComputer.countOurOtherErrors().toString(),
                  'Other errors',
                  'Points from our other errors',
                  color: statsComputer.countOurOtherErrors() >= 8 ? colorScheme.redColor : colorScheme.grayColor,
                  textColor: statsComputer.countOurOtherErrors() >= 8 ? colorScheme.redTextColor : colorScheme.grayTextColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBreakdownUs(BuildContext context, WidgetRef ref, SetStatsComputer statsComputer) {
    final colorScheme = ref.read(colorSchemeProvider.notifier).currentScheme;
    
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
                _buildPerformanceTile(
                  context,
                  'Attack',
                  statsComputer.countAttackErrors().toString(),
                  'Attack errors',
                  'Total attack errors committed',
                  color: colorScheme.grayColor,
                  textColor: colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Service',
                  statsComputer.countServeErrors().toString(),
                  'Service errors',
                  'Total service errors committed',
                  color: colorScheme.grayColor,
                  textColor: colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Receive',
                  statsComputer.countReceiveErrors().toString(),
                  'Receive errors',
                  'Total receive errors committed',
                  color: colorScheme.grayColor,
                  textColor: colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Dig',
                  statsComputer.countDigErrors().toString(),
                  'Dig errors',
                  'Total dig errors committed',
                  color: colorScheme.grayColor,
                  textColor: colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Block',
                  statsComputer.countBlockErrors().toString(),
                  'Block errors',
                  'Total block errors committed',
                  color: colorScheme.grayColor,
                  textColor: colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Cover',
                  statsComputer.countCoverErrors().toString(),
                  'Cover errors',
                  'Total cover errors committed',
                  color: colorScheme.grayColor,
                  textColor: colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Faults',
                  statsComputer.countRuleViolations().toString(),
                  'Rule violations',
                  'Total faults/violations committed',
                  color: colorScheme.grayColor,
                  textColor: colorScheme.grayTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Free Ball',
                  statsComputer.countFreeBallErrors().toString(),
                  'Free ball errors',
                  'Total free ball errors committed',
                  color: colorScheme.grayColor,
                  textColor: colorScheme.grayTextColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStats(BuildContext context, WidgetRef ref, SetStatsComputer statsComputer) {
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
                ),
                _buildPerformanceTile(
                  context,
                  'PS %',
                  statsComputer.getPointScoringPercentage().toStringAsFixed(0),
                  '${statsComputer.getPointScoringCounts()['won']}/${statsComputer.getPointScoringCounts()['total']}',
                  'Point-scoring percentage',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Ace : Serve Error',
                  statsComputer.getAceToServiceErrorRatio(),
                  '${statsComputer.countAces()}:${statsComputer.countServeErrors()}',
                  'Ace to service error ratio',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Ace : Rec Error',
                  statsComputer.getAceToReceiveErrorRatio(),
                  '${statsComputer.countAces()}:${statsComputer.countReceiveErrors()}',
                  'Ace to receive error ratio',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Kill : Attack Error',
                  statsComputer.getKillToAttackErrorRatio(),
                  '${statsComputer.countKills()}:${statsComputer.countAttackErrors()}',
                  'Kill to attack error ratio',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  '3+ Runs - Us',
                  statsComputer.countThreePlusPointRunsUs().toString(),
                  'Scoring runs',
                  'Number of 3+ point runs for us',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  '3+ Runs - Them',
                  statsComputer.countThreePlusPointRunsThem().toString(),
                  'Their runs',
                  'Number of 3+ point runs for them',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
                ),
                _buildPerformanceTile(
                  context,
                  'Points Ratio',
                  statsComputer.getPointsRatio(),
                  '${statsComputer.getTotalOurPoints()}:${statsComputer.getTotalOpponentPoints()}',
                  'Our points to their points ratio',
                  color: colorScheme.performanceColor,
                  textColor: colorScheme.performanceTextColor,
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
