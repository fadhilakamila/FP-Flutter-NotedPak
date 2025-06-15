// lib/widgets/notes_grid.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart'; // Tidak diperlukan lagi untuk pengelompokan tanggal
// import '../models/note.dart'; // Tidak diperlukan lagi untuk pengelompokan tanggal

import 'note_card.dart';
import '../change_notifiers/notes_provider.dart'; // Import NotesProvider

// ====================================================================
// BAGIAN INI DIHAPUS: DEFINISI WIDGET HEADER DAN DELEGATE TIDAK DIGUNAKAN LAGI
// ====================================================================

// HAPUS ATAU KOMEN SELURUH BLOK BERIKUT
/*
// Widget untuk tampilan header tanggal
class _StickyDateHeader extends StatelessWidget {
  final String headerText;
  final Color backgroundColor;
  final Color textColor;

  const _StickyDateHeader({
    required this.headerText,
    this.backgroundColor = const Color(0xFFF5F7FA),
    this.textColor = const Color(0xFF8A8A8A),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          headerText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// Delegate untuk membuat header menjadi sticky
class _SliverDateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String headerText;
  final Color backgroundColor;
  final Color textColor;

  _SliverDateHeaderDelegate({
    required this.headerText,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _StickyDateHeader(
      headerText: headerText,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant _SliverDateHeaderDelegate oldDelegate) {
    return oldDelegate.headerText != headerText ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.textColor != textColor;
  }
}
*/
// ====================================================================
// AKHIR BAGIAN YANG DIHAPUS
// ====================================================================

class NotesGrid extends StatelessWidget {
  const NotesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final notes = notesProvider
            .notes; // Menggunakan semua catatan, tidak lagi dikelompokkan

        // Jika tidak ada catatan, tampilkan pesan kosong
        if (notes.isEmpty) {
          return const Center(
            child: Text(
              'No notes to display.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        // Menggunakan CustomScrollView dengan SliverPadding dan SliverGrid
        return CustomScrollView(
          slivers: [
            SliverPadding(
              // <-- Menambahkan padding horizontal di sini
              padding: const EdgeInsets.symmetric(
                horizontal: 16, // Padding kiri dan kanan
                vertical: 8, // Padding atas dan bawah
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16, // Jarak antar kolom
                  mainAxisSpacing: 16, // Jarak antar baris
                  childAspectRatio: 0.7, // Sesuaikan rasio aspek kartu
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return NoteCard(note: notes[index], isInGrid: true);
                  },
                  childCount: notes.length, // Jumlah total catatan
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
