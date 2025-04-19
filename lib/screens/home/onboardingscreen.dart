import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aether/models/onboarding_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:google_fonts/google_fonts.dart';


class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  int currentQuestionIndex = 0;
  double mentalWellBeingValue = 5;
  OnboardingModel onboardingData = OnboardingModel(
    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    reasonsForJoining: [],
    mentalWellBeing: '',
    frequentEmotions: [],
    mentalHealthManagement: [],
    dailyTimeCommitment: '',
    reminderPreference: '',
    activityPreference: '',
    primaryFocusArea: '',
    vulnerableTimes: [],
    preferredWellnessActivities: [],
  );

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What brings you to Aether?',
      'options': [
        'Improve my mental well-being',
        'Reduce stress and anxiety',
        'Develop mindfulness habits',
        'Track my emotions and moods',
        'Improve sleep quality',
        'Increase focus and productivity',
        'Improve emotional awareness',
        'Other wellness goals',
      ],
      'multiple': true,
      'key': 'reasonsForJoining',
    },
    {
      'question': 'On a scale of 1–10, how would you rate your current mental well-being?',
      'type': 'slider',
      'key': 'mentalWellBeing',
    },
    {
      'question': 'Which emotions do you experience most often?',
      'options': [
        'Stressed',
        'Anxious',
        'Happy',
        'Overwhelmed',
        'Calm',
        'Sad',
        'Motivated',
        'Numb/disconnected',
        'Energetic',
        'Lonely',
      ],
      'multiple': true,
      'key': 'frequentEmotions',
    },
    {
      'question': 'How do you currently manage your mental health?',
      'options': [
        'Meditation or mindfulness exercises',
        'Journaling',
        'Therapy or counseling',
        'Talking to friends/family',
        'Physical activity (exercise, yoga, etc.)',
        'Listening to music',
        'Engaging in creative activities (drawing, writing, etc.)',
        'I don’t actively manage it yet',
      ],
      'multiple': true,
      'key': 'mentalHealthManagement',
    },
    {
      'question': 'How much time can you dedicate to Aether daily?',
      'options': [
        'Less than 5 minutes',
        '5–10 minutes',
        '10–20 minutes',
        '20+ minutes',
      ],
      'multiple': false,
      'key': 'dailyTimeCommitment',
    },
    {
      'question': 'Would you like to receive gentle reminders for mindfulness or self-care check-ins?',
      'options': [
        'Yes, daily',
        'Yes, a few times a week',
        'No, I’ll check in on my own',
      ],
      'multiple': false,
      'key': 'reminderPreference',
    },
    {
      'question': 'Do you prefer guided exercises or self-directed activities?',
      'options': [
        'Guided exercises (e.g., meditation, breathing techniques)',
        'Self-directed activities (e.g., journaling, reflection prompts)',
        'A mix of both',
      ],
      'multiple': false,
      'key': 'activityPreference',
    },
    {
      'question': 'What is your primary focus area in Aether?',
      'options': [
        'Stress management',
        'Emotional awareness',
        'Mindfulness & meditation',
        'Sleep improvement',
        'Self-reflection & personal growth',
      ],
      'multiple': false,
      'key': 'primaryFocusArea',
    },
    {
      'question': 'Are there any particular times of day when you feel most emotionally vulnerable?',
      'options': [
        'Morning',
        'Afternoon',
        'Evening',
        'Late night',
        'No specific time',
      ],
      'multiple': true,
      'key': 'vulnerableTimes',
    },
    {
      'question': 'What wellness activities do you want Aether to include for you?',
      'options': [
        'Breathing exercises',
        'Guided meditation',
        'Mood journaling',
        'Personalized affirmations',
        'Daily wellness tips',
        'Sleep relaxation techniques',
        'Productivity and focus exercises',
      ],
      'multiple': true,
      'key': 'preferredWellnessActivities',
    },
  ];

  void handleSelection(dynamic value) {
    String key = questions[currentQuestionIndex]['key'];

    setState(() {
      if (questions[currentQuestionIndex]['multiple'] == true) {
        List<String> list = List<String>.from(onboardingData.toMap()[key]);
        if (list.contains(value)) {
          list.remove(value);
        } else {
          list.add(value);
        }
        onboardingData = OnboardingModel.fromMap(
          {
            ...onboardingData.toMap(),
            key: list,
          },
          onboardingData.userId,
        );
      } else {
        onboardingData = OnboardingModel.fromMap(
          {
            ...onboardingData.toMap(),
            key: value,
          },
          onboardingData.userId,
        );
      }
    });
  }

  void nextQuestion() async {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      await onboardingData.saveToFirestore();
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'onboardingComplete': true});
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> checkOnboardingStatus() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (userDoc.exists && userDoc['onboardingComplete'] == true) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      checkOnboardingStatus();
    }
  }

@override
Widget build(BuildContext context) {
  Map<String, dynamic> currentQuestion = questions[currentQuestionIndex];

  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(
      children: [
        AnimateGradient(
          primaryColors: [
            Color.fromARGB(255, 116, 227, 235),
            Color.fromARGB(255, 133, 169, 223),
          ],
          secondaryColors: [
            Color.fromARGB(255, 0, 191, 201),
            Color.fromARGB(255, 146, 254, 213),
          ],
          duration: Duration(seconds: 5),
          child: Container(),
        ),
        SafeArea(
          child: Column(
            children: [
              // Top bar with back and logout buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: previousQuestion,
                    ),
                    IconButton(
                      icon: Icon(Icons.exit_to_app, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ),

              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Left-aligns the question
                    children: [
                      SizedBox(height: 20),
                      Text(
                        currentQuestion['question'],
                        textAlign: TextAlign.left,
                        style: GoogleFonts.merriweather(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 30),

                      if (currentQuestion.containsKey('type') &&
                          currentQuestion['type'] == 'slider')
                        Column(
                          children: [
                            Slider(
                              value: mentalWellBeingValue,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: mentalWellBeingValue.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  mentalWellBeingValue = value;
                                  onboardingData = OnboardingModel.fromMap(
                                    {
                                      ...onboardingData.toMap(),
                                      'mentalWellBeing':
                                          mentalWellBeingValue.round().toString(),
                                    },
                                    onboardingData.userId,
                                  );
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Struggling", style: TextStyle(color: Colors.red)),
                                Text("Thriving", style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ],
                        )
                      else
                        Column(
                          children: currentQuestion['options'].map<Widget>((option) {
                            bool isSelected = onboardingData
                                .toMap()[currentQuestion['key']]
                                .contains(option);
                            return GestureDetector(
                              onTap: () => handleSelection(option),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? null : Colors.grey[200],
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 46, 71, 199),
                                            Color.fromARGB(255, 69, 128, 216),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    option,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      SizedBox(height: 30),

                      Center(
                        child: FloatingActionButton(
                          onPressed: nextQuestion,
                          child: Text(
                            currentQuestionIndex == questions.length - 1
                                ? "Finish"
                                : "Next",
                          ),
                        ),
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Adjusted progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    color: const Color.fromARGB(255, 68, 118, 255),
                    minHeight: 8, // Slightly thicker for visibility
                  ),
                ),
              ),
              SizedBox(height: 10), // Not at the bottom edge
            ],
          ),
        ),
      ],
    ),
  );
}
}