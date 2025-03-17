import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String entryId;
  final String userId;
  final String content;
  final DateTime date;

  JournalEntry({
    required this.entryId,
    required this.userId,
    required this.content,
    required this.date,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      entryId: map['entryId'],
      userId: map['userId'],
      content: map['content'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'userId': userId,
      'content': content,
      'date': date,
    };
  }
}
