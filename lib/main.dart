import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/onboardingscreen.dart'; // Import Onboarding
import 'screens/journal/journal_home.dart';
import 'screens/forum/forum_home.dart';
import 'screens/chatbot/chatbot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Clear Firestore cache
  await FirebaseFirestore.instance.clearPersistence();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aether',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/home': (context) => HomeScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/journal': (context) => JournalHome(),
        '/forum': (context) => ForumHome(),
        '/chatbot': (context) => ChatbotScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  Future<bool> _checkOnboardingCompletion(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get(const GetOptions(source: Source.server)); // Force fresh data

      if (!userDoc.exists) return false; // If document doesn't exist, user is new

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      return userData?['onboardingComplete'] == true;
    } catch (e) {
      print("Error checking onboarding status: $e");
      return false; // Default to onboarding if error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          String userId = snapshot.data!.uid;
          return FutureBuilder<bool>(
            future: _checkOnboardingCompletion(userId),
            builder: (context, onboardingSnapshot) {
              if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (onboardingSnapshot.data == false) {
                return OnboardingScreen();
              }
              return HomeScreen();
            },
          );
        }
        return LoginScreen();
      },
    );
  }
}

