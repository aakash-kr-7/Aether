import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/jh.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              AppBar(
                title: Text(
                  "Memory Log",
                  style: GoogleFonts.pacifico(fontSize: 26, color: Colors.white),
                ),
                backgroundColor: const Color.fromARGB(255, 54, 172, 109),
              ),
              Expanded(
                child: StreamBuilder<List<JournalEntry>>(
                  stream: _journalService.getUserEntries(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading entries.", style: TextStyle(color: Colors.black)));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "No entries yet!",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      );
                    }

                    final entries = snapshot.data!;

                    return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return AnimatedOpacity(
                          duration: Duration(milliseconds: 800),
                          opacity: 1.0,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            color: const Color.fromARGB(255, 200, 245, 208),
                            child: ListTile(
                              title: Text(entry.title.isNotEmpty ? entry.title : "Untitled", style: TextStyle(color: Colors.black)),
                              subtitle: Text("Mood: ${entry.mood}\n${formatDate(entry.date)}", style: TextStyle(color: Colors.black)),
                              leading: Icon(Icons.book, color: const Color.fromARGB(255, 76, 206, 65)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: Duration(milliseconds: 600),
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
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 76, 206, 65),
              child: Icon(Icons.edit, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 600),
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
