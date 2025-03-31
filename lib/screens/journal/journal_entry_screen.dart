import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final List<Map<String, String>> moods = [
    {'mood': 'Happy', 'emoji': '😊'},
    {'mood': 'Sad', 'emoji': '😢'},
    {'mood': 'Angry', 'emoji': '😡'},
    {'mood': 'Excited', 'emoji': '🤩'},
    {'mood': 'Anxious', 'emoji': '😰'},
    {'mood': 'Grateful', 'emoji': '🙏'},
    {'mood': 'Calm', 'emoji': '😌'},
    {'mood': 'Tired', 'emoji': '😴'},
    {'mood': 'Stressed', 'emoji': '😖'},
    {'mood': 'Neutral', 'emoji': '😐'},
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
        notes: _notes,
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
    Color textColor = Colors.black; // Default text color
    Color bgColor = Colors.brown; // Default background color

    // Check if background is green, set text to white
    if (bgColor == Colors.green) {
      textColor = Colors.white;
    }

    return Scaffold(
      body: Hero(
        tag: 'journal-entry',
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/entryj.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: Colors.brown.withOpacity(0.8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.entry == null ? "A New Memory" : "Edit Memory",
                        style: GoogleFonts.dancingScript(
                          fontSize: 26, color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: textColor),
                        onPressed: _saveEntry,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: "Entry Title",
                            hintStyle: TextStyle(color: textColor),
                          ),
                          style: TextStyle(color: textColor),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            hintText: "Write your thoughts...",
                            hintStyle: TextStyle(color: textColor),
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(color: textColor),
                        ),
                        SizedBox(height: 16.0),
                        Container(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: moods.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedMood = moods[index]['mood']!;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 6),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedMood == moods[index]['mood']
                                        ? Colors.brown
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(moods[index]['emoji']!, style: TextStyle(fontSize: 20)),
                                      SizedBox(width: 6),
                                      Text(
                                        moods[index]['mood']!,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: "Add a note",
                            hintStyle: TextStyle(color: textColor),
                            suffixIcon: IconButton(icon: Icon(Icons.add), onPressed: _addNote),
                          ),
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
