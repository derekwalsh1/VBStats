import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/presentation/providers/match_providers.dart';
import 'package:vbstats/presentation/providers/team_providers.dart';
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
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: sets.length + 1, // +1 for add set tile
                          itemBuilder: (context, index) {
                            if (index == sets.length) {
                              // Add set tile
                              return Card(
                                elevation: 4,
                                color: Colors.grey.shade200,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SetStartScreen(match: currentMatch),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_circle_outline, size: 48, color: Colors.grey.shade600),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add Set',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            final set = sets[index];
                            final bool weWon = set.ourScore > set.oppScore;
                            return Card(
                              elevation: 4,
                              child: InkWell(
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
                                onLongPress: () => _showDeleteSetConfirmation(context, ref, set),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Set ${set.setIndex}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${set.ourScore}',
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: weWon ? Colors.green : Colors.red,
                                            ),
                                          ),
                                          const Text(
                                            ' - ',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                          Text(
                                            '${set.oppScore}',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        weWon ? Icons.check_circle : Icons.cancel,
                                        color: weWon ? Colors.green : Colors.red,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteSetConfirmation(BuildContext context, WidgetRef ref, Set set) async {
    final confirmed = await showDialog<bool>(
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
    
    if (confirmed == true && context.mounted) {
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
    }
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
                
                // Invalidate providers to refresh all views
                ref.invalidate(matchSetsProvider(currentMatch.id));
                ref.invalidate(teamMatchesProvider(currentMatch.teamId));

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
      
      // Get screen bounds for iPad share position
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      
      await service.exportMatch(currentMatch.id, sharePositionOrigin: sharePositionOrigin);
      
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
