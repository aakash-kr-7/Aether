import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/forum_post.dart';
import '../../services/forum_service.dart';
import 'create_post_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_detail_screen.dart';
import 'user_posts_screen.dart';

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

  void _navigateToPostDetail(ForumPost post) async {
  // Wait for detail screen to pop, then refresh UI
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostDetailScreen(
        postData: {  // Pass the entire postData
          'postId': post.postId,
          'title': post.title,  
          'content': post.content,
          'userId': post.userId,
          'username': post.username,
          'timestamp': post.timestamp,
          'likeCount': post.likes.length,
          'commentCount': post.commentCount,
        },
      ),
    ),
  );
  setState(() {}); // Refresh to get latest comments count
}

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "See what people have been saying.",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
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
                    posts.sort((a, b) => (b.likes.length + b.commentCount)
                        .compareTo(a.likes.length + a.commentCount));

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        ForumPost post = posts[index];
                        bool isLiked = post.likes.contains(userId);

                        return GestureDetector(
                          onTap: () => _navigateToPostDetail(post),
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            color: Color.fromARGB(255, 26, 36, 53),
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
                                          isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              isLiked ? Colors.red : Colors.grey,
                                        ),
                                        onPressed: () =>
                                            _toggleLike(post.postId),
                                      ),
                                      Text(
                                        "${post.likes.length} likes",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white),
                                      ),
                                      SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () => _navigateToPostDetail(post),
                                        child: Row(
                                          children: [
                                            Icon(Icons.comment,
                                                color: Colors.blue[700]),
                                            SizedBox(width: 4),
                                            Text(
                                              "${post.commentCount} comments",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "Posted by Anonymous",
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: Colors.grey),
                                    ),
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
              ),
            ],
          ),
        ),
      ),
    ),
    floatingActionButton: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "userPosts",
          backgroundColor: Colors.blueGrey[700],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserPostsScreen()),
            );
          },
          child: Icon(Icons.person, color: Colors.white),
          mini: true,
        ),
        SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "createPost",
          backgroundColor: Colors.blue[700],
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreatePostScreen()));
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ],
    ),
  );
}
}