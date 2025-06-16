import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';
import '../enums/order_option.dart';

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'notes';

  List<Note> _allNotes = [];
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _notesStream;
  String _searchTerm = '';
  OrderOption _orderBy = OrderOption.dateModified;
  bool _isDescending = true;
  bool _isGrid = true;

  NotesProvider() {
    _notesStream = _firestore.collection(_collectionName).snapshots();
    _notesStream.listen((snapshot) {
      _allNotes = snapshot.docs.map((doc) {
        try {
          return Note.fromFirestore(doc);
        } catch (e) {
          return Note(
            id: doc.id,
            title: 'Error Parsing Note',
            content: 'Failed to load content for this note due to a data error.',
            dateModified: DateTime.now(),
            dateCreated: DateTime.now(),
            tags: ['parsing-error'],
          );
        }
      }).toList();
      _sortNotes();
      notifyListeners();
    });
  }

  // Metode untuk mengambil semua catatan dari Firestore
  Future<void> fetchNotes() async {
    try {
      print('>>> fetchNotes: Starting to fetch documents from collection "$_collectionName"...');
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection(_collectionName).get();
      print('<<< fetchNotes: Successfully fetched ${snapshot.docs.length} documents.');

      _allNotes = snapshot.docs.map((doc) {
        try {
          final note = Note.fromFirestore(doc);
          print('      - Parsed document ID: ${doc.id} -> Title: ${note.title}');
          return note;
        } catch (e) {
          print('!!! fetchNotes: Error parsing document with ID: ${doc.id}. Error: $e');
          // Jika ada error parsing, buat catatan dummy agar tidak crash seluruh aplikasi.
          // Ini membantu melacak dokumen mana yang bermasalah.
          return Note(
            id: doc.id,
            title: 'Error Parsing Note',
            content: 'Failed to load content for this note due to a data error.',
            dateModified: DateTime.now(),
            dateCreated: DateTime.now(),
            // Menghapus type: NoteType.daily,
            tags: ['parsing-error'],
          );
        }
      }).toList();

      print('>>> fetchNotes: All documents processed. Total notes in _allNotes: ${_allNotes.length}');
      _sortNotes();
      notifyListeners();
      print('<<< fetchNotes: notifyListeners() called. UI should update.');
    } catch (e) {
      print('!!! fetchNotes: Main error during fetching process: $e');
      // Tampilkan SnackBar atau pesan error di UI jika Anda mau
    }
  }

  List<Note> get notes {
    List<Note> filteredNotes = _allNotes.where((note) {
      final query = _searchTerm.toLowerCase();
      return query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();

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

  Future<void> addNote(Note note) async {
    try {
    DocumentReference docRef = await _firestore.collection(_collectionName).add(note.toFirestore());
    note.id = docRef.id;

    _allNotes.add(note);
    _sortNotes();
    notifyListeners();
    print('>>> addNote: Note added to Firestore and local list. ID: ${note.id}');
    } catch (e) {
      print('!!! addNote: Error adding note: $e');
    }
  }

  Future<void> updateNote(Note updatedNote) async {
    try {
      if (updatedNote.id == null || updatedNote.id!.isEmpty) {
        print("!!! updateNote: Error: Cannot update note without an ID.");
        return;
      }
      await _firestore.collection(_collectionName).doc(updatedNote.id).update(updatedNote.toFirestore());
      
      
      int index = _allNotes.indexWhere((n) => n.id == updatedNote.id);
      if (index != -1) {
        _allNotes[index] = updatedNote;
        _sortNotes();
        notifyListeners();
        print('>>> updateNote: Note updated in Firestore and local list. ID: ${updatedNote.id}');
      }
    } catch (e) {
      print('!!! updateNote: Error updating note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
    await _firestore.collection(_collectionName).doc(noteId).delete();
    _allNotes.removeWhere((note) => note.id == noteId);
    _sortNotes();
    notifyListeners();
    print('>>> deleteNote: Note deleted from Firestore and local list. ID: $noteId');
    } catch (e) {
      print('!!! deleteNote: Error deleting note: $e');
    }
  }

  void _sortNotes([List<Note>? notesList]) {
    final listToSort = notesList ?? _allNotes;

    listToSort.sort((a, b) {
      int comparisonResult = 0;
      if (_orderBy == OrderOption.dateModified) {
        comparisonResult = a.dateModified.compareTo(b.dateModified);
      } else if (_orderBy == OrderOption.dateCreated) {
        comparisonResult = a.dateCreated.compareTo(b.dateCreated);
      } else {
        comparisonResult = a.title.compareTo(b.title);
      }

      return _isDescending ? -comparisonResult : comparisonResult;
    });
  }
}