import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/presentation/providers/match_providers.dart';
import 'package:vbstats/presentation/providers/database_providers.dart';
import 'package:vbstats/presentation/screens/match_detail_screen.dart';

class NewMatchScreen extends ConsumerStatefulWidget {
  const NewMatchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NewMatchScreen> createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends ConsumerState<NewMatchScreen> {
  late TextEditingController _opponentController;
  late TextEditingController _eventController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _opponentController = TextEditingController();
    _eventController = TextEditingController();
  }

  @override
  void dispose() {
    _opponentController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  Future<void> _createMatch() async {
    final opponent = _opponentController.text.trim();
    if (opponent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter opponent name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final event = _eventController.text.trim().isEmpty
          ? null
          : _eventController.text.trim();

      final matchId = await ref.read(
        createMatchProvider((opponent, event)).future,
      );

      // Invalidate matches list
      ref.invalidate(matchesProvider);

      // Get the created match and navigate to detail
      final repo = await ref.read(matchRepositoryProvider.future);
      final match = await repo.getMatchById(matchId);

      if (mounted && match != null) {
        // Pop the new match screen and push match detail
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(match: match),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating match: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Match'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Match Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _opponentController,
              decoration: InputDecoration(
                labelText: 'Opponent Name *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.groups),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _eventController,
              decoration: InputDecoration(
                labelText: 'Event Name (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.event),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _createMatch,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Match'),
            ),
          ],
        ),
      ),
    );
  }
}
