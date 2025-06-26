import 'dart:async'; // WAJIB: Diperlukan untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';
import '../enums/order_option.dart';

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = 'notes';

  List<Note> _allNotes = [];
  StreamSubscription<QuerySnapshot>? _notesSubscription; // Listener untuk Firestore

  String _searchTerm = '';
  OrderOption _orderBy = OrderOption.dateModified;
  bool _isDescending = true;
  bool _isGrid = true;

  NotesProvider() {
    // Memantau perubahan status login user
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        // Jika user login, mulai mendengarkan perubahan di database
        _listenToNotes(user.uid);
      } else {
        // Jika user logout, hentikan listener dan bersihkan data
        _cancelSubscription();
        _allNotes = [];
        notifyListeners();
      }
    });
  }

  // --- GETTER UNTUK UI ---
  bool get isGrid => _isGrid;
  OrderOption get orderBy => _orderBy;
  bool get isDescending => _isDescending;

  List<Note> get notes {
    List<Note> filteredNotes = _allNotes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(_searchTerm.toLowerCase());
      final contentMatch = note.content.toLowerCase().contains(_searchTerm.toLowerCase());
      final tagMatch = note.tags.any((tag) => tag.toLowerCase().contains(_searchTerm.toLowerCase()));
      return titleMatch || contentMatch || tagMatch;
    }).toList();
    
    // Pengurutan dilakukan di sini agar selalu ter-update saat UI me-render
    _sortList(filteredNotes);
    return filteredNotes;
  }

  // --- LISTENER REAL-TIME ---
  void _listenToNotes(String userId) {
    // Batalkan listener lama jika ada untuk mencegah kebocoran memori
    _notesSubscription?.cancel();

    // Buat query ke Firestore
    final query = _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId);

    // Mulai mendengarkan stream dari query
    _notesSubscription = query.snapshots().listen(
      (snapshot) {
        print(">>> REAL-TIME UPDATE: Menerima ${snapshot.docs.length} dokumen dari Firestore.");
        // Ubah data dari snapshot menjadi list of Note object
        _allNotes = snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
        // Beri tahu UI untuk di-render ulang dengan data baru
        notifyListeners();
      },
      onError: (error) {
        // Tangani jika ada error saat mendengarkan
        print("!!! ERROR saat mendengarkan notes: $error");
      },
    );
  }
  
  // --- FUNGSI CREATE, UPDATE, DELETE YANG LEBIH SEDERHANA ---
  // Kita tidak perlu mengubah state lokal (_allNotes) di sini.
  // Listener _listenToNotes akan menanganinya secara otomatis.

  Future<void> addNote(Note note) async {
    // Cukup tambahkan data ke Firestore. UI akan update otomatis.
    try {
      await _firestore.collection(_collectionName).add(note.toFirestore());
    } catch (e) {
      print("Error adding note: $e");
    }
  }

  Future<void> updateNote(Note note) async {
    // Cukup update data di Firestore. UI akan update otomatis.
    if (note.id == null) return;
    try {
      await _firestore.collection(_collectionName).doc(note.id).update(note.toFirestore());
    } catch (e) {
      print("Error updating note: $e");
    }
  }

  Future<void> deleteNote(String id) async {
    // Cukup hapus data dari Firestore. UI akan update otomatis.
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      print("Error deleting note: $e");
    }
  }
  
  // --- FUNGSI HELPER LAINNYA ---
  
  void _sortList(List<Note> listToSort) {
    listToSort.sort((a, b) {
      int comparison;
      switch (_orderBy) {
        case OrderOption.title:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case OrderOption.dateCreated:
          comparison = a.dateCreated.compareTo(b.dateCreated);
          break;
        case OrderOption.dateModified:
        default:
          comparison = a.dateModified.compareTo(b.dateModified);
          break;
      }
      return _isDescending ? -comparison : comparison;
    });
  }

  void updateSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void updateOrder(OrderOption option) {
    if (_orderBy == option) {
      _isDescending = !_isDescending;
    } else {
      _orderBy = option;
      _isDescending = true;
    }
    notifyListeners();
  }

  void toggleView() {
    _isGrid = !_isGrid;
    notifyListeners();
  }
  
  // Method untuk membersihkan listener saat tidak dibutuhkan lagi
  void _cancelSubscription() {
    _notesSubscription?.cancel();
    _notesSubscription = null;
  }

  @override
  void dispose() {
    // Pastikan untuk membatalkan listener saat provider tidak digunakan lagi
    _cancelSubscription();
    super.dispose();
  }
}