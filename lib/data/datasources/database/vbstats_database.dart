import 'package:drift/drift.dart';
import 'tables.dart';

part 'vbstats_database.g.dart';

@DriftDatabase(tables: [Teams, Matches, Sets, Rallies])
class VBStatsDatabase extends _$VBStatsDatabase {
  VBStatsDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from == 1) {
        // Add timeout columns to existing sets table
        await migrator.addColumn(sets, sets.ourTimeoutsUsed);
        await migrator.addColumn(sets, sets.oppTimeoutsUsed);
      }
      if (from <= 2) {
        // Create teams table and add teamId to matches
        await migrator.createTable(teams);
        // Add teamId column with a default team
        await migrator.addColumn(matches, matches.teamId);
        // Create a default team for existing matches
        await customStatement(
          "INSERT OR IGNORE INTO teams (id, name, created_at) VALUES ('default-team', 'My Team', datetime('now'))"
        );
        await customStatement(
          "UPDATE matches SET team_id = 'default-team' WHERE team_id IS NULL OR team_id = ''"
        );
      }
    },
  );

  // Team queries
  Future<List<TeamEntity>> getAllTeams() => select(teams).get();

  Future<TeamEntity?> getTeamById(String id) =>
      (select(teams)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTeam(TeamsCompanion team) =>
      into(teams).insert(team);

  Future<bool> updateTeam(TeamsCompanion team) =>
      update(teams).replace(team);

  Future<int> deleteTeam(String id) =>
      (delete(teams)..where((t) => t.id.equals(id))).go();

  // Match queries
  Future<List<MatchEntity>> getAllMatches() => select(matches).get();

  Future<List<MatchEntity>> getMatchesByTeam(String teamId) =>
      (select(matches)..where((m) => m.teamId.equals(teamId))).get();

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
