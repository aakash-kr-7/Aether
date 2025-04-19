import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/journal_service.dart';
import '../../models/journal_entry.dart';
import 'journal_entry_screen.dart';
import 'journal_detail_screen.dart';

class JournalHome extends StatefulWidget {
  @override
  _JournalHomeState createState() => _JournalHomeState();
}
class _JournalHomeState extends State<JournalHome> with SingleTickerProviderStateMixin {
  final JournalService _journalService = JournalService();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd – HH:mm').format(date);
  }

  String getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😔';
      case 'excited':
        return '🤩';
      case 'angry':
        return '😠';
      case 'anxious':
        return '😰';
      case 'grateful':
        return '🙏';
      case 'calm':
        return '😌';
      case 'tired':
        return '😪';
      case 'stressed':
        return '😧';
      case 'neutral':
        return '😐';
      default:
        return '📖';
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/jh.png',
                fit: BoxFit.cover,
              ),
            ),
            Center(child: Text("Please log in to view entries.", style: TextStyle(fontSize: 18, color: Colors.black))),
          ],
        ),
      );
    }

    String userId = user.uid;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Memory Log",
                  style: GoogleFonts.sacramento(fontSize: 60, color: Colors.white),
                ),
              ),
            ),
            Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: DefaultTextStyle(
          style: GoogleFonts.sacramento(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Every moment matters...',
                speed: Duration(milliseconds: 150),
              ),
            ],
            totalRepeatCount: 1,
            pause: const Duration(milliseconds: 1000),
          ),
        ),
      ),
    ),
            Expanded(
              child: StreamBuilder<List<JournalEntry>>(
                stream: _journalService.getUserEntries(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading entries.", style: GoogleFonts.poppins(color: Colors.black)));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No entries yet!", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)));
                  }

                  final entries = snapshot.data!;

                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: 1.0,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: const Color(0xFFA8E6CF),
                          child: ListTile(
                            leading: Text(
                              getMoodIcon(entry.mood),
                              style: const TextStyle(fontSize: 28),
                            ),
                            title: Text(
                              entry.title.isNotEmpty ? entry.title : "Untitled",
                              style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Mood: ${entry.mood}\n${formatDate(entry.date)}",
                              style: GoogleFonts.poppins(color: Colors.black),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 600),
                                  pageBuilder: (context, animation, secondaryAnimation) => JournalDetailScreen(entry: entry),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF00BFA6),
              child: const Icon(Icons.edit, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (context, animation, secondaryAnimation) => JournalEntryScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
