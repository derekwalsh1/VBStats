import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/domain/entities/enums.dart';
import 'package:vbstats/domain/repositories/match_repository.dart';

class MatchImportExportService {
  final MatchRepository matchRepository;

  MatchImportExportService(this.matchRepository);

  /// Export a single match with all its sets and rallies
  Future<void> exportMatch(String matchId, {Rect? sharePositionOrigin}) async {
    final match = await matchRepository.getMatchById(matchId);
    if (match == null) throw Exception('Match not found');

    final sets = await matchRepository.getSetsByMatch(matchId);
    final setsData = <Map<String, dynamic>>[];

    for (final set in sets) {
      final rallies = await matchRepository.getRalliesBySet(set.id);
      setsData.add({
        'setIndex': set.setIndex,
        'startRotation': set.startRotation,
        'startServeReceiveState': set.startServeReceiveState.name,
        'ourScore': set.ourScore,
        'oppScore': set.oppScore,
        'ourTimeoutsUsed': set.ourTimeoutsUsed,
        'oppTimeoutsUsed': set.oppTimeoutsUsed,
        'rallies': rallies.map((r) => {
          'rallyIndex': r.rallyIndex,
          'rotationAtStart': r.rotationAtStart,
          'weWereServing': r.weWereServing,
          'outcome': r.outcome.name,
          'weWon': r.weWon,
          'timestamp': r.timestamp.toIso8601String(),
        }).toList(),
      });
    }

    final exportData = {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'match': {
        'opponentName': match.opponentName,
        'eventName': match.eventName,
        'date': match.date.toIso8601String(),
        'sets': setsData,
      },
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final fileName = 'vbstats_${match.opponentName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.json';

    // Save to temporary directory and share
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'VBStats Match Export - ${match.opponentName}',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Export all matches for a team
  Future<void> exportTeamMatches(String teamId, {Rect? sharePositionOrigin}) async {
    final matches = await matchRepository.getMatchesByTeam(teamId);
    if (matches.isEmpty) throw Exception('No matches to export');

    final matchesData = <Map<String, dynamic>>[];

    for (final match in matches) {
      final sets = await matchRepository.getSetsByMatch(match.id);
      final setsData = <Map<String, dynamic>>[];

      for (final set in sets) {
        final rallies = await matchRepository.getRalliesBySet(set.id);
        setsData.add({
          'setIndex': set.setIndex,
          'startRotation': set.startRotation,
          'startServeReceiveState': set.startServeReceiveState.name,
          'ourScore': set.ourScore,
          'oppScore': set.oppScore,
          'ourTimeoutsUsed': set.ourTimeoutsUsed,
          'oppTimeoutsUsed': set.oppTimeoutsUsed,
          'rallies': rallies.map((r) => {
            'rallyIndex': r.rallyIndex,
            'rotationAtStart': r.rotationAtStart,
            'weWereServing': r.weWereServing,
            'outcome': r.outcome.name,
            'weWon': r.weWon,
            'timestamp': r.timestamp.toIso8601String(),
          }).toList(),
        });
      }

      matchesData.add({
        'opponentName': match.opponentName,
        'eventName': match.eventName,
        'date': match.date.toIso8601String(),
        'sets': setsData,
      });
    }

    final exportData = {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'matches': matchesData,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final fileName = 'vbstats_team_export_${DateTime.now().millisecondsSinceEpoch}.json';

    // Save to temporary directory and share
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'VBStats Team Matches Export',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Import matches from a JSON file
  Future<int> importMatches(String teamId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('No file selected');
    }

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    if (data['version'] != 1) {
      throw Exception('Unsupported file version');
    }

    int importedCount = 0;

    // Handle both single match and multiple matches export formats
    if (data.containsKey('match')) {
      // Single match format
      await _importSingleMatch(data['match'] as Map<String, dynamic>, teamId);
      importedCount = 1;
    } else if (data.containsKey('matches')) {
      // Multiple matches format
      final matches = data['matches'] as List<dynamic>;
      for (final matchData in matches) {
        await _importSingleMatch(matchData as Map<String, dynamic>, teamId);
        importedCount++;
      }
    } else {
      throw Exception('Invalid file format');
    }

    return importedCount;
  }

  Future<void> _importSingleMatch(Map<String, dynamic> matchData, String teamId) async {
    // Create match
    final matchId = await matchRepository.createMatch(
      teamId,
      matchData['opponentName'] as String,
      eventName: matchData['eventName'] as String?,
    );

    // Update match date
    final match = await matchRepository.getMatchById(matchId);
    if (match != null) {
      final updatedMatch = Match(
        id: match.id,
        teamId: match.teamId,
        opponentName: match.opponentName,
        eventName: match.eventName,
        date: DateTime.parse(matchData['date'] as String),
        createdAt: match.createdAt,
      );
      await matchRepository.updateMatch(updatedMatch);
    }

    // Import sets
    final setsData = matchData['sets'] as List<dynamic>?;
    if (setsData != null) {
      for (final setData in setsData) {
        final setMap = setData as Map<String, dynamic>;
        
        final setId = await matchRepository.createSet(
          matchId,
          setMap['setIndex'] as int,
          setMap['startRotation'] as int,
          setMap['startServeReceiveState'] == 'serve',
        );

        // Update set scores and timeouts
        final set = await matchRepository.getSetById(setId);
        if (set != null) {
          final updatedSet = Set(
            id: set.id,
            matchId: set.matchId,
            setIndex: set.setIndex,
            startRotation: set.startRotation,
            startServeReceiveState: set.startServeReceiveState,
            ourScore: setMap['ourScore'] as int,
            oppScore: setMap['oppScore'] as int,
            ourTimeoutsUsed: setMap['ourTimeoutsUsed'] as int? ?? 0,
            oppTimeoutsUsed: setMap['oppTimeoutsUsed'] as int? ?? 0,
            createdAt: set.createdAt,
          );
          await matchRepository.updateSet(updatedSet);
        }

        // Import rallies
        final ralliesData = setMap['rallies'] as List<dynamic>?;
        if (ralliesData != null) {
          for (final rallyData in ralliesData) {
            final rallyMap = rallyData as Map<String, dynamic>;
            await matchRepository.addRally(
              setId,
              rallyMap['rallyIndex'] as int,
              rallyMap['rotationAtStart'] as int,
              rallyMap['weWereServing'] as bool,
              rallyMap['outcome'] as String,
              rallyMap['weWon'] as bool,
            );
          }
        }
      }
    }
  }
}
