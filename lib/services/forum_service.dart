import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_post.dart';
import '../models/comment_model.dart';

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

  Future<void> addComment({
  required String postId,
  required String userId,
  required String username,
  required String content,
}) async {
  final commentRef = FirebaseFirestore.instance
      .collection('forumPosts')
      .doc(postId)
      .collection('comments')
      .doc();

  final comment = CommentModel(
    commentId: commentRef.id,
    userId: userId,
    username: username,
    content: content,
    timestamp: DateTime.now(),
  );

  await commentRef.set(comment.toMap());

  // Increment the commentCount in the parent post
  await FirebaseFirestore.instance
      .collection('forumPosts')
      .doc(postId)
      .update({'commentCount': FieldValue.increment(1)});
}

Stream<List<CommentModel>> getCommentsForPost(String postId) {
  return FirebaseFirestore.instance
      .collection('forumPosts')
      .doc(postId)
      .collection('comments')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
          .toList());
}

Future<void> deleteComment({
  required String postId,
  required String commentId,
}) async {
  final commentRef = FirebaseFirestore.instance
      .collection('forumPosts')
      .doc(postId)
      .collection('comments')
      .doc(commentId);

  await commentRef.delete();

  // Decrement commentCount safely
  final postRef = FirebaseFirestore.instance.collection('forumPosts').doc(postId);
  await postRef.update({
    'commentCount': FieldValue.increment(-1),
  });
}

Future<void> deletePost(String postId) async {
  try {
    // Delete all comments under the post
    final commentsSnapshot = await forumCollection
        .doc(postId)
        .collection('comments')
        .get();

    for (var doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the post itself
    await forumCollection.doc(postId).delete();
  } catch (e) {
    print("Error deleting post: $e");
  }
}

Stream<List<ForumPost>> getUserPosts(String userId) {
  return forumCollection
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ForumPost.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
}
}