// lib/widgets/note_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

import '../models/note.dart';
import '../core/constants.dart'; // Import constants

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.note,
    this.isInGrid = true, // Tambahkan properti untuk menentukan tampilan grid atau list
    super.key,
  });

  final Note note;
  final bool isInGrid;

  @override
  Widget build(BuildContext context) {
    if (isInGrid) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Radius sudut kartu
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('d MMM').format(note.dateModified).toUpperCase(), // Format tanggal
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF8A8A8A), // Warna abu-abu untuk tanggal
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333), // Warna teks judul
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getChipColor(note.type), // Warna chip berdasarkan tipe
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  note.type.name, // Teks tipe catatan
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666), // Warna teks konten
                ),
                maxLines: 4, // Sesuaikan sesuai kebutuhan
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else {
      // Tampilan list
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), // Margin untuk tampilan list
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getChipColor(note.type),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      note.type.name,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Bisa tambahkan ikon atau indikator lain di sini jika perlu
          ],
        ),
      );
    }
  }

  Color _getChipColor(NoteType type) {
    switch (type) {
      case NoteType.daily:
        return const Color(0xFF6EC6FF); // Biru muda
      case NoteType.college:
        return const Color(0xFFFFA726); // Oranye
      case NoteType.work:
        return const Color(0xFF4CAF50); // Hijau
      case NoteType.hobby:
        return const Color(0xFF9C27B0); // Ungu
      case NoteType.life:
        return const Color(0xFFEF5350); // Merah
      default:
        return Colors.grey;
    }
  }
}