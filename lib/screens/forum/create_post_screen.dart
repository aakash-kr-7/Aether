import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/forum_service.dart';
import '../../models/forum_post.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ForumService _forumService = ForumService();
  final _uuid = Uuid();

  void _submitPost() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "default_user";
      String username = FirebaseAuth.instance.currentUser?.email ?? "Anonymous";
      String postId = _uuid.v4();

      ForumPost newPost = ForumPost(
        postId: postId,
        userId: userId,
        username: username,
        title: title,
        content: content,
        timestamp: DateTime.now(),
        likes: [],
        commentCount: 0,
      );

      await _forumService.createPost(newPost);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Post Created!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(icon: Icon(Icons.check, color: Colors.white), onPressed: _submitPost)
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: "Enter post title..."),
              maxLines: 1,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(hintText: "Enter post content..."),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}