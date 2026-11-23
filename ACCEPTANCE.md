# Form validation: acceptance criteria

The Save entry button is always enabled. When the form is not valid, it shows
a message instead of silently doing nothing. Notes may be at most 2000
characters (`maxNoteLength`).

1. Given no score is selected, when I tap Save entry, then the message
   "Choose a score from 1 to 10" appears under the chips and nothing is added
   to the history (the Entries count stays the same).
2. Given the message from criterion 1 is showing, when I tap a score chip,
   then the message disappears.
3. Given a score is selected and the note is empty, when I tap Save entry,
   then the entry appears at the top of the history, the Entries count goes up
   by one, and the form is cleared.
4. Given a score is selected and the note is exactly 2000 characters, when I
   tap Save entry, then the entry is saved and no error message appears
   (boundary: the limit itself is allowed).
5. Given a score is selected and the note is 2001 characters, when I tap Save
   entry, then the message "Note must be at most 2000 characters" appears
   under the note field, nothing is added to the history, and my score and
   note are kept so I can shorten the note.
6. Given the message from criterion 5 is showing, when I delete one character
   so the note is 2000 characters and tap Save entry, then the entry is saved
   and the message is gone.
7. Given neither a score nor a valid note, when I tap Save entry, then both
   messages appear at the same time.
