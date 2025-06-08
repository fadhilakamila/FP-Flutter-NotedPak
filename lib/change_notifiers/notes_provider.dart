// lib/change_notifiers/notes_provider.dart
import 'package:flutter/material.dart';
import '../models/note.dart'; // Pastikan path ini benar
import '../enums/order_option.dart'; // Pastikan path ini benar

class NotesProvider with ChangeNotifier {
  List<Note> _allNotes = [];
  String _searchTerm = '';
  OrderOption _orderBy = OrderOption.dateModified; // Default pengurutan
  bool _isDescending = true; // Default descending
  bool _isGrid = true; // Default tampilan grid

  NotesProvider() {
    // Data dummy sesuai dengan gambar yang kamu berikan
    _allNotes = [
      Note(
        id: '1',
        title: 'To Do List',
        content: '• House chores\n• 30 min run\n• Read a book\n• Laundry',
        dateModified: DateTime(2025, 5, 31),
        dateCreated: DateTime(2025, 5, 30),
        type: NoteType.daily,
        tags: ['Daily', 'Chores'], // <--- Pastikan ini ada
      ),
      Note(
        id: '2',
        title: 'Daily Task',
        content: '• Study\n• Break\n• Mop the floors\n• Running a dog',
        dateModified: DateTime(2025, 4, 19),
        dateCreated: DateTime(2025, 4, 18),
        type: NoteType.daily,
        tags: ['Daily', 'Hobby'], // <--- Pastikan ini ada
      ),
      Note(
        id: '3',
        title: 'Budak Korporat??',
        content:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        dateModified: DateTime(2025, 3, 6),
        dateCreated: DateTime(2025, 3, 5),
        type: NoteType.college,
        tags: ['College'], // <--- Pastikan ini ada
      ),
      Note(
        id: '4',
        title: 'Goals',
        content:
            'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        dateModified: DateTime(2025, 3, 6),
        dateCreated: DateTime(2025, 3, 5),
        type: NoteType.life,
        tags: ['Life', 'Goals'], // <--- Pastikan ini ada
      ),
      Note(
        id: '5',
        title: 'Database System W4',
        content:
            'Normalization>on process of ordening bae,<\ndata structures to ensure that tye basic data\ncreated is 04.9C0A quabtv\nUsed to minimize data\nredundancy and data\ninconsistency.\nNormalization stage starts\nfrom the highest\nstand (INF) to the (S>XF).\nUsually\nup to the or level as they •re\nsuffic•ent to produce good\nquality tobles',
        dateModified: DateTime(2025, 4, 17),
        dateCreated: DateTime(2025, 4, 16),
        type: NoteType.college,
        tags: ['College', 'Database'], // <--- Pastikan ini ada
      ),
      Note(
        id: '6',
        title: 'My Project',
        content:
            'Meeting with KONE\nas lift vendor\nimportant to win the\ntender\ncall pak megantara\nas the PM',
        dateModified: DateTime(2025, 1, 29),
        dateCreated: DateTime(2025, 1, 28),
        type: NoteType.work,
        tags: ['Work', 'Project'], // <--- Pastikan ini ada
      ),
      Note(
        id: '7',
        title: 'Tennis',
        content: 'tenis ku suka tenis\nkami sukanya apa?\naku suka kamu aw\ntenis tenis apa yang\nlucu? tenis sama\nkamu awww',
        dateModified: DateTime(2025, 12, 5),
        dateCreated: DateTime(2025, 12, 4),
        type: NoteType.hobby,
        tags: ['Hobby', 'Sport'], // <--- Pastikan ini ada
      ),
      Note(
        id: '8',
        title: 'Reading Notes',
        content: '', // Konten kosong karena di gambar tidak ada
        dateModified: DateTime(2025, 3, 6),
        dateCreated: DateTime(2025, 3, 5),
        type: NoteType.college,
        tags: ['College', 'Reading'], // <--- Pastikan ini ada
      ),
    ];
    _sortNotes(); // Urutkan catatan awal
  }

  List<Note> get notes {
    // Filter catatan berdasarkan search term
    List<Note> filteredNotes = _allNotes.where((note) {
      final query = _searchTerm.toLowerCase();
      return query.isEmpty ||
             note.title.toLowerCase().contains(query) ||
             note.content.toLowerCase().contains(query);
    }).toList();

    // Urutkan catatan yang sudah difilter
    _sortNotes(filteredNotes);
    return filteredNotes;
  }

  String get searchTerm => _searchTerm;
  set searchTerm(String value) {
    _searchTerm = value;
    notifyListeners();
  }

  OrderOption get orderBy => _orderBy;
  set orderBy(OrderOption value) {
    _orderBy = value;
    _sortNotes();
    notifyListeners();
  }

  bool get isDescending => _isDescending;
  set isDescending(bool value) {
    _isDescending = value;
    _sortNotes();
    notifyListeners();
  }

  bool get isGrid => _isGrid;
  set isGrid(bool value) {
    _isGrid = value;
    notifyListeners();
  }

  void addNote(Note note) {
    _allNotes.add(note);
    print('Catatan baru ditambahkan. Jumlah catatan sekarang: ${_allNotes.length}');
    _sortNotes();
    notifyListeners();
  }

  // --- TAMBAHKAN METODE INI UNTUK UPDATE CATATAN ---
  void updateNote(Note updatedNote) {
    final index = _allNotes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _allNotes[index] = updatedNote;
      _sortNotes(); // Urutkan lagi setelah pembaruan
      notifyListeners();
    }
  }

  void _sortNotes([List<Note>? notesList]) {
    final listToSort = notesList ?? _allNotes;

    listToSort.sort((a, b) {
      int comparisonResult = 0;
      if (_orderBy == OrderOption.dateModified) {
        comparisonResult = a.dateModified.compareTo(b.dateModified);
      } else if (_orderBy == OrderOption.dateCreated) { // PERBAIKI TYPO INI JIKA BELUM
        comparisonResult = a.dateCreated.compareTo(b.dateCreated);
      }

      return _isDescending ? -comparisonResult : comparisonResult;
    });
  }
}