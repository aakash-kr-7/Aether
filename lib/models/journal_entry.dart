import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String entryId;
  final String userId;
  final String title;
  final String content;
  final List<String> notes;
  final String mood;
  final DateTime date;

  JournalEntry({
    required this.entryId,
    required this.userId,
    required this.title,
    required this.content,
    required this.notes,
    required this.mood,
    required this.date,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      entryId: map['entryId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Untitled',
      content: map['content'] ?? 'No content',
      notes: map['notes'] is List ? List<String>.from(map['notes']) : <String>[],
      mood: map['mood'] ?? 'Neutral',
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'userId': userId,
      'title': title,
      'content': content,
      'notes': notes,
      'mood': mood,
      'date': Timestamp.fromDate(date),
    };
  }
}
