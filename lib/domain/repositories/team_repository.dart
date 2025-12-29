import 'package:vbstats/domain/entities/match_entities.dart';

abstract class TeamRepository {
  Future<List<Team>> getAllTeams();
  Future<Team?> getTeamById(String id);
  Future<String> createTeam(String name);
  Future<void> updateTeam(Team team);
  Future<void> deleteTeam(String id);
}
