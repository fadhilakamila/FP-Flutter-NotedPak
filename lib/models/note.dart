// lib/models/note.dart
import 'package:flutter/material.dart';

enum NoteType { daily, college, work, hobby, life } // Menambahkan enum NoteType

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime dateModified;
  final DateTime dateCreated;
  final NoteType type; // Menambahkan field type

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.dateModified,
    required this.dateCreated,
    required this.type,
  });
}