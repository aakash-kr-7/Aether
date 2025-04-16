import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/insight.dart';

class InsightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Converts check-in responses to tags
  List<String> generateTagsFromCheckin({
    required String? mood,
    required String? primaryEmotion,
    required double? sleepQuality,
    required String? bodyFeeling,
    required String? nutrition,
    required List<String>? supportNeeded,
    required String? musicIntent,
    required String? dailyGoal,
  }) {
    final List<String> tags = [];

    // Mood to tag
    if (mood != null) tags.add(mood.toLowerCase());

    // Primary emotion
    if (primaryEmotion != null) tags.add(primaryEmotion.toLowerCase());

    // Sleep Quality
    if (sleepQuality != null) {
      if (sleepQuality >= 8) tags.add('good sleep');
      else if (sleepQuality <= 4) tags.add('poor sleep');
      else tags.add('moderate sleep');
    }

    // Body
    if (bodyFeeling != null) tags.add(bodyFeeling.toLowerCase());

    // Nutrition
    if (nutrition != null) {
      switch (nutrition) {
        case 'Yes, I ate well ✅':
          tags.add('good nutrition');
          break;
        case 'I skipped meals ⏳':
          tags.add('skipped meals');
          break;
        case 'Ate unhealthy food 🍕':
          tags.add('unhealthy food');
          break;
        case 'Didn’t eat much at all 🚫':
          tags.add('low appetite');
          break;
      }
    }

    // Support Needed
    if (supportNeeded != null) {
      for (var item in supportNeeded) {
        if (item.contains('Motivation')) tags.add('motivation');
        else if (item.contains('Relaxation')) tags.add('relaxation');
        else if (item.contains('Healing')) tags.add('emotional healing');
        else if (item.contains('Clarity')) tags.add('mental clarity');
        else if (item.contains('Energy')) tags.add('energy');
      }
    }

    // Music Intent
    if (musicIntent != null) {
      if (musicIntent.contains('Lift')) tags.add('uplifting music');
      else if (musicIntent.contains('Process')) tags.add('processing emotion');
      else if (musicIntent.contains('Deepen')) tags.add('deepen emotion');
    }

    // Daily Goal
    if (dailyGoal != null) {
      switch (dailyGoal) {
        case 'Drink More Water 💧':
          tags.add('hydration');
          break;
        case 'Take a Walk 🚶‍♂️':
          tags.add('physical activity');
          break;
        case 'Deep Breathing Exercise 🌬️':
          tags.add('breathing exercise');
          break;
        case 'Read Something Inspiring 📖':
          tags.add('inspiration');
          break;
        case 'Connect with Someone ☎️':
          tags.add('connection');
          break;
      }
    }

    return tags;
  }

  /// Generate insights from generated tags
  Future<void> generateInsightsAfterCheckin(String uid, List<String> tags) async {
    final Set<String> seen = {};
    final List<Insight> finalInsights = [];

    for (String tag in tags) {
      final querySnapshot = await _firestore
          .collection('insights_repository')
          .where('tags', arrayContains: tag)
          .limit(5)
          .get();

      for (var doc in querySnapshot.docs) {
        if (!seen.contains(doc.id)) {
          finalInsights.add(Insight.fromFirestore(doc.id, doc.data()));
          seen.add(doc.id);
        }
      }
    }

    // Store in insights_generated subcollection
    for (var insight in finalInsights) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('insights_generated')
          .add({
        ...insight.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Final function to call after check-in is completed
  Future<void> handleCheckinAndGenerateInsights({
    required String uid,
    required String? mood,
    required String? primaryEmotion,
    required double? sleepQuality,
    required String? bodyFeeling,
    required String? nutrition,
    required List<String>? supportNeeded,
    required String? musicIntent,
    required String? dailyGoal,
  }) async {
    final tags = generateTagsFromCheckin(
      mood: mood,
      primaryEmotion: primaryEmotion,
      sleepQuality: sleepQuality,
      bodyFeeling: bodyFeeling,
      nutrition: nutrition,
      supportNeeded: supportNeeded,
      musicIntent: musicIntent,
      dailyGoal: dailyGoal,
    );

    await generateInsightsAfterCheckin(uid, tags);
  }

  /// Like an insight
  Future<void> likeInsight(String uid, Insight insight) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('liked_insights')
        .add({
      ...insight.toMap(),
      'liked_at': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch liked insights
  Future<List<Insight>> fetchLikedInsights(String uid) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('liked_insights')
        .orderBy('liked_at', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Insight.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Fetch recent insights
  Future<List<Insight>> fetchGeneratedInsights(String uid) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('insights_generated')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs
        .map((doc) => Insight.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
