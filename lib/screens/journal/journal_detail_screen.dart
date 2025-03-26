import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: Text(entry.title.isNotEmpty ? entry.title : "Untitled", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deleteEntry(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mood: ${entry.mood}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Date: ${_formatDate(entry.date)}", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            SizedBox(height: 20),
            Text(entry.content, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            if (entry.notes.isNotEmpty) ...[
              Text("Notes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entry.notes
                    .map((note) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("• $note", style: TextStyle(fontSize: 16)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
