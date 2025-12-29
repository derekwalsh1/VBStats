import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/domain/entities/enums.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/presentation/providers/database_providers.dart';
import 'package:vbstats/core/utils/set_logic.dart';

// Provider for the current set state
class LiveSetState {
  final Set set;
  final List<Rally> rallies;
  final int currentRotation;
  final ServeReceiveState currentServeReceiveState;
  final List<Rally> undoStack;

  LiveSetState({
    required this.set,
    required this.rallies,
    required this.currentRotation,
    required this.currentServeReceiveState,
    this.undoStack = const [],
  });

  LiveSetState copyWith({
    Set? set,
    List<Rally>? rallies,
    int? currentRotation,
    ServeReceiveState? currentServeReceiveState,
    List<Rally>? undoStack,
  }) {
    return LiveSetState(
      set: set ?? this.set,
      rallies: rallies ?? this.rallies,
      currentRotation: currentRotation ?? this.currentRotation,
      currentServeReceiveState:
          currentServeReceiveState ?? this.currentServeReceiveState,
      undoStack: undoStack ?? this.undoStack,
    );
  }
}

// Provider for live set state management
final liveSetProvider =
    StateNotifierProvider.family<LiveSetNotifier, LiveSetState?, String>(
  (ref, setId) => LiveSetNotifier(ref, setId),
);

class LiveSetNotifier extends StateNotifier<LiveSetState?> {
  final Ref ref;
  final String setId;

  LiveSetNotifier(this.ref, this.setId) : super(null) {
    _loadSet();
  }

  Future<void> _loadSet() async {
    try {
      final repo = await ref.read(matchRepositoryProvider.future);
      final set = await repo.getSetById(setId);
      if (set == null) return;

      final rallies = await repo.getRalliesBySet(setId);

      // Calculate current rotation and serve/receive state
      int currentRotation = set.startRotation;
      ServeReceiveState currentState = set.startServeReceiveState;

      if (rallies.isNotEmpty) {
        final stateManager = SetStateManager(
          currentSet: set,
          currentRotation: set.startRotation,
          currentServeReceiveState: set.startServeReceiveState,
        );

        for (final rally in rallies) {
          stateManager.processRallyOutcome(rally.outcome);
        }

        currentRotation = stateManager.currentRotation;
        currentState = stateManager.currentServeReceiveState;
      }

      state = LiveSetState(
        set: set,
        rallies: rallies,
        currentRotation: currentRotation,
        currentServeReceiveState: currentState,
      );
    } catch (e) {
      debugPrint('Error loading set: $e');
    }
  }

  Future<void> addRally(RallyOutcome outcome) async {
    if (state == null) return;

    try {
      final repo = await ref.read(matchRepositoryProvider.future);
      final rallyIndex = state!.rallies.length;
      final weWon = outcome.weWon;

      // Add rally to database
      await repo.addRally(
        setId,
        rallyIndex,
        state!.currentRotation,
        state!.currentServeReceiveState == ServeReceiveState.serve,
        outcome.name,
        weWon,
      );

      // Update set scores
      final newOurScore = state!.set.ourScore + (weWon ? 1 : 0);
      final newOppScore = state!.set.oppScore + (weWon ? 0 : 1);

      final updatedSet = Set(
        id: state!.set.id,
        matchId: state!.set.matchId,
        setIndex: state!.set.setIndex,
        startRotation: state!.set.startRotation,
        startServeReceiveState: state!.set.startServeReceiveState,
        ourScore: newOurScore,
        oppScore: newOppScore,
        ourTimeoutsUsed: state!.set.ourTimeoutsUsed,
        oppTimeoutsUsed: state!.set.oppTimeoutsUsed,
        createdAt: state!.set.createdAt,
      );

      await repo.updateSet(updatedSet);

      // Calculate new rotation and serve/receive state
      final stateManager = SetStateManager(
        currentSet: state!.set,
        currentRotation: state!.currentRotation,
        currentServeReceiveState: state!.currentServeReceiveState,
      );
      stateManager.processRallyOutcome(outcome);

      // Reload to get updated data
      await _loadSet();
    } catch (e) {
      debugPrint('Error adding rally: $e');
    }
  }

  Future<void> undo() async {
    if (state == null || state!.rallies.isEmpty) return;

    try {
      final repo = await ref.read(matchRepositoryProvider.future);
      final lastRally = state!.rallies.last;

      // Delete last rally
      await repo.deleteRally(lastRally.id);

      // Update set scores
      final newOurScore = state!.set.ourScore - (lastRally.weWon ? 1 : 0);
      final newOppScore = state!.set.oppScore - (lastRally.weWon ? 0 : 1);

      final updatedSet = Set(
        id: state!.set.id,
        matchId: state!.set.matchId,
        setIndex: state!.set.setIndex,
        startRotation: state!.set.startRotation,
        startServeReceiveState: state!.set.startServeReceiveState,
        ourScore: newOurScore,
        oppScore: newOppScore,
        ourTimeoutsUsed: state!.set.ourTimeoutsUsed,
        oppTimeoutsUsed: state!.set.oppTimeoutsUsed,
        createdAt: state!.set.createdAt,
      );

      await repo.updateSet(updatedSet);

      // Reload to recalculate state
      await _loadSet();
    } catch (e) {
      debugPrint('Error undoing rally: $e');
    }
  }

  Future<void> useTimeout(bool isOurs, int timeoutNumber) async {
    if (state == null) return;
    
    try {
      final repo = await ref.read(matchRepositoryProvider.future);
      
      final updatedSet = Set(
        id: state!.set.id,
        matchId: state!.set.matchId,
        setIndex: state!.set.setIndex,
        startRotation: state!.set.startRotation,
        startServeReceiveState: state!.set.startServeReceiveState,
        ourScore: state!.set.ourScore,
        oppScore: state!.set.oppScore,
        ourTimeoutsUsed: isOurs ? timeoutNumber : state!.set.ourTimeoutsUsed,
        oppTimeoutsUsed: isOurs ? state!.set.oppTimeoutsUsed : timeoutNumber,
        createdAt: state!.set.createdAt,
      );
      
      await repo.updateSet(updatedSet);
      await _loadSet();
    } catch (e) {
      debugPrint('Error using timeout: $e');
    }
  }
}
