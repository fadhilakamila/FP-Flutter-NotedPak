// lib/pages/main_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Import komponen-komponen baru
import '../widgets/search_field.dart';
import '../widgets/view_options.dart';
import '../widgets/note_grid.dart';
import '../widgets/note_list.dart';
import '../widgets/note_fab.dart';
import '../widgets/message_dialog.dart';

import '../models/note.dart';
import '../change_notifiers/notes_provider.dart';
import '../core/constants.dart';
import '../enums/order_option.dart';

// Custom painter tetap sama
class NotedPakIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final blueColor = const Color(0xFF5B9BD5);
    final strokeWidth = size.width * 0.08;

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = blueColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width * 0.7, size.height * 0.75),
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(rect1, paint);

    final rect2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.2, size.width * 0.7, size.height * 0.75),
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(rect2, paint);

    final foldSize = size.width * 0.15;
    final docRight = size.width * 0.95;
    final docBottom = size.height * 0.95;

    paint
      ..style = PaintingStyle.fill
      ..color = blueColor;
    final foldPath = Path();
    foldPath.moveTo(docRight - foldSize, docBottom);
    foldPath.lineTo(docRight, docBottom - foldSize);
    foldPath.quadraticBezierTo(
      docRight - foldSize * 0.4,
      docBottom - foldSize * 0.4,
      docRight,
      docBottom,
    );
    foldPath.close();
    canvas.drawPath(foldPath, paint);

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.6
      ..color = blueColor;
    final foldLine = Path();
    foldLine.moveTo(docRight - foldSize, docBottom);
    foldLine.lineTo(docRight, docBottom - foldSize);
    canvas.drawPath(foldLine, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class NotedPakHomePage extends StatelessWidget {
  const NotedPakHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final notes = notesProvider.notes;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 20,
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NotedPak!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B9BD5),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.grey[600], size: 24),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchField(), // Komponen SearchField
              ),
              const SizedBox(height: 10),
              const ViewOptions(),
              Expanded(
                child: notes.isEmpty
                    ? Center( // Jika catatan kosong, tampilkan logo dan teks "You have no notes yet"
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon/Logo NotedPak
                            Container(
                              width: 120,
                              height: 120,
                              child: CustomPaint(
                                painter: NotedPakIconPainter(),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Text "You have no notes yet"
                            Column(
                              children: [
                                Text(
                                  'You have no notes yet,',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: const Color(0xFF5B9BD5),
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Start creating by pressing the + button below!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: const Color(0xFF5B9BD5),
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : notesProvider.isGrid
                        ? const NotesGrid()
                        : const NotesList(),
              ),
            ],
          ),
          floatingActionButton: NoteFab( // <--- PERUBAHAN PENTING: MENGGANTI KODE LAMA DENGAN NoteFab
            onPressed: () {
              _showAddNoteDialog(context); // Memanggil fungsi yang sudah ada
            },
          ),
        );
      },
    );
  }

  void _handleNoteResult(BuildContext context, Map<String, dynamic>? noteData) {
    if (noteData != null) {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);

      NoteType noteType;
      try {
        noteType = NoteType.values.firstWhere(
            (e) => e.toString().split('.').last == noteData['type'],
            orElse: () => NoteType.daily);
      } catch (e) {
        noteType = NoteType.daily;
      }
      
      DateTime createdDate = DateTime.parse(noteData['createdDate']);
      DateTime lastModifiedDate = DateTime.parse(noteData['lastModifiedDate']);

      Note newOrUpdatedNote = Note(
        id: noteData['id'] ?? (notesProvider.notes.length + 1).toString(),
        title: noteData['title'],
        content: noteData['content'],
        tags: List<String>.from(noteData['tags'] ?? []),
        dateCreated: createdDate,
        dateModified: lastModifiedDate,
        type: noteType,
      );

      if (notesProvider.notes.any((n) => n.id == newOrUpdatedNote.id)) {
        notesProvider.updateNote(newOrUpdatedNote);
      } else {
        notesProvider.addNote(newOrUpdatedNote);
      }
    }
  }

  void _showAddNoteDialog(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      '/new_note',
    );
    _handleNoteResult(context, result as Map<String, dynamic>?);
  }
}