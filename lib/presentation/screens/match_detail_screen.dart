import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/presentation/providers/match_providers.dart';
import 'package:vbstats/presentation/providers/database_providers.dart';
import 'package:vbstats/presentation/screens/set_start_screen.dart';
import 'package:vbstats/presentation/screens/live_set_screen.dart';
import 'package:vbstats/core/services/match_import_export_service.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final Match match;

  const MatchDetailScreen({required this.match, Key? key}) : super(key: key);

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  late Match currentMatch;

  @override
  void initState() {
    super.initState();
    currentMatch = widget.match;
  }

  @override
  Widget build(BuildContext context) {
    final setsAsync = ref.watch(matchSetsProvider(currentMatch.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(currentMatch.displayName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditMatchDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => _exportMatch(context, ref),
            tooltip: 'Export Match',
          ),
        ],
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
                      'vs ${currentMatch.opponentName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM d, yyyy').format(currentMatch.date),
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    if (currentMatch.eventName != null)
                      Text(
                        currentMatch.eventName!,
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
                                    builder: (context) => SetStartScreen(match: currentMatch),
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
                          return Dismissible(
                            key: Key(set.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Set'),
                                  content: Text(
                                    'Are you sure you want to delete Set ${set.setIndex}? This will also delete all rallies in this set.',
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
                            },
                            onDismissed: (direction) async {
                              final repo = await ref.read(matchRepositoryProvider.future);
                              await repo.deleteSet(set.id);
                              ref.invalidate(matchSetsProvider(currentMatch.id));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Set ${set.setIndex} deleted'),
                                    action: SnackBarAction(
                                      label: 'Dismiss',
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
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
                                        match: currentMatch,
                                        setId: set.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
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
                          builder: (context) => SetStartScreen(match: currentMatch),
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

  void _showEditMatchDialog(BuildContext context, WidgetRef ref) {
    final opponentController = TextEditingController(text: currentMatch.opponentName);
    final eventController = TextEditingController(text: currentMatch.eventName ?? '');
    DateTime selectedDate = currentMatch.date;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Match'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: opponentController,
                  decoration: const InputDecoration(
                    labelText: 'Opponent Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: eventController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Match Date'),
                  subtitle: Text(DateFormat('MMMM d, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (opponentController.text.trim().isEmpty) return;

                final updatedMatch = Match(
                  id: currentMatch.id,
                  teamId: currentMatch.teamId,
                  opponentName: opponentController.text.trim(),
                  eventName: eventController.text.trim().isEmpty
                      ? null
                      : eventController.text.trim(),
                  date: selectedDate,
                  createdAt: currentMatch.createdAt,
                );

                final repo = await ref.read(matchRepositoryProvider.future);
                await repo.updateMatch(updatedMatch);
                ref.invalidate(matchSetsProvider(currentMatch.id));

                if (mounted) {
                  setState(() {
                    currentMatch = updatedMatch;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportMatch(BuildContext context, WidgetRef ref) async {
    try {
      final repo = await ref.read(matchRepositoryProvider.future);
      final service = MatchImportExportService(repo);
      
      await service.exportMatch(currentMatch.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
