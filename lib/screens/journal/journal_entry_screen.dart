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

  final List<Color> stickyNoteColors = [
    Color(0xFFFFF9C4),
    Color(0xFFB2EBF2),
    Color(0xFFC8E6C9),
    Color(0xFFFFCCBC),
    Color(0xFFD1C4E9),
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
    return Scaffold(
      body: Hero(
        tag: 'journal-entry',
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 41, 182, 175),
                Color(0xFF0ED2F7),
              ],
            ),
          ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.entry == null ? "A New Memory" : "Edit Memory",
                      style: GoogleFonts.sacramento(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.white, size: 28),
                      onPressed: _saveEntry,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCard(TextField(
                        controller: _titleController,
                        style: GoogleFonts.patrickHand(fontSize: 22, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Entry Title",
                          hintStyle: GoogleFonts.patrickHand(color: Colors.black54, fontSize: 20),
                          border: InputBorder.none,
                        ),
                      )),
                      SizedBox(height: 12),
                      _buildCard(
                        Container(
                          height: 350,
                        child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: GoogleFonts.patrickHand(fontSize: 20, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Write your thoughts...",
                          hintStyle: GoogleFonts.patrickHand(color: Colors.black54, fontSize: 20),
                          border: InputBorder.none,
                        ),
                      ))),
                      SizedBox(height: 16),
                      Text("How do you feel?", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
                      SizedBox(height: 8),
                      Container(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: moods.length,
                          itemBuilder: (context, index) {
                            final mood = moods[index];
                            final isSelected = _selectedMood == mood['mood'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMood = mood['mood']!;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blueAccent : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text(mood['emoji']!, style: TextStyle(fontSize: 18)),
                                    SizedBox(width: 6),
                                    Text(
                                      mood['mood']!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildCard(
                        TextField(
                          controller: _noteController,
                          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Add a note",
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: _addNote,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _notes.asMap().entries.map((entry) {
                          int index = entry.key;
                          String note = entry.value;
                          return Container(
                            width: 130,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: stickyNoteColors[index % stickyNoteColors.length],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note,
                                  style: GoogleFonts.patrickHand(
                                      fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _notes.remove(note)),
                                    child: Icon(Icons.close, size: 16, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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

Widget _buildCard(Widget child) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(2, 2),
        ),
      ],
    ),
    child: child,
  );
}
}