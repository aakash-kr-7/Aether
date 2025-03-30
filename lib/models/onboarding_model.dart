import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingModel {
  String userId;
  List<String> reasonsForJoining;
  String mentalWellBeing;
  List<String> frequentEmotions;
  List<String> mentalHealthManagement;
  String dailyTimeCommitment;
  String reminderPreference;
  String activityPreference;
  String primaryFocusArea;
  List<String> vulnerableTimes;
  List<String> preferredWellnessActivities;

  OnboardingModel({
    required this.userId,
    required this.reasonsForJoining,
    required this.mentalWellBeing,
    required this.frequentEmotions,
    required this.mentalHealthManagement,
    required this.dailyTimeCommitment,
    required this.reminderPreference,
    required this.activityPreference,
    required this.primaryFocusArea,
    required this.vulnerableTimes,
    required this.preferredWellnessActivities,
  });

  Map<String, dynamic> toMap() {
    return {
      'reasonsForJoining': reasonsForJoining,
      'mentalWellBeing': mentalWellBeing,
      'frequentEmotions': frequentEmotions,
      'mentalHealthManagement': mentalHealthManagement,
      'dailyTimeCommitment': dailyTimeCommitment,
      'reminderPreference': reminderPreference,
      'activityPreference': activityPreference,
      'primaryFocusArea': primaryFocusArea,
      'vulnerableTimes': vulnerableTimes,
      'preferredWellnessActivities': preferredWellnessActivities,
    };
  }

  factory OnboardingModel.fromMap(Map<String, dynamic> map, String userId) {
    return OnboardingModel(
      userId: userId,
      reasonsForJoining: List<String>.from(map['reasonsForJoining'] ?? []),
      mentalWellBeing: map['mentalWellBeing'] ?? '',  // ✅ Fixed: Ensures a String, not an int (0)
      frequentEmotions: List<String>.from(map['frequentEmotions'] ?? []),
      mentalHealthManagement: List<String>.from(map['mentalHealthManagement'] ?? []),
      dailyTimeCommitment: map['dailyTimeCommitment'] ?? '',
      reminderPreference: map['reminderPreference'] ?? '',
      activityPreference: map['activityPreference'] ?? '',
      primaryFocusArea: map['primaryFocusArea'] ?? '',
      vulnerableTimes: List<String>.from(map['vulnerableTimes'] ?? []),
      preferredWellnessActivities: List<String>.from(map['preferredWellnessActivities'] ?? []),
    );
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set(
      toMap(),
      SetOptions(merge: true),
    );
  }
}
