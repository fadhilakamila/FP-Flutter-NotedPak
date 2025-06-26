// lib/widgets/search_field.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../change_notifiers/notes_provider.dart';
import '../core/constants.dart'; // Import constants

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final NotesProvider notesProvider;
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    notesProvider = context
        .read<NotesProvider>(); // Menggunakan context.read<NotesProvider>()
    searchController = TextEditingController()
      ..addListener(() {
        notesProvider.searchTerm = searchController.text;
      });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search notes...',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF8A8A8A),
        ), // Sesuaikan warna hint
        prefixIcon: const Icon(
          Icons.search,
          size: 24,
          color: Color(0xFF8A8A8A),
        ), // Mengganti ikon dan menyesuaikan ukuran/warna
        suffixIcon: ListenableBuilder(
          listenable: searchController,
          builder: (context, clearButton) => searchController.text.isNotEmpty
              ? clearButton!
              : const SizedBox.shrink(),
          child: GestureDetector(
            onTap: () {
              searchController.clear();
            },
            child: const Icon(
              Icons.clear,
              color: Color(0xFF8A8A8A),
            ), // Mengganti ikon dan menyesuaikan warna
          ),
        ),
        fillColor: Colors.white, // Sesuai gambar
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ), // Sesuaikan padding
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            10,
          ), // Radius lebih kecil dari gambar
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0), // Warna border abu-abu muda
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: primary, // Warna biru utama saat fokus
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
