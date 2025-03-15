import 'package:flutter/material.dart';
import 'journal_entry_screen.dart';

class JournalHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Journal", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: Text(
          "No entries yet!",
          style: TextStyle(fontSize: 18, color: Colors.blue[700]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => JournalEntryScreen()));
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
