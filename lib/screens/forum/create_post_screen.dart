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
  final TextEditingController _controller = TextEditingController();
  final ForumService _forumService = ForumService();
  final _uuid = Uuid();

  void _submitPost() async {
    String text = _controller.text;
    if (text.isNotEmpty) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "default_user";
      String username = FirebaseAuth.instance.currentUser?.email ?? "Anonymous";
      String postId = _uuid.v4();

      ForumPost newPost = ForumPost(
        postId: postId,
        userId: userId,
        username: username,
        title: text,
        content: "This is a placeholder content for now.",
        timestamp: DateTime.now(),
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
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: "Write your post title..."),
          maxLines: 1,
        ),
      ),
    );
  }
}
