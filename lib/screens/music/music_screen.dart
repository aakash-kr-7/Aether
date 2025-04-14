import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/music_recommendation.dart';
import '../../services/recommendation_service.dart';

class MusicRecommendationScreen extends StatefulWidget {
  final String userId;

  const MusicRecommendationScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _MusicRecommendationScreenState createState() => _MusicRecommendationScreenState();
}

class _MusicRecommendationScreenState extends State<MusicRecommendationScreen> {
  late final RecommendationService _recommendationService;
  List<MusicTrack> _recommendedTracks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _recommendationService = RecommendationService();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final checkinSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('checkins') // ✅ important: you had 'checkin', corrected to 'checkins'
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (checkinSnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No recent check-ins found.';
        });
        return;
      }

      final latestCheckinId = checkinSnapshot.docs.first.id;

      final recommendationsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('music_recommendations')
          .where('fromCheckinId', isEqualTo: latestCheckinId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (recommendationsSnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No recommendations found for your latest check-in.';
        });
        return;
      }

      final recommendationData = recommendationsSnapshot.docs.first.data();
      final recommendationId = recommendationsSnapshot.docs.first.id;

      final recommendation = MusicRecommendation.fromMap(recommendationId, recommendationData);

      setState(() {
        _recommendedTracks = recommendation.recommendedTracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading recommendations: $e';
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Music Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _recommendedTracks.isEmpty
                  ? const Center(child: Text('No tracks available.'))
                  : ListView.builder(
                      itemCount: _recommendedTracks.length,
                      itemBuilder: (context, index) {
                        final track = _recommendedTracks[index];
                        return ListTile(
                          leading: Image.network(
                            track.albumArtUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note),
                          ),
                          title: Text(track.trackName),
                          subtitle: Text(track.artistName),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () => _launchURL(track.trackUrl),
                          ),
                        );
                      },
                    ),
    );
  }
}
