import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/forum_post.dart';
import '../../services/forum_service.dart';
import 'post_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class UserPostsScreen extends StatelessWidget {
  final ForumService _forumService = ForumService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "default_user";

  void _showDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop();
              await _forumService.deletePost(postId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Posts", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<List<ForumPost>>(
        stream: _forumService.getUserPosts(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "You haven't posted anything yet.",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }

          List<ForumPost> userPosts = snapshot.data!;
          return ListView.builder(
            itemCount: userPosts.length,
            itemBuilder: (context, index) {
              ForumPost post = userPosts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(postData: {
                        'postId': post.postId,
                        'title': post.title,
                        'content': post.content,
                        'userId': post.userId,
                        'username': post.username,
                        'timestamp': post.timestamp,
                        'likeCount': post.likes.length,
                        'commentCount': post.commentCount,
                      }),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(12),
                  color: Color.fromARGB(255, 26, 36, 53),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                post.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, post.postId),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          post.content,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.red, size: 20),
                            SizedBox(width: 4),
                            Text("${post.likes.length}", style: GoogleFonts.poppins(color: Colors.white)),
                            SizedBox(width: 16),
                            Icon(Icons.comment, color: Colors.blue, size: 20),
                            SizedBox(width: 4),
                            Text("${post.commentCount}", style: GoogleFonts.poppins(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: Color.fromARGB(255, 3, 16, 34),
    );
  }
}
