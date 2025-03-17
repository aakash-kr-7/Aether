import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/journal_service.dart';
import '../../models/journal_entry.dart';

class JournalEntryScreen extends StatefulWidget {
  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  final JournalService _journalService = JournalService();
  final _uuid = Uuid();

  void _saveEntry() async {
    String text = _controller.text;
    if (text.isNotEmpty) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "default_user";
      String entryId = _uuid.v4();
      JournalEntry newEntry = JournalEntry(
        entryId: entryId,
        userId: userId,
        content: text,
        date: DateTime.now(),
      );

      await _journalService.addEntry(newEntry);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Entry Saved!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Journal Entry", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(icon: Icon(Icons.check, color: Colors.white), onPressed: _saveEntry)
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: "Write your thoughts..."),
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
  }
}
