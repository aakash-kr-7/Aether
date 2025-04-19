import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/forum_post.dart';
import '../../services/forum_service.dart';
import 'create_post_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumHome extends StatefulWidget {
  @override
  _ForumHomeState createState() => _ForumHomeState();
}

class _ForumHomeState extends State<ForumHome> {
  final ForumService _forumService = ForumService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "default_user";

  void _toggleLike(String postId) {
    _forumService.toggleLike(postId, userId);
  }

  @override
  Widget build(BuildContext context) {
    String? username = FirebaseAuth.instance.currentUser?.email ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome, $username",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: StreamBuilder<List<ForumPost>>(
              stream: _forumService.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No posts yet. Be the first to post!",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  );
                }

                List<ForumPost> posts = snapshot.data!;

                posts.sort((a, b) => (b.likes.length + b.commentCount).compareTo(a.likes.length + a.commentCount));

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    ForumPost post = posts[index];
                    bool isLiked = post.likes.contains(userId);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: Color.fromARGB(255, 26, 36, 53), // Dark color for card background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              post.content,
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () => _toggleLike(post.postId),
                                ),
                                Text(
                                  "${post.likes.length} likes",
                                  style: GoogleFonts.poppins(color: Colors.white),
                                ),
                                SizedBox(width: 16),
                                Icon(
                                  Icons.comment,
                                  color: Colors.blue[700],
                                ),
                                Text(
                                  "${post.commentCount} comments",
                                  style: GoogleFonts.poppins(color: Colors.white),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "Posted by Anonymous",
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
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
