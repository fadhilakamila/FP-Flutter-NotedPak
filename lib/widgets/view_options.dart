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
            DropdownButton<OrderOption>(
              value: notesProvider.orderBy,
              icon: Icon(
                notesProvider.isDescending
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                size: 16,
                color: Color(0xFF8A8A8A),
              ), // Ikon panah naik/turun
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(8),
              isDense: true,
              items: OrderOption.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e == OrderOption.dateModified ? 'Date modified' : 'Date created', // Teks yang lebih mudah dimengerti
                        style: const TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)), // Ukuran dan warna font
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  notesProvider.orderBy = newValue!;
                });
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
                setState(() {
                  notesProvider.isGrid = !notesProvider.isGrid;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}