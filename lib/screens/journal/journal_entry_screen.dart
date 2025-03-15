import 'package:flutter/material.dart';

class JournalEntryScreen extends StatefulWidget {
  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final TextEditingController _controller = TextEditingController();

  void _saveEntry() {
    String text = _controller.text;
    if (text.isNotEmpty) {
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
