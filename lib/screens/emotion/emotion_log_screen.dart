import 'package:flutter/material.dart';
import '../../models/emotion_log.dart';
import '../../services/emotion_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class EmotionLogScreen extends StatefulWidget {
  final String userId;
  const EmotionLogScreen({super.key, required this.userId});

  @override
  State<EmotionLogScreen> createState() => _EmotionLogScreenState();
}

class _EmotionLogScreenState extends State<EmotionLogScreen> {
  final EmotionService _emotionService = EmotionService();

  String? mood;
  String? primaryEmotion;
  double sleepQuality = 5;
  String? bodyFeeling;
  String? nutrition;
  List<String> supportNeeded = [];
  String? musicIntent;
  String? dailyGoal;

    final _supportOptions = [
    'Motivation & Inspiration 🔥',
    'Relaxation & Stress Relief 😌',
    'Emotional Processing & Healing 💙',
    'Mental Clarity & Focus 🧠',
    'Energy Boost & Activity ⚡',
  ];

  String getMoodLabel(double value) {
  if (value <= 1) return '🫠 Meh...';
  if (value <= 3) return '😕 Not the best';
  if (value <= 5) return '😶‍🌫 Okay-ish';
  if (value <= 7) return '🌤 Getting there';
  if (value <= 9) return '😊 Pretty Good!';
  return '🌈 Cloud 9!';
}


  Future<void> submitLog() async {
    final log = EmotionLog(
      mood: mood,
      primaryEmotion: primaryEmotion,
      sleepQuality: sleepQuality.toDouble(),
      bodyFeeling: bodyFeeling,
      nutrition: nutrition,
      supportNeeded: supportNeeded,
      musicIntent: musicIntent,
      dailyGoal: dailyGoal,
      date: DateTime.now(),
    );

    try {
      await _emotionService.addEmotionLog(widget.userId, log);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in submitted successfully!')),
      );

      Navigator.pop(context, 'completed');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit check-in: $e')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Hey, how are you?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/em.png', // make sure this path is correct
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3), // optional dark overlay
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildMoodStep(),
              const SizedBox(height: 16),
              buildPrimaryEmotionStep(),
              const SizedBox(height: 16),
              buildSleepQualityStep(),
              const SizedBox(height: 16),
              buildBodyFeelingStep(),
              const SizedBox(height: 16),
              buildNutritionStep(),
              const SizedBox(height: 16),
              buildSupportNeededStep(),
              const SizedBox(height: 16),
              buildMusicIntentStep(),
              const SizedBox(height: 16),
              buildDailyGoalStep(),
              const SizedBox(height: 32),
              SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 72, 143, 208), // soft pastel blue
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 6,
      shadowColor: Colors.blueAccent.withOpacity(0.3),
      padding: EdgeInsets.symmetric(vertical: 14),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    onPressed: submitLog,
    child: const Text('Save Entry ✨'),
  ),
),
            ],
          ),
        ),
      ],
    ),
  );
}

  // Keep your exact question builders here 👇
Widget buildMoodStep() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Card(
        color: const Color.fromARGB(255, 196, 236, 244).withOpacity(0.3), // more transparent to let blur show
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_emotions, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text(
                'How are you feeling overall?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Happy😁', 'Calm😌', 'Sad😞', 'Neutral😑', 'Angry😠', 'Anxious😥', 'Empty☹']
                .map((m) => ChoiceChip(
                      label: Text(m),
                      selected: mood == m,
                      selectedColor: Colors.orangeAccent.withOpacity(0.8),
                      onSelected: (selected) {
                        setState(() => mood = selected ? m : null);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    ),
  )));
}


  Widget buildPrimaryEmotionStep() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Card(
        color: const Color.fromARGB(255, 196, 236, 244).withOpacity(0.3), // more transparent to let blur show
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.favorite, color: Colors.pinkAccent),
              SizedBox(width: 8),
              Text(
                'Primary emotion you’re experiencing?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              'Excitement🤩',
              'Joy😄',
              'Love🥰',
              'Confidence😎',
              'Nostalgia🥹',
              'Overwhelm🤯',
              'Self-Doubt😣',
              'Resentment😒'
            ]
                .map((emotion) => ChoiceChip(
                      label: Text(emotion),
                      selected: primaryEmotion == emotion,
                      selectedColor: Colors.pinkAccent.withOpacity(0.8),
                      onSelected: (selected) {
                        setState(() => primaryEmotion = selected ? emotion : null);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    ),
  )));
}


 Widget buildSleepQualityStep() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Card(
        color: const Color.fromARGB(255, 196, 236, 244).withOpacity(0.3), // more transparent to let blur show
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.nights_stay, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text(
                'How would you rate your sleep quality?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        Slider(
  value: sleepQuality,
  min: 0,
  max: 10,
  divisions: 5,
  label: getMoodLabel(sleepQuality),
  onChanged: (value) {
    setState(() {
      sleepQuality = value;
    });
  },
),


        ],
      ),
    ),
    )));
}


  Widget buildBodyFeelingStep() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Card(
        color: const Color.fromARGB(255, 196, 236, 244).withOpacity(0.3), // more transparent to let blur show
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.self_improvement, color: Colors.lightBlueAccent),
              SizedBox(width: 8),
              Text(
                'How is your body feeling?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Energetic💃', 'Fatigued😪', 'Sore🤕', 'Relaxed😊', 'Unwell🤧', 'Just okay👍']
                .map((feeling) => ChoiceChip(
                      label: Text(feeling),
                      selected: bodyFeeling == feeling,
                      selectedColor: Colors.lightBlueAccent.withOpacity(0.8),
                      onSelected: (selected) {
                        setState(() => bodyFeeling = selected ? feeling : null);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    ),
  )));
}


  Widget buildNutritionStep() {
 return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Card(
        color: const Color.fromARGB(255, 196, 236, 244).withOpacity(0.3), // more transparent to let blur show
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.restaurant, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Did you eat well yesterday?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              'Yes, I ate well ✅',
              'I skipped meals ⏳',
              'Ate unhealthy food 🍕',
              'Didn’t eat much at all 🚫',
            ].map((option) {
              return ChoiceChip(
                label: Text(option),
                selected: nutrition == option,
                selectedColor: Colors.green.withOpacity(0.7),
                onSelected: (selected) {
                  setState(() => nutrition = selected ? option : null);
                },
              );
            }).toList(),
          ),
        ],
      ),
    ),
  )));
}


  Widget buildSupportNeededStep() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Card(
        color: const Color.fromARGB(255, 196, 236, 244).withOpacity(0.3), // more transparent to let blur show
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.self_improvement, color: Colors.lightBlue),
              SizedBox(width: 8),
              Text(
                'What kind of support do you need?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _supportOptions.map((option) {
              final isSelected = supportNeeded.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                selectedColor: Colors.lightBlueAccent.withOpacity(0.7),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      supportNeeded.add(option);
                    } else {
                      supportNeeded.remove(option);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    ),
  )));
}

 Widget buildMusicIntentStep() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Card(
        color: const Color.fromARGB(255, 196, 236, 244).withOpacity(0.3), // more transparent to let blur show
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.music_note, color: Colors.deepPurple),
              SizedBox(width: 8),
              Expanded(
              child: Text(
                'What do you want from your music today?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Align(
  alignment: Alignment.centerLeft,
  child: Wrap(
    spacing: 8,
    children: ['Lift My Spirits 🎵', 'Help Me Process 🎶', 'Deepen My Mood 🎼']
        .map((intent) => ChoiceChip(
              label: Text(intent),
              selected: musicIntent == intent,
              selectedColor: const Color.fromARGB(255, 132, 70, 248),
              onSelected: (selected) {
                setState(() => musicIntent = selected ? intent : null);
              },
            ))
        .toList(),
  ),
),
        ],
      ),
    ),
  )));
}


  Widget buildDailyGoalStep() {
  final options = [
    'Drink More Water 💧',
    'Take a Walk 🚶‍♂',
    'Deep Breathing Exercise 🌬',
    'Read Something Inspiring 📖',
    'Connect with Someone ☎',
  ];

  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Card(
        color: const Color.fromARGB(255, 196, 236, 244).withOpacity(0.3), // more transparent to let blur show
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_events, color: Color.fromARGB(255, 54, 248, 119)),
              SizedBox(width: 8),
              Text(
                'What\'s one small goal for today?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: options.map((option) {
              final isSelected = dailyGoal == option;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                selectedColor: const Color.fromARGB(255, 42, 101, 0),
                onSelected: (selected) {
                  setState(() {
                    dailyGoal = selected ? option : null;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    ),
  )));
}
}