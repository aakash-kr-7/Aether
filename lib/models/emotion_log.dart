import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionLog {
  final String? mood;
  final String? primaryEmotion;
  final double? sleepQuality;
  final String? bodyFeeling;
  final String? nutrition;
  final List<String>? supportNeeded;
  final String? musicIntent;
  final String? dailyGoal;
  final DateTime? date;

  EmotionLog({
    this.mood,
    this.primaryEmotion,
    this.sleepQuality,
    this.bodyFeeling,
    this.nutrition,
    this.supportNeeded,
    this.musicIntent,
    this.dailyGoal,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'primaryEmotion': primaryEmotion,
      'sleepQuality': sleepQuality,
      'bodyFeeling': bodyFeeling,
      'nutrition': nutrition,
      'supportNeeded': supportNeeded,
      'musicIntent': musicIntent,
      'dailyGoal': dailyGoal,
      'date': Timestamp.fromDate(DateTime.now()),
    };
  }

  factory EmotionLog.fromMap(Map<String, dynamic> map) {
    return EmotionLog(
      mood: map['mood'],
      primaryEmotion: map['primaryEmotion'],
      sleepQuality: map['sleepQuality'],
      bodyFeeling: map['bodyFeeling'],
      nutrition: map['nutrition'],
      supportNeeded: map['supportNeeded'] != null
          ? List<String>.from(map['supportNeeded'])
          : null,
      musicIntent: map['musicIntent'],
      dailyGoal: map['dailyGoal'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
    );
  }
}
