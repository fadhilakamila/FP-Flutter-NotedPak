// lib/pages/main_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../main.dart';

// Import komponen-komponen baru
import '../widgets/search_field.dart';
import '../widgets/view_options.dart';
import '../widgets/note_grid.dart';
import '../widgets/note_list.dart';
import '../widgets/note_fab.dart';

import 'package:noted_pak/services/auth_service.dart';
import 'package:noted_pak/widgets/confirmation_dialog.dart';

import '../models/note.dart';
import '../change_notifiers/notes_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

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
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width * 0.7,
        size.height * 0.75,
      ),
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(rect1, paint);

    final rect2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 0.75,
      ),
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
              // Widget profil yang lama telah diganti dengan tombol logout
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFF5B9BD5),
                    size: 28,
                  ),
                  tooltip: 'Logout',
                  onPressed: () async {
                    // Menampilkan dialog konfirmasi sebelum logout
                    final bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return const ConfirmationDialog(
                          title: 'Confirm Logout',
                          content: 'Are you sure you want to log out?',
                          confirmButtonText: 'Logout',
                          confirmButtonColor: Colors.red,
                        );
                      },
                    );

                    // Jika pengguna mengonfirmasi, lakukan proses logout
                    if (confirmed == true) {
                      await AuthService().signOut();
                      if (context.mounted) {
                        // Kembali ke halaman login dan hapus semua rute sebelumnya
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (Route<dynamic> route) => false);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchField(),
              ),
              const SizedBox(height: 10),
              const ViewOptions(),
              Expanded(
                child: notes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CustomPaint(
                                painter: NotedPakIconPainter(),
                              ),
                            ),
                            const SizedBox(height: 32),
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
          floatingActionButton: NoteFab(
            onPressed: () {
              _showAddNoteDialog(context); // Langsung ke halaman new note
            },
          ),
        );
      },
    );
  }

  void _handleNoteResult(BuildContext context, Map<String, dynamic>? noteData) {
    if (noteData != null) {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);

      DateTime createdDate = noteData['dateCreated'] is DateTime
          ? noteData['dateCreated']
          : DateTime.parse(noteData['dateCreated']);
      DateTime lastModifiedDate = noteData['dateModified'] is DateTime
          ? noteData['dateModified']
          : DateTime.parse(noteData['dateModified']);

      Note newOrUpdatedNote = Note(
        id: noteData['id'] as String?,
        title: noteData['title'],
        content: noteData['content'],
        tags: List<String>.from(noteData['tags'] ?? []),
        dateCreated: createdDate,
        dateModified: lastModifiedDate,
      );

      if (notesProvider.notes.any((n) => n.id == newOrUpdatedNote.id)) {
        notesProvider.updateNote(newOrUpdatedNote);
      } else {
        notesProvider.addNote(newOrUpdatedNote);
      }
    }
  }

  // Hapus _showFabOptions dan _showOcrOptions dari sini
  // void _showFabOptions(BuildContext context) { ... }
  // void _showOcrOptions(BuildContext context) { ... }
  // void _navigateToNewNoteWithContent(BuildContext context, String content) async { ... }

  void _showAddNoteDialog(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/new_note');
    if (!context.mounted) return;
    _handleNoteResult(context, result as Map<String, dynamic>?);
  }
}
