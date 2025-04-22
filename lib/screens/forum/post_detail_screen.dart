import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/comment_model.dart'; // import your CommentModel
import '../../services/forum_service.dart'; // import your forum service

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> postData;

  const PostDetailScreen({Key? key, required this.postData}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    await ForumService().addComment(
      postId: widget.postData['postId'],
      userId: user.uid,
      username: 'Anonymous',
      content: _commentController.text.trim(),
    );

    // Update the comment count in the UI
    setState(() {
      widget.postData['commentCount']++;
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
  final post = widget.postData;

  return Scaffold(
    appBar: AppBar(
      title: Text("Post Details"),
    ),
    body: Column(
      children: [
        // 🔹 Post Content
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post['title'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(post['content'], style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red, size: 18),
                  SizedBox(width: 4),
                  Text('${post['likeCount']}'),
                  SizedBox(width: 12),
                  Icon(Icons.comment, color: Colors.grey, size: 18),
                  SizedBox(width: 4),
                  Text('${post['commentCount']}'),
                ],
              ),
            ],
          ),
        ),

        Divider(),

        // 🔹 Comments List
        Expanded(
          child: StreamBuilder<List<CommentModel>>(
            stream: ForumService().getCommentsForPost(post['postId']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final comments = snapshot.data ?? [];

              if (comments.isEmpty) {
                return Center(child: Text("No comments yet."));
              }

              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final isAuthor = comment.userId == widget.postData['userId'];

                  return ListTile(
                    title: Row(
                      children: [
                        Text(
                          comment.username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (isAuthor)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Author",
                                style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(comment.content),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          TimeOfDay.fromDateTime(comment.timestamp).format(context),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (comment.userId == FirebaseAuth.instance.currentUser?.uid)
                          IconButton(
                            icon: Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Delete Comment"),
                                  content: Text("Are you sure you want to delete this comment?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await ForumService().deleteComment(
                                          postId: widget.postData['postId'],
                                          commentId: comment.commentId,
                                        );

                                        setState(() {
                                          widget.postData['commentCount']--;
                                        });
                                      },
                                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // 🔹 Add Comment Box
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Write a comment...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: Colors.blue),
                onPressed: _addComment,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}