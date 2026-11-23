import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker/data/sample_entries.dart';
import 'package:mood_tracker/main.dart';
import 'package:mood_tracker/models/mood_entry.dart';
import 'package:mood_tracker/widgets/mood_card.dart';

// Widget tests for the entry form and history.

/// Renders the app in a window tall enough for every card to be built.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 5000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MoodTrackerApp());
}

Finder get saveButton => find.widgetWithText(FilledButton, 'Save entry');

void expectEntriesCount(WidgetTester tester, int count) {
  final entriesLabel = tester.element(find.text('Entries'));
  final entriesColumn = entriesLabel.findAncestorWidgetOfExactType<Column>()!;
  expect(
    find.descendant(
      of: find.byWidget(entriesColumn),
      matching: find.text('$count'),
    ),
    findsOneWidget,
  );
}

void main() {
  testWidgets('Save stays enabled and reports a missing score', (tester) async {
    await pumpApp(tester);

    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
    expectEntriesCount(tester, sampleEntries.length);

    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Choose a score from 1 to 10'), findsOneWidget);
    expectEntriesCount(tester, sampleEntries.length);
    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length));
  });

  testWidgets('choosing a score clears the missing-score message', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text('Choose a score from 1 to 10'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();

    expect(find.text('Choose a score from 1 to 10'), findsNothing);
  });

  testWidgets('an empty note is saved and the form is cleared', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.tap(saveButton);
    await tester.pump();

    expectEntriesCount(tester, sampleEntries.length + 1);
    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '3')).selected,
      isFalse,
    );
  });

  testWidgets('a note at the character limit is saved', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.enterText(find.byType(TextField), 'a' * maxNoteLength);
    await tester.tap(saveButton);
    await tester.pump();

    expect(
      find.text('Note must be at most $maxNoteLength characters'),
      findsNothing,
    );
    expectEntriesCount(tester, sampleEntries.length + 1);
  });

  testWidgets('a too-long note shows an error and preserves the form', (
    tester,
  ) async {
    final note = 'a' * (maxNoteLength + 1);
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.enterText(find.byType(TextField), note);
    await tester.tap(saveButton);
    await tester.pump();

    expect(
      find.text('Note must be at most $maxNoteLength characters'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      note,
    );
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '3')).selected,
      isTrue,
    );
    expectEntriesCount(tester, sampleEntries.length);
    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length));
  });

  testWidgets('editing a too-long note clears its error and allows saving', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.enterText(find.byType(TextField), 'a' * (maxNoteLength + 1));
    await tester.tap(saveButton);
    await tester.pump();
    expect(
      find.text('Note must be at most $maxNoteLength characters'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'a' * maxNoteLength);
    await tester.pump();
    expect(
      find.text('Note must be at most $maxNoteLength characters'),
      findsNothing,
    );

    await tester.tap(saveButton);
    await tester.pump();
    expectEntriesCount(tester, sampleEntries.length + 1);
  });

  testWidgets('the trimmed note is used for validation and saved', (
    tester,
  ) async {
    final note = 'a' * maxNoteLength;
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.enterText(find.byType(TextField), ' $note ');
    await tester.tap(saveButton);
    await tester.pump();

    expect(
      find.text('Note must be at most $maxNoteLength characters'),
      findsNothing,
    );
    expectEntriesCount(tester, sampleEntries.length + 1);
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text(note),
      ),
      findsOneWidget,
    );
  });

  testWidgets('missing score and an invalid note show both messages', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'a' * (maxNoteLength + 1));
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Choose a score from 1 to 10'), findsOneWidget);
    expect(
      find.text('Note must be at most $maxNoteLength characters'),
      findsOneWidget,
    );
    expectEntriesCount(tester, sampleEntries.length);
  });

  testWidgets('saving an entry puts it at the top of the history', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Rainy walk home');
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text('Rainy walk home'),
      ),
      findsOneWidget,
    );
  });
}
