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

  // Mood
  if (mood != null) {
    tags.add('mood_${mood.toLowerCase()}'); // e.g., mood_happy
  }

  // Primary Emotion
  if (primaryEmotion != null) {
    tags.add('emotion_${primaryEmotion.toLowerCase().replaceAll(' ', '_')}'); // e.g., emotion_self_doubt
  }

  // Sleep Quality → bucketed into ranges
  if (sleepQuality != null) {
    if (sleepQuality >= 9) tags.add('sleep_9_10');
    else if (sleepQuality >= 7) tags.add('sleep_7_8');
    else if (sleepQuality >= 4) tags.add('sleep_4_6');
    else tags.add('sleep_1_3');
  }

  // Body Feeling
  if (bodyFeeling != null) {
    tags.add('body_${bodyFeeling.toLowerCase().replaceAll(' ', '_')}');
  }

  // Nutrition
  if (nutrition != null) {
    switch (nutrition) {
      case 'Yes, I ate well ✅':
        tags.add('nutrition_good');
        break;
      case 'I skipped meals ⏳':
        tags.add('nutrition_skipped');
        break;
      case 'Ate unhealthy food 🍕':
        tags.add('nutrition_unhealthy');
        break;
      case 'Didn’t eat much at all 🚫':
        tags.add('nutrition_little');
        break;
    }
  }

  // Support Needed
  if (supportNeeded != null) {
    for (var support in supportNeeded) {
      if (support.contains('Motivation')) tags.add('support_motivation');
      else if (support.contains('Relaxation')) tags.add('support_relaxation');
      else if (support.contains('Healing')) tags.add('support_emotional');
      else if (support.contains('Clarity')) tags.add('support_clarity');
      else if (support.contains('Energy')) tags.add('support_energy');
    }
  }

  // Music Intent
  if (musicIntent != null) {
    if (musicIntent.contains('Lift')) tags.add('music_lift');
    else if (musicIntent.contains('Process')) tags.add('music_process');
    else if (musicIntent.contains('Deepen')) tags.add('music_deepen');
  }

  // Daily Goal
  if (dailyGoal != null) {
    if (dailyGoal.contains('Water')) tags.add('goal_water');
    else if (dailyGoal.contains('Walk')) tags.add('goal_walk');
    else if (dailyGoal.contains('Breathing')) tags.add('goal_breathing');
    else if (dailyGoal.contains('Read')) tags.add('goal_read');
    else if (dailyGoal.contains('Connect')) tags.add('goal_connect');
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

    print("🔍 Tag '$tag' → Found ${querySnapshot.docs.length} insights");

    for (var doc in querySnapshot.docs) {
      if (!seen.contains(doc.id)) {
        finalInsights.add(Insight.fromFirestore(doc.id, doc.data()));
        seen.add(doc.id);
      }
    }
  }

  print("💾 Total insights to be stored: ${finalInsights.length}");

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

  print("✅ Stored ${finalInsights.length} insights in Firestore");
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

  print("🧠 Generated Tags for Insights: $tags");

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
