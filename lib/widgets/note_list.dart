// lib/widgets/notes_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note_card.dart';
import '../change_notifiers/notes_provider.dart';

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final notes = notesProvider.notes;
        return ListView.builder(
          itemCount: notes.length,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ), // Padding list
          itemBuilder: (context, int index) {
            return NoteCard(
              note: notes[index],
              isInGrid: false, // Pastikan ini false untuk tampilan list
            );
          },
        );
      },
    );
  }
}
