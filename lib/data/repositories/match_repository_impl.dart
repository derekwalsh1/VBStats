import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:vbstats/data/datasources/database/vbstats_database.dart';
import 'package:vbstats/domain/entities/enums.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/domain/repositories/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  final VBStatsDatabase database;

  MatchRepositoryImpl(this.database);

  // Match operations
  @override
  Future<List<Match>> getAllMatches() async {
    final entities = await database.getAllMatches();
    return entities
        .map((e) => Match(
              id: e.id,
              opponentName: e.opponentName,
              eventName: e.eventName,
              date: e.date,
              createdAt: e.createdAt,
            ))
        .toList();
  }

  @override
  Future<Match?> getMatchById(String id) async {
    final entity = await database.getMatchById(id);
    if (entity == null) return null;
    return Match(
      id: entity.id,
      opponentName: entity.opponentName,
      eventName: entity.eventName,
      date: entity.date,
      createdAt: entity.createdAt,
    );
  }

  @override
  Future<String> createMatch(String opponentName, {String? eventName}) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await database.insertMatch(MatchesCompanion(
      id: Value(id),
      opponentName: Value(opponentName),
      eventName: Value(eventName),
      date: Value(now),
      createdAt: Value(now),
    ));
    return id;
  }

  @override
  Future<void> updateMatch(Match match) async {
    await database.updateMatch(MatchesCompanion(
      id: Value(match.id),
      opponentName: Value(match.opponentName),
      eventName: Value(match.eventName),
      date: Value(match.date),
      createdAt: Value(match.createdAt),
    ));
  }

  @override
  Future<void> deleteMatch(String id) async {
    // Delete all sets and rallies first
    final sets = await getSetsByMatch(id);
    for (final set in sets) {
      await deleteSet(set.id);
    }
    await database.deleteMatch(id);
  }

  // Set operations
  @override
  Future<List<Set>> getSetsByMatch(String matchId) async {
    final entities = await database.getSetsByMatch(matchId);
    return entities
        .map((e) => Set(
              id: e.id,
              matchId: e.matchId,
              setIndex: e.setIndex,
              startRotation: e.startRotation,
              startServeReceiveState: e.startServeReceiveState == 'serve'
                  ? ServeReceiveState.serve
                  : ServeReceiveState.receive,
              ourScore: e.ourScore,
              oppScore: e.oppScore,
              createdAt: e.createdAt,
            ))
        .toList();
  }

  @override
  Future<Set?> getSetById(String id) async {
    final entity = await database.getSetById(id);
    if (entity == null) return null;
    return Set(
      id: entity.id,
      matchId: entity.matchId,
      setIndex: entity.setIndex,
      startRotation: entity.startRotation,
      startServeReceiveState: entity.startServeReceiveState == 'serve'
          ? ServeReceiveState.serve
          : ServeReceiveState.receive,
      ourScore: entity.ourScore,
      oppScore: entity.oppScore,
      createdAt: entity.createdAt,
    );
  }

  @override
  Future<String> createSet(String matchId, int setIndex, int startRotation,
      bool startServing) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await database.insertSet(SetsCompanion(
      id: Value(id),
      matchId: Value(matchId),
      setIndex: Value(setIndex),
      startRotation: Value(startRotation),
      startServeReceiveState:
          Value(startServing ? 'serve' : 'receive'),
      createdAt: Value(now),
    ));
    return id;
  }

  @override
  Future<void> updateSet(Set set) async {
    await database.updateSet(SetsCompanion(
      id: Value(set.id),
      matchId: Value(set.matchId),
      setIndex: Value(set.setIndex),
      startRotation: Value(set.startRotation),
      startServeReceiveState: Value(
          set.startServeReceiveState == ServeReceiveState.serve
              ? 'serve'
              : 'receive'),
      ourScore: Value(set.ourScore),
      oppScore: Value(set.oppScore),
      createdAt: Value(set.createdAt),
    ));
  }

  @override
  Future<void> deleteSet(String id) async {
    // Delete all rallies first
    final rallies = await getRalliesBySet(id);
    for (final rally in rallies) {
      await database.deleteRally(rally.id);
    }
    await database.deleteSet(id);
  }

  // Rally operations
  @override
  Future<List<Rally>> getRalliesBySet(String setId) async {
    final entities = await database.getRalliesBySet(setId);
    return entities
        .map((e) => Rally(
              id: e.id,
              setId: e.setId,
              rallyIndex: e.rallyIndex,
              rotationAtStart: e.rotationAtStart,
              weWereServing: e.weWereServing,
              outcome: _parseOutcome(e.outcome),
              weWon: e.weWon,
              timestamp: e.timestamp,
            ))
        .toList();
  }

  @override
  Future<String> addRally(String setId, int rallyIndex, int rotation,
      bool weWereServing, String outcome, bool weWon) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await database.insertRally(RalliesCompanion(
      id: Value(id),
      setId: Value(setId),
      rallyIndex: Value(rallyIndex),
      rotationAtStart: Value(rotation),
      weWereServing: Value(weWereServing),
      outcome: Value(outcome),
      weWon: Value(weWon),
      timestamp: Value(now),
    ));
    return id;
  }

  @override
  Future<void> updateRally(Rally rally) async {
    await database.updateRally(RalliesCompanion(
      id: Value(rally.id),
      setId: Value(rally.setId),
      rallyIndex: Value(rally.rallyIndex),
      rotationAtStart: Value(rally.rotationAtStart),
      weWereServing: Value(rally.weWereServing),
      outcome: Value(rally.outcome.name),
      weWon: Value(rally.weWon),
      timestamp: Value(rally.timestamp),
    ));
  }

  @override
  Future<void> deleteRally(String id) async {
    await database.deleteRally(id);
  }

  @override
  Future<void> deleteRalliesFrom(String setId, int rallyIndex) async {
    await database.deleteRalliesFromIndex(setId, rallyIndex);
  }

  // Helper
  RallyOutcome _parseOutcome(String outcomeString) {
    return RallyOutcome.values.firstWhere(
      (e) => e.name == outcomeString,
      orElse: () => RallyOutcome.ace,
    );
  }
}
