import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/journal_service.dart';
import '../../models/journal_entry.dart';
import 'journal_home.dart';

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry? entry;

  JournalEntryScreen({this.entry});

  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final JournalService _journalService = JournalService();
  final _uuid = Uuid();

  List<String> _notes = [];
  String _selectedMood = 'Neutral';

  final List<String> moods = [
    'Happy', 'Sad', 'Angry', 'Excited', 'Anxious',
    'Grateful', 'Calm', 'Tired', 'Stressed', 'Neutral'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _notes = List.from(widget.entry!.notes);
      _selectedMood = widget.entry!.mood;
    }
  }

  void _saveEntry() async {
  String title = _titleController.text.trim();
  String content = _contentController.text.trim();

  // Ensure any unsaved note is added
  if (_noteController.text.isNotEmpty) {
    _notes.add(_noteController.text.trim());
    _noteController.clear();
  }

  if (title.isNotEmpty && content.isNotEmpty) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "default_user";
    String entryId = widget.entry?.entryId ?? _uuid.v4();
    DateTime entryDate = widget.entry?.date ?? DateTime.now();

    JournalEntry newEntry = JournalEntry(
      entryId: entryId,
      userId: userId,
      title: title,
      content: content,
      notes: _notes.isNotEmpty ? _notes : [],
      mood: _selectedMood,
      date: entryDate,
    );

    if (widget.entry == null) {
      await _journalService.addEntry(newEntry);
    } else {
      await _journalService.updateEntry(entryId, newEntry.toMap());
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Entry Saved!")));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => JournalHome()),
      (route) => false,
    );
  }
}

void _addNote() {
  if (_noteController.text.isNotEmpty) {
    setState(() {
      _notes.add(_noteController.text.trim());
      _noteController.clear();
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? "New Journal Entry" : "Edit Journal Entry",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(icon: Icon(Icons.check, color: Colors.white), onPressed: _saveEntry)
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: "Entry Title"),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(hintText: "Write your thoughts..."),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: _selectedMood,
              onChanged: (value) => setState(() => _selectedMood = value!),
              items: moods.map((mood) => DropdownMenuItem(
                value: mood,
                child: Text(mood),
              )).toList(),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Add a note",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addNote,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Wrap(
              children: _notes
                  .map((note) => Chip(
                        label: Text(note),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() => _notes.remove(note));
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
