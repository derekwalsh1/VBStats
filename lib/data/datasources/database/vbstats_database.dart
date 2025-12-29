import 'package:drift/drift.dart';
import 'tables.dart';

part 'vbstats_database.g.dart';

@DriftDatabase(tables: [Matches, Sets, Rallies])
class VBStatsDatabase extends _$VBStatsDatabase {
  VBStatsDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from == 1) {
        // Add timeout columns to existing sets table
        await migrator.addColumn(sets, sets.ourTimeoutsUsed);
        await migrator.addColumn(sets, sets.oppTimeoutsUsed);
      }
    },
  );

  // Match queries
  Future<List<MatchEntity>> getAllMatches() => select(matches).get();

  Future<MatchEntity?> getMatchById(String id) =>
      (select(matches)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<int> insertMatch(MatchesCompanion match) =>
      into(matches).insert(match);

  Future<bool> updateMatch(MatchesCompanion match) =>
      update(matches).replace(match);

  Future<int> deleteMatch(String id) =>
      (delete(matches)..where((m) => m.id.equals(id))).go();

  // Set queries
  Future<List<SetEntity>> getSetsByMatch(String matchId) =>
      (select(sets)..where((s) => s.matchId.equals(matchId)))
          .get();

  Future<SetEntity?> getSetById(String id) =>
      (select(sets)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> insertSet(SetsCompanion set) => into(sets).insert(set);

  Future<bool> updateSet(SetsCompanion set) => update(sets).replace(set);

  Future<int> deleteSet(String id) =>
      (delete(sets)..where((s) => s.id.equals(id))).go();

  // Rally queries
  Future<List<RallyEntity>> getRalliesBySet(String setId) =>
      (select(rallies)..where((r) => r.setId.equals(setId)))
          .get();

  Future<RallyEntity?> getRallyById(String id) =>
      (select(rallies)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<int> insertRally(RalliesCompanion rally) =>
      into(rallies).insert(rally);

  Future<bool> updateRally(RalliesCompanion rally) =>
      update(rallies).replace(rally);

  Future<int> deleteRally(String id) =>
      (delete(rallies)..where((r) => r.id.equals(id))).go();

  Future<int> deleteRalliesFromIndex(String setId, int fromIndex) =>
      (delete(rallies)
            ..where((r) =>
                r.setId.equals(setId) & r.rallyIndex.isBiggerOrEqualValue(fromIndex)))
          .go();
}
