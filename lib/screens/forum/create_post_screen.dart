import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submitPost() {
    String text = _controller.text;
    if (text.isNotEmpty) {
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
          decoration: InputDecoration(hintText: "Write your post..."),
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
  }
}
