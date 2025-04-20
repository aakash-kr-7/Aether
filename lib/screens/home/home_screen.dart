import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../forum/forum_home.dart';
import '../journal/journal_home.dart';
import '../chatbot/chatbot_screen.dart';
import '../emotion/emotion_log_screen.dart';
import '../music/music_screen.dart';
import '../insights/insights_screen.dart';
import '../insights/insight_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/music_recommendation.dart';
import '../music/music_player_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


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

  List<Map<String, dynamic>> insightsList = [];

@override
void initState() {
  super.initState();
  fetchInsights();
}

void fetchInsights() async {
  final userId = _authService.currentUserId;
  if (userId == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('insights_generated')
      .orderBy('timestamp', descending: true)
      .get();

  final loadedInsights = snapshot.docs.map((doc) => doc.data()).toList();

  setState(() {
    insightsList = loadedInsights.cast<Map<String, dynamic>>();
  });
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


Future<List<MusicTrack>> fetchLatestRecommendations() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('User not logged in');
    return [];
  }

  final userId = user.uid;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('music_recommendations')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) return [];

  final data = snapshot.docs.first.data();
  final List<dynamic> rawTracks = data['recommendedTracks'] ?? [];

  return rawTracks.map((track) => MusicTrack.fromMap(track)).take(4).toList();
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
      _buildDrawerItem(Icons.person, "Profile", onTap: () {
        // Add navigation later
        Navigator.pop(context); // Close the drawer
      }),
      _buildDrawerItem(Icons.music_note, "Music Recommendations", onTap: () {
        Navigator.pop(context); // Close the drawer first
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MusicRecommendationScreen(userId: _authService.currentUserId!)),
        );
      }),
      _buildDrawerItem(Icons.article, "Insights", onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InsightsScreen()),
        );
      }),
      _buildDrawerItem(Icons.run_circle, "Activity Tracker", onTap: () {
        // Add navigation later
        Navigator.pop(context);
      }),
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
          FutureBuilder<List<MusicTrack>>(
  future: fetchLatestRecommendations(), // make sure `userId` is available
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator(); // or a shimmer placeholder
    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
      return SizedBox.shrink(); // no recommendations
    } else {
      return _buildMusicRecommendations(snapshot.data!, context);
    }
  },
),

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
          builder: (context) => EmotionLogScreen(userId: _authService.currentUserId!), // Pass actual userId
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
  return Container(
    height: 180,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: insightsList.length,
      itemBuilder: (context, index) {
        final insight = insightsList[index];
        return _buildInsightCard(insight);
      },
    ),
  );
}


Widget _buildInsightCard(Map<String, dynamic> insight) {
  String previewText = insight['text']
      .toString()
      .split(' ')
      .take(20)
      .join(' ') + '...';

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InsightDetailScreen(insight: insight),
        ),
      );
    },
    child: Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          previewText,
          style: TextStyle(color: Colors.white, fontSize: 13),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}

Widget _buildMusicRecommendations(List<MusicTrack> tracks, BuildContext context) {
  if (tracks.length < 4) return SizedBox.shrink();

  return Column(
    children: [
      // First Row: Two Tiles (Big and Small)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // First Tile
          _buildMusicTile(tracks[0], context),

          // Second Tile
          _buildMusicTile(tracks[1], context),
        ],
      ),
      SizedBox(height: 15),

      // Second Row: Two Tiles (Big and Small)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Third Tile
          _buildMusicTile(tracks[2], context),

          // Fourth Tile
          _buildMusicTile(tracks[3], context),
        ],
      ),
    ],
  );
}

// Helper Function to Build Music Tile
Widget _buildMusicTile(MusicTrack track, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MusicPlayerScreen(
            title: track.trackName,
            url: track.trackUrl,
          ),
        ),
      );
    },
    child: Container(
      height: 130, // Standard height for all tiles
      width: MediaQuery.of(context).size.width * 0.45, // Standard width for each tile
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(track.albumArtUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            track.trackName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black.withOpacity(0.6), offset: Offset(2, 2), blurRadius: 6)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ),
  );
}

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
