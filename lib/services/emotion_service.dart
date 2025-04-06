import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emotion_log.dart';

class EmotionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEmotionLog(String userId, EmotionLog log) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkins') // Changed from daily_checkins
          .add(log.toMap()); // Changed from .doc(...).set(...)
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EmotionLog>> getEmotionLogs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkins')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EmotionLog.fromMap(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
