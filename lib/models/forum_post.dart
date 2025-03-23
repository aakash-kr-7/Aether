import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String postId;
  final String userId;
  final String username;
  final String title;
  final String content;
  final DateTime timestamp;
  final List<String> likes; // Track likes by userId
  final int commentCount;

  ForumPost({
    required this.postId,
    required this.userId,
    required this.username,
    required this.title,
    required this.content,
    required this.timestamp,
    this.likes = const [],
    this.commentCount = 0,
  });

  factory ForumPost.fromMap(Map<String, dynamic> map) {
    return ForumPost(
      postId: map['postId'],
      userId: map['userId'],
      username: map['username'],
      title: map['title'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'likes': likes,
      'commentCount': commentCount,
    };
  }
}
