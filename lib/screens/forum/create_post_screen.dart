import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.blue[800]?.withOpacity(0.7),
        title: Text("Create Post", style: GoogleFonts.poppins(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: _submitPost,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 3, 93, 105),
                  Color.fromARGB(255, 5, 68, 97),
                  Color.fromARGB(255, 5, 28, 61),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "What's on your mind?" text
                  Text(
                    "What's on your mind?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Title field
                  _buildTextField(
                    controller: _titleController,
                    hint: "Enter post title...",
                    maxLines: 1,
                  ),
                  SizedBox(height: 20),

                  // Content field
                  _buildTextField(
                    controller: _contentController,
                    hint: "Enter post content...",
                    maxLines: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
