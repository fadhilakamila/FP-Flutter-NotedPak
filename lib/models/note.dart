import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String? id;
  final String title;
  final String content;
  final DateTime dateModified;
  final DateTime dateCreated;
  final List<String> tags;
  final String? userId; 
  Note({
    this.id,
    required this.title,
    required this.content,
    required this.dateModified,
    required this.dateCreated,
    required this.tags,
    this.userId,
  });

  factory Note.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      dateModified: (data['dateModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateCreated: (data['dateCreated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
      userId: data['userId'], 
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'dateModified': Timestamp.fromDate(dateModified),
      'dateCreated': Timestamp.fromDate(dateCreated),
      'tags': tags,
      'userId': userId, 
    };
  }
}