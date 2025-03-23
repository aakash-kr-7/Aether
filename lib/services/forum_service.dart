import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_post.dart';

class ForumService {
  final CollectionReference forumCollection =
      FirebaseFirestore.instance.collection('forumPosts');

  Future<void> createPost(ForumPost post) async {
    try {
      await forumCollection.doc(post.postId).set(post.toMap());
    } catch (e) {
      print("Error creating post: $e");
    }
  }

  Stream<List<ForumPost>> getPosts() {
    return forumCollection
        .orderBy('timestamp', descending: true) // Sort by newest
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ForumPost.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      DocumentReference postRef = forumCollection.doc(postId);
      DocumentSnapshot postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        List<String> likes = List<String>.from(postSnapshot['likes'] ?? []);
        if (likes.contains(userId)) {
          likes.remove(userId); // Unlike
        } else {
          likes.add(userId); // Like
        }
        await postRef.update({
          'likes': likes,
          'likeCount': likes.length, // Update likeCount
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  Future<void> updateCommentCount(String postId, int newCount) async {
    try {
      await forumCollection.doc(postId).update({'commentCount': newCount});
    } catch (e) {
      print("Error updating comment count: $e");
    }
  }
}