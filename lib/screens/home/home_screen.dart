import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../forum/forum_home.dart';
import '../journal/journal_home.dart';
import '../chatbot/chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 4, 18, 39),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue.shade800,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade700),
              child: Text(
                "Menu",
                style: GoogleFonts.pacifico(fontSize: 28, color: Colors.white),
              ),
            ),
            _buildDrawerItem(Icons.person, "Profile"),
            _buildDrawerItem(Icons.music_note, "Music Recommendations"),
            _buildDrawerItem(Icons.article, "Articles"),
            _buildDrawerItem(Icons.shield_moon, "Sleep"),
            _buildDrawerItem(Icons.mediation, "Meditation"),
          ],
        ),
      ),
      body: Stack(
        children: [
          _buildCloudsBackground(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Aether",
                  style: GoogleFonts.pacifico(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildCheckInCard(),
                SizedBox(height: 20),
                _buildButtonRow(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudsBackground() {
    return Stack(
      children: [
        Positioned(top: 50, left: 30, child: _buildCloud()),
        Positioned(top: 150, right: 30, child: _buildCloud()),
        Positioned(bottom: 100, left: 80, child: _buildCloud()),
        Positioned(bottom: 200, right: 50, child: _buildCloud()),
        Positioned(bottom: 50, left: 20, child: _buildCloud()),
        Positioned(bottom: 30, right: 40, child: _buildCloud()),
      ],
    );
  }

  Widget _buildCloud() {
    return Icon(Icons.cloud, color: Colors.white.withOpacity(0.3), size: 60);
  }

  Widget _buildCheckInCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("How are you feeling today?",
              style: TextStyle(fontSize: 18, color: Colors.white)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _emojiButton("😃"),
              _emojiButton("🙂"),
              _emojiButton("😐"),
              _emojiButton("☹"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emojiButton(String emoji) {
    return GestureDetector(
      onTap: () {},
      child: Text(emoji, style: TextStyle(fontSize: 30)),
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _buildNavButton(context, "Forum", Icons.forum, ForumHome(), const Color.fromARGB(255, 30, 199, 233))),
        SizedBox(width: 10),
        Expanded(child: _buildNavButton(context, "Journal", Icons.book, JournalHome(), const Color.fromARGB(255, 59, 141, 255))),
        SizedBox(width: 10),
        Expanded(child: _buildNavButton(context, "Lily-Chatbot", Icons.smart_toy, ChatbotScreen(), const Color.fromARGB(255, 74, 195, 167))),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, String text, IconData icon, Widget page, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(height: 5),
            Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}