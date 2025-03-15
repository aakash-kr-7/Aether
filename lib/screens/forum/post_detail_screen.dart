import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String title;

  PostDetailScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("This is a placeholder for post details."),
      ),
    );
  }
}
