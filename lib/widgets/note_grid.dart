// lib/widgets/notes_grid.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import 'note_card.dart';
import '../change_notifiers/notes_provider.dart'; // Import NotesProvider

class NotesGrid extends StatelessWidget {
  const NotesGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final notes = notesProvider.notes;
        return GridView.builder(
          itemCount: notes.length,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Padding grid
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16, // Jarak antar kolom
            mainAxisSpacing: 16, // Jarak antar baris
            childAspectRatio: 0.7, // Sesuaikan rasio aspek kartu agar sesuai gambar
          ),
          itemBuilder: (context, int index) {
            return NoteCard(
              note: notes[index],
              isInGrid: true, // Pastikan ini true untuk tampilan grid
            );
          },
        );
      },
    );
  }
}