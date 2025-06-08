// lib/widgets/view_options.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../change_notifiers/notes_provider.dart';
import '../core/constants.dart';
import '../enums/order_option.dart';
import 'note_icon_button.dart';

class ViewOptions extends StatefulWidget {
  const ViewOptions({super.key});

  @override
  State<ViewOptions> createState() => _ViewOptionsState();
}

class _ViewOptionsState extends State<ViewOptions> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (_, notesProvider, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding sesuai gambar
        child: Row(
          children: [
            // Icon tanggal untuk pengurutan
            const Icon(
              Icons.date_range, // Menggunakan ikon tanggal
              size: 20,
              color: Color(0xFF8A8A8A), // Warna abu-abu seperti gambar
            ),
            const SizedBox(width: 8),
            // Dropdown untuk opsi pengurutan
            Container( // Menambahkan Container untuk latar belakang putih dan border
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding di dalam kotak
              decoration: BoxDecoration(
                color: Colors.white, // Latar belakang putih
                borderRadius: BorderRadius.circular(10), // Sudut membulat
                border: Border.all(
                  color: const Color(0xFFE0E0E0), // Warna border abu-abu muda
                  width: 1.0,
                ),
              ),
              child: DropdownButton<OrderOption>(
                value: notesProvider.orderBy,
                // Mengubah ikon menjadi segitiga ke bawah (dropdown)
                icon: const Icon(
                  Icons.arrow_drop_down, // Ikon segitiga ke bawah
                  size: 24, // Ukuran ikon dropdown
                  color: Color(0xFF8A8A8A), // Warna abu-abu
                ),
                underline: const SizedBox.shrink(), // Menghilangkan garis bawah
                borderRadius: BorderRadius.circular(8),
                isDense: true,
                items: OrderOption.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e == OrderOption.dateModified ? 'Date modified' : 'Date created',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) {
                  // Saat opsi diubah, update notesProvider.orderBy
                  notesProvider.orderBy = newValue!;
                },
              ),
            ),
            // Tombol untuk mengubah arah pengurutan (Ascending/Descending)
            NoteIconButton(
              icon: notesProvider.isDescending
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              size: 16,
              onPressed: () {
                notesProvider.isDescending = !notesProvider.isDescending; // Toggle isDescending
              },
            ),
            const Spacer(),
            // Ikon grid/list
            NoteIconButton(
              icon: notesProvider.isGrid
                  ? Icons.grid_view // Ikon grid
                  : Icons.list, // Ikon list
              size: 20,
              onPressed: () {
                notesProvider.isGrid = !notesProvider.isGrid; // Toggle isGrid
              },
            ),
          ],
        ),
      ),
    );
  }
}