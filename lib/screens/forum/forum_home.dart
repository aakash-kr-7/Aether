import 'package:flutter/material.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ForumHome extends StatelessWidget {
  final List<String> posts = ["First Post!", "Second Post!"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forum", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(posts[index]),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(title: posts[index])));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen()));
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
