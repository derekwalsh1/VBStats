import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/domain/entities/enums.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/presentation/providers/live_set_provider.dart';
import 'package:vbstats/presentation/providers/match_providers.dart';
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
                  // Scoring breakdown
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildScoringBreakdown(context, statsComputer),
                  ),
                  // Performance stats
                  SizedBox(
                    width: isTablet ? (constraints.maxWidth - 36) / 2 : constraints.maxWidth - 24,
                    child: _buildPerformanceStats(context, statsComputer),
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

  Widget _buildScoringBreakdown(BuildContext context, SetStatsComputer statsComputer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scoring Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Us', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      _buildStatRowWithThreshold('Aces', statsComputer.countAces(), 2, true),
                      _buildStatRowWithThreshold('Kills', statsComputer.countKills(), 14, true),
                      _buildStatRowWithThreshold('Blocks', statsComputer.countBlocks(), 1, true),
                      _buildStatRowWithThreshold('Opp Errors', statsComputer.countOpponentErrors(), 8, true),
                      const Divider(),
                      _buildStatRow(context, 'Total', statsComputer.getTotalOurPoints(), bold: true),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Them', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      _buildStatRowWithThreshold('Aces', statsComputer.countReceiveErrors(), 2, false),
                      _buildStatRowWithThreshold('Kills', statsComputer.countDigErrors(), 14, false),
                      _buildStatRowWithThreshold('Blocks', statsComputer.countCoverErrors(), 1, false),
                      _buildStatRowWithThreshold('Our Errors', statsComputer.countOurOtherErrors(), 8, false),
                      const Divider(),
                      _buildStatRow(context, 'Total', statsComputer.getTotalOpponentPoints(), bold: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStats(BuildContext context, SetStatsComputer statsComputer) {
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
                ),
                _buildPerformanceTile(
                  context,
                  'PS %',
                  statsComputer.getPointScoringPercentage().toStringAsFixed(0),
                  '${statsComputer.getPointScoringCounts()['won']}/${statsComputer.getPointScoringCounts()['total']}',
                  'Point-scoring percentage',
                ),
                _buildPerformanceTile(
                  context,
                  'Ace Ratio',
                  statsComputer.getAceToServiceErrorRatio(),
                  '${statsComputer.countAces()}:${statsComputer.countServeErrors()}',
                  'Ace to service error ratio',
                ),
                _buildPerformanceTile(
                  context,
                  'Rec Ratio',
                  statsComputer.getAceToReceiveErrorRatio(),
                  '${statsComputer.countAces()}:${statsComputer.countReceiveErrors()}',
                  'Ace to receive error ratio',
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
              height: 200,
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
    String infoText,
  ) {
    return Card(
      color: Colors.blue.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
