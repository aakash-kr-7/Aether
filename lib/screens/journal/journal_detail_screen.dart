import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/journal_entry.dart';
import '../../services/journal_service.dart';
import 'journal_home.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;
  final JournalService _journalService = JournalService();

  JournalDetailScreen({required this.entry});

  void _deleteEntry(BuildContext context) async {
    await _journalService.deleteEntry(entry.entryId!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Entry deleted.")));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => JournalHome()),
      (route) => false,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/journal.png"),
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
                color: const Color.fromARGB(255, 44, 93, 40).withOpacity(0.8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.title.isNotEmpty ? entry.title : "Untitled",
                      style: GoogleFonts.dancingScript(
                        fontSize: 26, 
                        color: Colors.white,  // White text on green background
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () => _deleteEntry(context),
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
                      Text(
                        "Mood: ${entry.mood}",
                        style: GoogleFonts.dancingScript(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold,
                          color: Colors.black // Black text
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Date: ${_formatDate(entry.date)}",
                        style: GoogleFonts.dancingScript(
                          fontSize: 18, 
                          color: Colors.grey[700]  // Grey text for date
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20),
                      Text(
                        entry.content,
                        style: GoogleFonts.dancingScript(
                          fontSize: 20, 
                          fontWeight: FontWeight.w500, 
                          color: Colors.black // Black text
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20),
                      if (entry.notes.isNotEmpty) ...[
                        Text(
                          "Notes:",
                          style: GoogleFonts.dancingScript(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold,
                            color: Colors.black // Black text
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: entry.notes
                              .map((note) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      "• $note",
                                      style: GoogleFonts.dancingScript(
                                        fontSize: 20, 
                                        color: Colors.black // Black text
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
