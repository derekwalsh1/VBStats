import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vbstats/domain/entities/enums.dart';
import 'package:vbstats/domain/entities/match_entities.dart';
import 'package:vbstats/domain/repositories/match_repository.dart';
import 'package:vbstats/presentation/providers/database_providers.dart';
import 'package:vbstats/presentation/screens/live_set_screen.dart';

class SetStartScreen extends ConsumerStatefulWidget {
  final Match match;

  const SetStartScreen({required this.match, Key? key}) : super(key: key);

  @override
  ConsumerState<SetStartScreen> createState() => _SetStartScreenState();
}

class _SetStartScreenState extends ConsumerState<SetStartScreen> {
  int? _selectedRotation;
  ServeReceiveState? _selectedServeReceive;
  bool _isLoading = false;

  Future<void> _startSet() async {
    if (_selectedRotation == null || _selectedServeReceive == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rotation and serve/receive state')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = await ref.read(matchRepositoryProvider.future);
      
      // Get next set index
      final sets = await repo.getSetsByMatch(widget.match.id);
      final nextSetIndex = sets.isEmpty ? 1 : sets.length + 1;

      // Create set
      final setId = await repo.createSet(
        widget.match.id,
        nextSetIndex,
        _selectedRotation!,
        _selectedServeReceive! == ServeReceiveState.serve,
      );

      if (mounted) {
        // Navigate to live set screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LiveSetScreen(
              match: widget.match,
              setId: setId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating set: $e')),
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
        title: const Text('Start New Set'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rotation selection
            const Text(
              'Select Starting Rotation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final rotation = index + 1;
                final isSelected = _selectedRotation == rotation;

                return GestureDetector(
                  onTap: _isLoading ? null : () {
                    setState(() => _selectedRotation = rotation);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepOrange
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepOrange
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$rotation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Serve/Receive selection
            const Text(
              'Starting State',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStateButton(
                    'Serving',
                    ServeReceiveState.serve,
                    _selectedServeReceive == ServeReceiveState.serve,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStateButton(
                    'Receiving',
                    ServeReceiveState.receive,
                    _selectedServeReceive == ServeReceiveState.receive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _startSet,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start Set'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateButton(
    String label,
    ServeReceiveState state,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: _isLoading ? null : () {
        setState(() => _selectedServeReceive = state);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
