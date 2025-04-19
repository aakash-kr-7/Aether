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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Entry deleted.")),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => JournalHome()),
      (route) => false,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  final List<Color> stickyNoteColors = [
    Color(0xFFB3E5FC), // Light Blue 100
    Color(0xFF81D4FA), // Light Blue 200
    Color(0xFF4FC3F7), // Light Blue 300
    Color(0xFF29B6F6), // Light Blue 400
    Color(0xFFE1F5FE), // Light Blue 50 (very pale)
    Color(0xFFB2EBF2), // Cyan 100
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 41, 182, 175),
              Color(0xFF0ED2F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          entry.title.isNotEmpty ? entry.title : "Untitled",
                          style: GoogleFonts.patrickHand(
                            fontSize: 28,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _deleteEntry(context),
                      ),
                    ],
                  ),
                ),

                // Big Paper Container
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    width: MediaQuery.of(context).size.width * 0.92,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 194, 255, 254),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: CustomPaint(
                      painter: LinedPaperPainter(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Mood: ${entry.mood}",
                                  style: GoogleFonts.patrickHand(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  _formatDate(entry.date),
                                  style: GoogleFonts.patrickHand(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              entry.content,
                              style: GoogleFonts.shadowsIntoLight(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 20),
                            if (entry.notes.isNotEmpty) ...[
                              Text(
                                "Notes:",
                                style: GoogleFonts.patrickHand(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: entry.notes.asMap().entries.map((e) {
                                  int index = e.key;
                                  String note = e.value;
                                  return Container(
                                    width: 120,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: stickyNoteColors[index % stickyNoteColors.length],
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      note,
                                      style: GoogleFonts.patrickHand(
                                        fontSize: 16,
                                        color: Colors.brown[800],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
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

// Lined Paper Painter
class LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double y = 20; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
