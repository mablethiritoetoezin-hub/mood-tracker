import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import 'mood_score_selector.dart';

/// A form for recording a new mood entry.
///
/// Exercise 1, step 3, and Exercise 2, steps 1-3.
class MoodEntryForm extends StatefulWidget {
  const MoodEntryForm({super.key, required this.onSubmit});

  /// Called with the new entry when the user saves it.
  final ValueChanged<MoodEntry> onSubmit;

  @override
  State<MoodEntryForm> createState() => _MoodEntryFormState();
}

class _MoodEntryFormState extends State<MoodEntryForm> {
  /// The selected score. It starts with nothing selected.
  int? _score;

  /// Holds the text of the note field. It owns resources and listeners, so
  /// whoever creates it must also dispose of it.
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final score = _score;
    if (score == null) return;

    final note = _noteController.text.trim();
    widget.onSubmit(
      MoodEntry(
        score: score,
        note: note.isEmpty ? null : note,
        createdAt: DateTime.now(),
      ),
    );

    setState(() {
      _score = null;
    });
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            MoodScoreSelector(
              selectedScore: _score,
              onChanged: (score) {
                // Without setState the value changes but build() does not
                // run again, so the chip would not look selected.
                setState(() {
                  _score = score;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 12),
            FilledButton(
              // null disables the button until a score is chosen.
              onPressed: _score == null ? null : _save,
              child: const Text('Save entry'),
            ),
          ],
        ),
      ),
    );
  }
}
