import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/journal_service.dart';
import '../../models/journal_entry.dart';
import 'journal_entry_screen.dart';
import 'journal_detail_screen.dart';

class JournalHome extends StatefulWidget {
  @override
  _JournalHomeState createState() => _JournalHomeState();
}

class _JournalHomeState extends State<JournalHome> {
  final JournalService _journalService = JournalService();

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd – HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Your Journal", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue[800],
        ),
        body: Center(child: Text("Please log in to view entries.")),
      );
    }

    String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Journal", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<List<JournalEntry>>(
        stream: _journalService.getUserEntries(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");
            return Center(child: Text("Error loading entries."));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No entries yet!",
                style: TextStyle(fontSize: 18, color: Colors.blue[700]),
              ),
            );
          }

          final entries = snapshot.data!;
          print("Fetched Entries: ${entries.map((e) => e.toMap()).toList()}");

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];

              return ListTile(
                title: Text(entry.title.isNotEmpty ? entry.title : "Untitled"),
                subtitle: Text("Mood: ${entry.mood}\n${formatDate(entry.date)}"),
                leading: Icon(Icons.book, color: Colors.blue[700]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JournalDetailScreen(entry: entry),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JournalEntryScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}