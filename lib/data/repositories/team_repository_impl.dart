import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:vbstats/data/datasources/database/vbstats_database.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/domain/repositories/team_repository.dart';

class TeamRepositoryImpl implements TeamRepository {
  final VBStatsDatabase database;

  TeamRepositoryImpl(this.database);

  @override
  Future<List<Team>> getAllTeams() async {
    final entities = await database.getAllTeams();
    return entities
        .map((e) => Team(
              id: e.id,
              name: e.name,
              createdAt: e.createdAt,
            ))
        .toList();
  }

  @override
  Future<Team?> getTeamById(String id) async {
    final entity = await database.getTeamById(id);
    if (entity == null) return null;
    return Team(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
    );
  }

  @override
  Future<String> createTeam(String name) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await database.insertTeam(TeamsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(now),
    ));
    return id;
  }

  @override
  Future<void> updateTeam(Team team) async {
    await database.updateTeam(TeamsCompanion(
      id: Value(team.id),
      name: Value(team.name),
      createdAt: Value(team.createdAt),
    ));
  }

  @override
  Future<void> deleteTeam(String id) async {
    // Note: This will orphan matches - consider adding cascade delete or validation
    await database.deleteTeam(id);
  }
}
