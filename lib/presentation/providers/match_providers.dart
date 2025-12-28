import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/domain/repositories/match_repository.dart';
import 'package:vbstats/presentation/providers/database_providers.dart';

// Matches list provider
final matchesProvider =
    FutureProvider<List<Match>>((ref) async {
  final repo = await ref.watch(matchRepositoryProvider.future);
  return repo.getAllMatches();
});

// Currently selected match
final selectedMatchProvider = StateProvider<Match?>((ref) => null);

// Match sets provider
final matchSetsProvider =
    FutureProvider.family<List<Set>, String>((ref, matchId) async {
  final repo = await ref.watch(matchRepositoryProvider.future);
  return repo.getSetsByMatch(matchId);
});

// Create match mutation
final createMatchProvider =
    FutureProvider.family<String, (String, String?)>((ref, args) async {
  final repo = await ref.watch(matchRepositoryProvider.future);
  final (opponentName, eventName) = args;
  return repo.createMatch(opponentName, eventName: eventName);
});
