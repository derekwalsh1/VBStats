import 'package:vbstats/domain/entities/match_entities.dart';

abstract class MatchRepository {
  Future<List<Match>> getAllMatches();
  Future<Match?> getMatchById(String id);
  Future<String> createMatch(String opponentName, {String? eventName});
  Future<void> updateMatch(Match match);
  Future<void> deleteMatch(String id);

  Future<List<Set>> getSetsByMatch(String matchId);
  Future<Set?> getSetById(String id);
  Future<String> createSet(String matchId, int setIndex, int startRotation, bool startServing);
  Future<void> updateSet(Set set);
  Future<void> deleteSet(String id);

  Future<List<Rally>> getRalliesBySet(String setId);
  Future<String> addRally(String setId, int rallyIndex, int rotation, bool weWereServing, String outcome, bool weWon);
  Future<void> updateRally(Rally rally);
  Future<void> deleteRally(String id);
  Future<void> deleteRalliesFrom(String setId, int rallyIndex);
}
