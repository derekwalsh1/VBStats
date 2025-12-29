import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/presentation/providers/database_providers.dart';

// Provider for all teams
final teamsProvider = FutureProvider<List<Team>>((ref) async {
  final repo = await ref.watch(teamRepositoryProvider.future);
  return repo.getAllTeams();
});

// Provider for a specific team
final teamProvider = FutureProvider.family<Team?, String>((ref, teamId) async {
  final repo = await ref.watch(teamRepositoryProvider.future);
  return repo.getTeamById(teamId);
});

// Provider for matches by team
final teamMatchesProvider = FutureProvider.family<List<Match>, String>((ref, teamId) async {
  final repo = await ref.watch(matchRepositoryProvider.future);
  return repo.getMatchesByTeam(teamId);
});
