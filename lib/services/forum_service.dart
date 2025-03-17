import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_post.dart';

class ForumService {
  final CollectionReference forumCollection = 
      FirebaseFirestore.instance.collection('forumPosts');

  // Create a new forum post
  Future<void> createPost(ForumPost post) async {
    try {
      await forumCollection.doc(post.postId).set(post.toMap());
    } catch (e) {
      print("Error creating post: $e");
    }
  }

  // Get all forum posts (real-time updates)
  Stream<List<ForumPost>> getPosts() {
    return forumCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ForumPost.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Delete a forum post
  Future<void> deletePost(String postId) async {
    try {
      await forumCollection.doc(postId).delete();
    } catch (e) {
      print("Error deleting post: $e");
    }
  }
}
