import 'package:cloud_firestore/cloud_firestore.dart';

class Insight {
  final String id;
  final String text;
  final List<String> tags;
  final String type;
  final String source;
  final DateTime? timestamp;

  Insight({
    required this.id,
    required this.text,
    required this.tags,
    required this.type,
    required this.source,
    this.timestamp,
  });

  factory Insight.fromFirestore(String id, Map<String, dynamic> data) {
    return Insight(
      id: id,
      text: data['text'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      type: data['type'] ?? '',
      source: data['source'] ?? '',
      timestamp: (data['timestamp'] != null)
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'tags': tags,
      'type': type,
      'source': source,
      'timestamp': timestamp ?? DateTime.now(),
    };
  }
}
