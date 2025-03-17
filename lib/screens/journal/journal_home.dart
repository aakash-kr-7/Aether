import 'package:flutter/material.dart';
import '../../services/journal_service.dart';
import '../../models/journal_entry.dart';
import 'journal_entry_screen.dart';

class JournalHome extends StatefulWidget {
  @override
  _JournalHomeState createState() => _JournalHomeState();
}

class _JournalHomeState extends State<JournalHome> {
  final JournalService _journalService = JournalService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Journal", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<List<JournalEntry>>(
        stream: _journalService.getUserEntries("USER_ID_HERE"), // Replace with actual user ID
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No entries yet!", style: TextStyle(fontSize: 18, color: Colors.blue[700])));
          }

          List<JournalEntry> entries = snapshot.data!;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(entries[index].content),
                subtitle: Text(entries[index].date.toString()),
                leading: Icon(Icons.book, color: Colors.blue[700]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => JournalEntryScreen()));
          setState(() {}); // 🔹 Refresh the journal list after returning
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
