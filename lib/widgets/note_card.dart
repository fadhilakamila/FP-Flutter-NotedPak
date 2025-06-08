// lib/widgets/note_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

import '../models/note.dart';
import '../core/constants.dart';

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
    // Membungkus seluruh kartu dengan GestureDetector agar bisa diklik
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman NewOrEditNotePage
        // dan kirim data catatan yang sedang diklik
        Navigator.pushNamed(
          context,
          '/edit_note', // Ini adalah rute yang sudah didefinisikan di main.dart
          arguments: {
            'existingNote': {
              'id': note.id,
              'title': note.title,
              'content': note.content,
              'tags': note.tags,
              'createdDate': note.dateCreated.toIso8601String(), // Pastikan format ISO 8601 String
              'lastModifiedDate': note.dateModified.toIso8601String(), // Pastikan format ISO 8601 String
              'type': note.type.toString().split('.').last, // Kirim nama enum sebagai String
            },
            'isReadOnly': false, // Bisa atur ini ke true jika ingin mode hanya lihat
          },
        );
      },
      child: Card( // Menggunakan Card sebagai pengganti Container agar memiliki elevasi dan bentuk bawaan
        // Mempertahankan BoxDecoration dari Container sebelumnya untuk kontrol yang lebih baik
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Radius sudut kartu
        ),
        elevation: 2, // Memberikan sedikit bayangan
        margin: isInGrid ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 6, horizontal: 10), // Margin disesuaikan
        clipBehavior: Clip.antiAlias, // Penting untuk memastikan konten terpotong sesuai border radius
        child: Container( // Ini adalah konten internal Card
          decoration: BoxDecoration( // Warna dan border berada di Container internal
            color: Colors.white,
            borderRadius: BorderRadius.circular(10), // Tetap pertahankan radius agar sesuai dengan Card
            // Tidak perlu boxShadow lagi karena sudah ada elevation dari Card
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      ],
    );
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