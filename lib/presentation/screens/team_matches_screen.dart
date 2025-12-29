import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/presentation/providers/team_providers.dart';
import 'package:vbstats/presentation/providers/database_providers.dart';
import 'package:vbstats/presentation/screens/match_detail_screen.dart';

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

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text('vs ${match.opponentName}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('MMM d, yyyy').format(match.date)),
                            if (match.eventName != null)
                              Text(match.eventName!),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MatchDetailScreen(match: match),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateMatchDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Match'),
                ),
              ),
            ],
          );
        },
      ),
    );
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
}
