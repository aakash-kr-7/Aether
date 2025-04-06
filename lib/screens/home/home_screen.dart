import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../forum/forum_home.dart';
import '../journal/journal_home.dart';
import '../chatbot/chatbot_screen.dart';
import '../emotion/emotion_log_screen.dart';

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

  Widget _buildSectionTitle(String title) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
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
          _buildDrawerItem(Icons.article, "Insights"),
          _buildDrawerItem(Icons.run_circle, "Activity Tracker"),
        ],
      ),
    ),
    body: SingleChildScrollView(  // Wrap the body content with SingleChildScrollView
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildTitle(),
          SizedBox(height: 10),
          _buildEmotionLoggingTile(),
          SizedBox(height: 15),
          _buildButtonRow(context),
          SizedBox(height: 15),
          _buildSectionTitle("Insights"),
          _buildInsightsSection(),
          SizedBox(height: 15),
          _buildSectionTitle("Music Recommendations"),
          _buildMusicRecommendations(),
          SizedBox(height: 15),
          _buildSectionTitle("Activity Tracker"),
          _buildActivityTracker(),
        ],
      ),
    ),
  );
}


  Widget _buildTitle() {
    return Text(
      "Aether",
      style: GoogleFonts.pacifico(
        fontSize: 48,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmotionLoggingTile() {
  return GestureDetector(
    onTap: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmotionLogScreen(userId: 'your_user_id'), // Pass actual userId
        ),
      );

      if (result == 'completed') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feel free to log again anytime!')),
        );

        setState(() {
          // If you want to update something visually in the home screen
        });
      }
    },
    child: Container(
      height: 120,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          "Log Your Emotions",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    ),
  );
}


  Widget _buildButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _buildNavButton(context, "Forum", Icons.forum, ForumHome(), Colors.cyan)),
        SizedBox(width: 10),
        Expanded(child: _buildNavButton(context, "Journal", Icons.book, JournalHome(), Colors.blueAccent)),
        SizedBox(width: 10),
        Expanded(child: _buildNavButton(context, "Lily", Icons.smart_toy, ChatbotScreen(), Colors.teal)),
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

  Widget _buildInsightsSection() {
  List<String> insights = [
    "Mindfulness",
    "Stress Relief",
    "Daily Motivation",
    "Positive Habits",
    "Emotional Balance",
    "Focus Boost",
    "Sleep Quality"
  ];

  return Container(
    height: 180, // Taller for a portrait-like shape
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: insights.length,
      itemBuilder: (context, index) {
        return _buildInsightCard(insights[index]);
      },
    ),
  );
}

Widget _buildInsightCard(String title) {
  return Container(
    width: 120, // Portrait shape
    margin: EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.blueGrey,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
    ),
  );
}


  Widget _buildMusicRecommendations() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text("Main Recommendation", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        SizedBox(width: 10),
        Column(
          children: [
            _buildSmallMusicTile("Feel It"),
            SizedBox(height: 10),
            _buildSmallMusicTile("Forget It"),
            SizedBox(height: 10),
            _buildSmallMusicTile("Deepen It"),
          ],
        )
      ],
    );
  }

  Widget _buildSmallMusicTile(String title) {
    return Container(
      width: 100,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.purpleAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget _buildActivityTracker() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text("Today's Progress", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        SizedBox(width: 10),
        Column(
          children: [
            _buildSmallActivityTile("Steps"),
            SizedBox(height: 10),
            _buildSmallActivityTile("Calories"),
            SizedBox(height: 10),
            _buildSmallActivityTile("Meditation"),
          ],
        )
      ],
    );
  }

  Widget _buildSmallActivityTile(String title) {
    return Container(
      width: 100,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
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
