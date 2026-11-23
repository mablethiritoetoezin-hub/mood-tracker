import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import '../widgets/mood_card.dart';
import '../widgets/mood_entry_form.dart';
import '../widgets/mood_summary.dart';

/// The home screen: the entry form, a summary card and the history.
///
/// It owns the list of entries, because both the summary and the history
/// need it, and the form hands each new entry up through onSubmit.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.initialEntries});

  final List<MoodEntry> initialEntries;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<MoodEntry> _entries;

  @override
  void initState() {
    super.initState();
    // Copy the list: the widget's list may be const or shared (like the
    // sample data), and adding to it would change it for everyone.
    _entries = List.of(widget.initialEntries);
  }

  void _addEntry(MoodEntry entry) {
    setState(() {
      _entries.insert(0, entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                MoodEntryForm(onSubmit: _addEntry),
                const SizedBox(height: 16),
                MoodSummary(entries: _entries),
                const SizedBox(height: 24),
                Text('History', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final entry in _entries) MoodCard(entry: entry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
