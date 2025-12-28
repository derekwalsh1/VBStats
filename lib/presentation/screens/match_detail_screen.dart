import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/presentation/providers/match_providers.dart';
import 'package:vbstats/presentation/screens/set_start_screen.dart';
import 'package:vbstats/presentation/screens/live_set_screen.dart';

class MatchDetailScreen extends ConsumerWidget {
  final Match match;

  const MatchDetailScreen({required this.match, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(matchSetsProvider(match.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(match.displayName),
        centerTitle: true,
      ),
      body: setsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading sets: $error'),
        ),
        data: (sets) {
          return Column(
            children: [
              // Match header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs ${match.opponentName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (match.eventName != null)
                      Text(
                        match.eventName!,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
              // Sets list
              Expanded(
                child: sets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No sets yet'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SetStartScreen(match: match),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Set'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: sets.length,
                        itemBuilder: (context, index) {
                          final set = sets[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text('Set ${set.setIndex}'),
                              subtitle: Text(
                                '${set.ourScore} - ${set.oppScore}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LiveSetScreen(
                                      match: match,
                                      setId: set.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              // Add Set button
              if (sets.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SetStartScreen(match: match),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Set'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
