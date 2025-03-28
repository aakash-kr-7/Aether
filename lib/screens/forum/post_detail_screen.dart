import 'package:flutter/material.dart';
import '../../models/forum_post.dart';

class PostDetailScreen extends StatelessWidget {
  final ForumPost post;

  PostDetailScreen({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.content,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              "Posted by: ${post.username}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text("${post.likes.length} likes"),
                SizedBox(width: 16),
                Icon(Icons.comment, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text("${post.commentCount} comments"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}