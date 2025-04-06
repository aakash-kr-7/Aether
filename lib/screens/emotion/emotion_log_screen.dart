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
  late final List<Widget Function()> steps;
  
  String? mood;
  String? primaryEmotion;
  double sleepQuality = 5;
  String? bodyFeeling;
  String? nutrition;
  List<String> supportNeeded = [];
  String? musicIntent;
  String? dailyGoal;

  int currentStep = 0;

  void nextStep() {
    if (currentStep < 7) {
      setState(() {
        currentStep++;
      });
    } else {
      submitLog();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> submitLog() async {
  final log = EmotionLog(
    mood: mood ?? '',
    primaryEmotion: primaryEmotion ?? '',
    sleepQuality: sleepQuality.toInt(),
    bodyFeeling: bodyFeeling ?? '',
    nutrition: nutrition ?? '',
    supportNeeded: supportNeeded,
    musicIntent: musicIntent ?? '',
    dailyGoal: dailyGoal ?? '',
    date: DateTime.now(),
  );

  try {
    await _emotionService.addEmotionLog(widget.userId, log);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in submitted successfully!')),
    );

    // ✅ Send result back to home screen
    Navigator.pop(context, 'completed');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit check-in: $e')),
    );
  }
}


    Widget buildStep() {
    switch (currentStep) {
      case 0:
        return buildMoodStep();
      case 1:
        return buildPrimaryEmotionStep();
      case 2:
        return buildSleepQualityStep();
      case 3:
        return buildBodyFeelingStep();
      case 4:
        return buildNutritionStep();
      case 5:
        return buildSupportNeededStep();
      case 6:
        return buildMusicIntentStep();
      case 7:
        return buildDailyGoalStep();
      default:
        return buildMoodStep();
    }
  }

  Widget buildMoodStep() {
    final moods = ['Happy & Energized 😃', 'Calm & Peaceful 😊', 'Neutral / Meh 😐', 'Sad & Down 😞', 'Frustrated or Angry 😡', 'Anxious or Stressed 😰', 'Lonely or Empty 😔'];
    return buildOptions('How are you feeling right now?', moods, (value) => setState(() => mood = value));
  }

  Widget buildPrimaryEmotionStep() {
    final emotions = ['Excitement 🎉', 'Gratitude 🙏', 'Love & Connection ❤️', 'Confidence 🔥', 'Nostalgia 📖', 'Overwhelm 😵', 'Self-Doubt 🤯', 'Regret 😔', 'Loneliness 🖤', 'Anger/Resentment 😤'];
    return buildOptions('What is the strongest emotion underneath your mood today?', emotions, (value) => setState(() => primaryEmotion = value));
  }

  Widget buildSleepQualityStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('How did you sleep last night?', style: TextStyle(fontSize: 18)),
        Slider(
  value: sleepQuality,
  min: 0,
  max: 10,
  divisions: 10,
  label: sleepQuality.round().toString(),
  onChanged: (value) {
    setState(() {
      sleepQuality = value;
    });
  },
  onChangeEnd: (value) {
    nextStep();
  },
),
      ],
    );
  }

  Widget buildBodyFeelingStep() {
    final options = ['Energized & Strong 💪', 'Okay, Just Normal 🤷‍♂️', 'Fatigued & Drained 😴', 'Aching or Sore 🤕', 'Headache / Unwell 🤧'];
    return buildOptions('How is your body feeling today?', options, (value) => setState(() => bodyFeeling = value));
  }

  Widget buildNutritionStep() {
    final options = ['Yes, I ate well ✅', 'I skipped meals ⏳', 'Ate unhealthy food 🍕', 'Didn’t eat much at all 🚫'];
    return buildOptions('Did you eat well yesterday?', options, (value) => setState(() => nutrition = value));
  }

  Widget buildSupportNeededStep() {
    final options = ['Motivation & Inspiration 🔥', 'Relaxation & Stress Relief 😌', 'Emotional Processing & Healing 💙', 'Mental Clarity & Focus 🧠', 'Energy Boost & Activity ⚡'];
    return buildMultiSelectOptions('What kind of support would be most helpful today?', options, supportNeeded);
  }

  Widget buildMusicIntentStep() {
    final options = ['Lift My Spirits 🎵', 'Help Me Process 🎶', 'Deepen My Mood 🎼'];
    return buildOptions('What do you want from your music today?', options, (value) => setState(() => musicIntent = value));
  }

  Widget buildDailyGoalStep() {
    final options = ['Drink More Water 💧', 'Take a Walk 🚶‍♂️', 'Deep Breathing Exercise 🌬️', 'Read Something Inspiring 📖', 'Connect with Someone ☎️'];
    return buildOptions('What’s one small goal for today?', options, (value) => setState(() => dailyGoal = value));
  }

  Widget buildOptions(String question, List<String> options, Function(String) onSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ...options.map((option) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ElevatedButton(
            onPressed: () {
              onSelected(option);
              nextStep();
            },
            child: Text(option, textAlign: TextAlign.center),
          ),
        )),
      ],
    );
  }

  Widget buildMultiSelectOptions(String question, List<String> options, List<String> selectedOptions) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ...options.map((option) {
          final isSelected = selectedOptions.contains(option);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : null,
              ),
              onPressed: () {
                setState(() {
                  if (isSelected) {
                    selectedOptions.remove(option);
                  } else {
                    selectedOptions.add(option);
                  }
                });
              },
              child: Text(option, textAlign: TextAlign.center),
            ),
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: selectedOptions.isNotEmpty ? nextStep : null,
          child: const Text('Next'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Daily Check-in'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: Center(child: buildStep()),
  );
}
}
