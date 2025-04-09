import 'package:flutter/material.dart';
import '../../models/emotion_log.dart';
import '../../services/emotion_service.dart';

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

  final _supportOptions = ['Motivation & Inspiration 🔥', 'Relaxation & Stress Relief 😌', 'Emotional Processing & Healing 💙', 'Mental Clarity & Focus 🧠', 'Energy Boost & Activity ⚡'];

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
      appBar: AppBar(title: const Text('Daily Check-In')),
      body: SingleChildScrollView(
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
                onPressed: submitLog,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keep your exact question builders here 👇

  Widget buildMoodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How are you feeling overall?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: ['Happy', 'Calm', 'Sad', 'Neutral', 'Angry', 'Anxious', 'Empty']
              .map((m) => ChoiceChip(
                    label: Text(m),
                    selected: mood == m,
                    onSelected: (selected) {
                      setState(() => mood = selected ? m : null);
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildPrimaryEmotionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Primary emotion you’re experiencing?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: ['Excitement', 'Joy', 'Love', 'Confidence', 'Nostalgie', 'Overwhelm', 'Self-Doubt', 'Resentment']
              .map((emotion) => ChoiceChip(
                    label: Text(emotion),
                    selected: primaryEmotion == emotion,
                    onSelected: (selected) {
                      setState(() => primaryEmotion = selected ? emotion : null);
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildSleepQualityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How would you rate your sleep quality?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Slider(
          value: sleepQuality,
          min: 1,
          max: 10,
          divisions: 9,
          label: sleepQuality.round().toString(),
          onChanged: (value) {
            setState(() => sleepQuality = value);
          },
        ),
      ],
    );
  }

  Widget buildBodyFeelingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How is your body feeling?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: ['Energetic', 'Fatigued', 'Sore', 'Relaxed', 'Unwell', 'Just okay']
              .map((feeling) => ChoiceChip(
                    label: Text(feeling),
                    selected: bodyFeeling == feeling,
                    onSelected: (selected) {
                      setState(() => bodyFeeling = selected ? feeling : null);
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildNutritionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Did you eat well yesterday?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: ['Yes, I ate well ✅', 'I skipped meals ⏳', 'Ate unhealthy food 🍕', 'Didn’t eat much at all 🚫']
              .map((option) => ChoiceChip(
                    label: Text(option),
                    selected: nutrition == option,
                    onSelected: (selected) {
                      setState(() => nutrition = selected ? option : null);
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildSupportNeededStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What kind of support do you need?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: _supportOptions.map((option) {
            final isSelected = supportNeeded.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
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
    );
  }

  Widget buildMusicIntentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What do you want from your music today?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: ['Lift My Spirits 🎵', 'Help Me Process 🎶', 'Deepen My Mood 🎼']
              .map((intent) => ChoiceChip(
                    label: Text(intent),
                    selected: musicIntent == intent,
                    onSelected: (selected) {
                      setState(() => musicIntent = selected ? intent : null);
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildDailyGoalStep() {
  final options = [
    'Drink More Water 💧',
    'Take a Walk 🚶‍♂️',
    'Deep Breathing Exercise 🌬️',
    'Read Something Inspiring 📖',
    'Connect with Someone ☎️',
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'What\'s one small goal for today?',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: options.map((option) {
          final isSelected = dailyGoal == option;
          return ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                dailyGoal = selected ? option : null;
              });
            },
          );
        }).toList(),
      ),
    ],
  );
}
}
