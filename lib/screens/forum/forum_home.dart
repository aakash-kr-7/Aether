import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/forum_post.dart';
import '../../services/forum_service.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ForumHome extends StatefulWidget {
  @override
  _ForumHomeState createState() => _ForumHomeState();
}

class _ForumHomeState extends State<ForumHome> {
  final ForumService _forumService = ForumService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forum", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<List<ForumPost>>(
        stream: _forumService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No posts yet!", style: TextStyle(fontSize: 18, color: Colors.blue[700])));
          }

          List<ForumPost> posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(posts[index].title),
                subtitle: Text(posts[index].username),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: posts[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen()));
          setState(() {}); // 🔹 Refresh the forum list after returning
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
