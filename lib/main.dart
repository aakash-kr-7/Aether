import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/journal/journal_home.dart';
import 'screens/forum/forum_home.dart';

void main() {
  runApp(AetherApp());
}

class AetherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeSelectionScreen(),
    );
  }
}

class HomeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aether Home"), backgroundColor: Colors.blue[800]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            }, child: Text("Go to Login")),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => JournalHome()));
            }, child: Text("Go to Journal")),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ForumHome()));
            }, child: Text("Go to Forum")),
          ],
        ),
      ),
    );
  }
}
