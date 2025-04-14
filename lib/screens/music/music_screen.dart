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
  String? _mood;
  String? _primaryEmotion;

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
          .collection('checkins')
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

      final checkinData = checkinSnapshot.docs.first.data();
      _mood = checkinData['mood'];
      _primaryEmotion = checkinData['primaryEmotion'];

      final recommendationsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('music_recommendations')
          .orderBy('timestamp', descending: true)
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
    backgroundColor: const Color(0xFF121212), // Dark background for premium feel
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Your Music Recommendations',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadRecommendations,
        ),
      ],
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : _errorMessage != null
            ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)))
            : _recommendedTracks.isEmpty
                ? const Center(child: Text('No tracks available.', style: TextStyle(color: Colors.white)))
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      if (_mood != null && _recommendedTracks.isNotEmpty)
                        _buildRecommendationSection('Since you were feeling $_mood, here are your tracks:', _recommendedTracks),
                      if (_primaryEmotion != null && _recommendedTracks.isNotEmpty)
                        _buildRecommendationSection('Since you were feeling $_primaryEmotion, here are your tracks:', _recommendedTracks),
                      if (_recommendedTracks.isNotEmpty)
                        _buildRecommendationSection('Your Recently Played Tracks:', _recommendedTracks),
                    ],
                  ),
  );
}

Widget _buildRecommendationSection(String title, List<MusicTrack> tracks) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tracks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return GestureDetector(
                onTap: () => _launchURL(track.trackUrl),
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          track.albumArtUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 100,
                            color: Colors.grey,
                            child: const Icon(Icons.music_note, color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.trackName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
}