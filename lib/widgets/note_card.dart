import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';
import '../widgets/note_tag.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.note,
    this.isInGrid = true,
    super.key,
  });

  final Note note;
  final bool isInGrid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/edit_note',
          arguments: {
            'existingNote': {
              'id': note.id,
              'title': note.title,
              'content': note.content,
              'tags': note.tags,
              'dateCreated': note.dateCreated.toIso8601String(),
              'dateModified': note.dateModified.toIso8601String(),
            },
            'isReadOnly': false,
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        margin: isInGrid
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 10,
              ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: isInGrid ? _buildGridContent() : _buildListContent(),
        ),
      ),
    );
  }

  // Metode pembangun konten untuk tampilan grid
  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('d MMM').format(note.dateModified).toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8A8A8A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          note.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child:
              // Gunakan TagList untuk menampilkan semua tag
              TagList(
            tags: note.tags.isEmpty ? ['Uncategorized'] : note.tags,
            spacing: 4.0, // Jarak antar tag horizontal
            runSpacing: 4.0, // Jarak antar baris tag vertikal
            showAddButton: false, // Tidak perlu tombol tambah tag di NoteCard
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Text(
            note.content,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Metode pembangun konten untuk tampilan list
  Widget _buildListContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('d MMM').format(note.dateModified).toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8A8A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Gunakan TagList untuk menampilkan semua tag
              TagList(
                tags: note.tags.isEmpty ? ['Uncategorized'] : note.tags,
                spacing: 4.0,
                runSpacing: 4.0,
                showAddButton: false,
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}