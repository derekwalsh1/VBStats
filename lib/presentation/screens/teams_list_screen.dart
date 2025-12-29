import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/presentation/providers/team_providers.dart';
import 'package:vbstats/presentation/providers/database_providers.dart';
import 'package:vbstats/presentation/screens/team_matches_screen.dart';

class TeamsListScreen extends ConsumerWidget {
  const TeamsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Teams'),
        centerTitle: true,
      ),
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading teams: $error'),
        ),
        data: (teams) {
          if (teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No teams yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTeamDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Team'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(team.name[0].toUpperCase()),
                  ),
                  title: Text(team.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditTeamDialog(context, ref, team),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TeamMatchesScreen(team: team),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTeamDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditTeamDialog(BuildContext context, WidgetRef ref, Team team) {
    final controller = TextEditingController(text: team.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Team'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Team Name',
            hintText: 'Enter team name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              
              final updatedTeam = Team(
                id: team.id,
                name: controller.text.trim(),
                createdAt: team.createdAt,
              );
              
              final repo = await ref.read(teamRepositoryProvider.future);
              await repo.updateTeam(updatedTeam);
              ref.invalidate(teamsProvider);
              
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddTeamDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Team'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Team Name',
            hintText: 'Enter team name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              
              final repo = await ref.read(teamRepositoryProvider.future);
              await repo.createTeam(controller.text.trim());
              ref.invalidate(teamsProvider);
              
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
