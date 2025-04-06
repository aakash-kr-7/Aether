class EmotionLog {
  final String mood;
  final String primaryEmotion;
  final int sleepQuality;
  final String bodyFeeling;
  final String nutrition;
  final List<String> supportNeeded;
  final String musicIntent;
  final String dailyGoal;
  final DateTime date;

  EmotionLog({
    required this.mood,
    required this.primaryEmotion,
    required this.sleepQuality,
    required this.bodyFeeling,
    required this.nutrition,
    required this.supportNeeded,
    required this.musicIntent,
    required this.dailyGoal,
    required this.date,
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
      'date': date,
    };
  }

  factory EmotionLog.fromMap(Map<String, dynamic> map) {
    return EmotionLog(
      mood: map['mood'] ?? '',
      primaryEmotion: map['primaryEmotion'] ?? '',
      sleepQuality: map['sleepQuality'] ?? 0,
      bodyFeeling: map['bodyFeeling'] ?? '',
      nutrition: map['nutrition'] ?? '',
      supportNeeded: List<String>.from(map['supportNeeded'] ?? []),
      musicIntent: map['musicIntent'] ?? '',
      dailyGoal: map['dailyGoal'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }
}
