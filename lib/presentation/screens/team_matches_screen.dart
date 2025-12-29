import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/presentation/providers/team_providers.dart';
import 'package:vbstats/presentation/providers/database_providers.dart';
import 'package:vbstats/presentation/screens/match_detail_screen.dart';
import 'package:vbstats/core/services/match_import_export_service.dart';

class TeamMatchesScreen extends ConsumerWidget {
  final Team team;

  const TeamMatchesScreen({required this.team, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(teamMatchesProvider(team.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export') {
                await _exportMatches(context, ref);
              } else if (value == 'import') {
                await _importMatches(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('Export Matches'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Import Matches'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading matches: $error'),
        ),
        data: (matches) {
          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No matches yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateMatchDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Match'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: matches.length + 1, // +1 for add match tile
              itemBuilder: (context, index) {
                if (index == matches.length) {
                  // Add match tile
                  return Card(
                    elevation: 4,
                    color: Colors.grey.shade200,
                    child: InkWell(
                      onTap: () => _showCreateMatchDialog(context, ref),
                      onLongPress: () => _showDeleteConfirmation(context, ref, null, index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: 48, color: Colors.grey.shade600),
                            const SizedBox(height: 8),
                            Text(
                              'Add Match',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                
                final match = matches[index];
                return Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MatchDetailScreen(match: match),
                        ),
                      );
                    },
                    onLongPress: () => _showDeleteConfirmation(context, ref, match, index),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            child: Text(
                              match.opponentName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'vs ${match.opponentName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(match.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (match.eventName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              match.eventName!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Match? match, int index) async {
    if (match == null) return; // Don't delete the add tile
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: Text(
          'Are you sure you want to delete the match against ${match.opponentName}? This will also delete all sets and rallies.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final repo = await ref.read(matchRepositoryProvider.future);
      await repo.deleteMatch(match.id);
      ref.invalidate(teamMatchesProvider(team.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Match against ${match.opponentName} deleted'),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _showCreateMatchDialog(BuildContext context, WidgetRef ref) {
    final opponentController = TextEditingController();
    final eventController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Match'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: opponentController,
              decoration: const InputDecoration(
                labelText: 'Opponent Name',
                hintText: 'Enter opponent name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: eventController,
              decoration: const InputDecoration(
                labelText: 'Event Name (Optional)',
                hintText: 'Tournament, league, etc.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (opponentController.text.trim().isEmpty) return;
              
              final repo = await ref.read(matchRepositoryProvider.future);
              final matchId = await repo.createMatch(
                team.id,
                opponentController.text.trim(),
                eventName: eventController.text.trim().isEmpty 
                    ? null 
                    : eventController.text.trim(),
              );
              
              ref.invalidate(teamMatchesProvider(team.id));
              
              if (context.mounted) {
                Navigator.of(context).pop();
                
                // Get the created match and navigate to it
                final match = await repo.getMatchById(matchId);
                if (match != null && context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MatchDetailScreen(match: match),
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportMatches(BuildContext context, WidgetRef ref) async {
    try {
      final repo = await ref.read(matchRepositoryProvider.future);
      final service = MatchImportExportService(repo);
      
      // Get screen bounds for iPad share position
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      
      await service.exportTeamMatches(team.id, sharePositionOrigin: sharePositionOrigin);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Matches exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importMatches(BuildContext context, WidgetRef ref) async {
    try {
      final repo = await ref.read(matchRepositoryProvider.future);
      final service = MatchImportExportService(repo);
      
      final count = await service.importMatches(team.id);
      
      // Refresh the matches list
      ref.invalidate(teamMatchesProvider(team.id));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported $count ${count == 1 ? 'match' : 'matches'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
