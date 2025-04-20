import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/music_recommendation.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _apiKey = 'AIzaSyDKf71lai7DOR4vCHqKZHI3tovGxlZ_VJg'; // ⚠️ Make sure to use env variables in production

  final Map<String, String> moodToMusic = {
    'Happy😁': 'upbeat happy songs',
    'Calm😌': 'calming relaxing music',
    'Sad😞': 'sad emotional songs',
    'Neutral😑': 'chill background music',
    'Angry😠': 'anger release rock music',
    'Anxious😥': 'soothing anxiety relief music',
    'Empty☹': 'ambient lonely melodies',
  };

  final Map<String, String> primaryEmotionToMusic = {
    'Excitement🤩': 'energetic workout playlist',
    'Joy😄': 'feel good hits',
    'Love🥰': 'romantic love songs',
    'Confidence😎': 'motivational hype music',
    'Nostalgia🥹': 'nostalgic throwback tracks',
    'Overwhelm🤯': 'calming stress relief music',
    'Self-Doubt😣': 'empowering anthems',
    'Resentment😒': 'intense cathartic tunes',
  };

 Future<void> generateAndStoreRecommendations(String userId) async {
  try {
    print('Starting to generate recommendations for user: $userId');

    final checkinSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('checkins')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (checkinSnapshot.docs.isEmpty) {
      print('No check-ins found for user: $userId');
      return;
    }

    final checkin = checkinSnapshot.docs.first;
    final checkinData = checkin.data();

    final mood = checkinData['mood'] as String?;
    final primaryEmotion = checkinData['primaryEmotion'] as String?;

    print('Latest check-in mood: $mood, emotion: $primaryEmotion');

    final queries = <String>{};
    if (mood != null && moodToMusic.containsKey(mood)) {
      queries.add(moodToMusic[mood]!);
    }
    if (primaryEmotion != null && primaryEmotionToMusic.containsKey(primaryEmotion)) {
      queries.add(primaryEmotionToMusic[primaryEmotion]!);
    }

    if (queries.isEmpty) {
      print('No queries found for mood or emotion.');
      return;
    }

    final tracks = <MusicTrack>[];
    for (final query in queries) {
      print('Fetching YouTube music for query: $query');
      final results = await _fetchYouTubeMusic(query);
      print('Found ${results.length} tracks for query: $query');
      tracks.addAll(results);
    }

    if (tracks.isEmpty) {
      print('No tracks found for any query.');
      return;
    }

    final recommendationDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('music_recommendations')
        .doc();

    final recommendation = MusicRecommendation(
      id: recommendationDoc.id,
      timestamp: DateTime.now(),
      fromCheckinId: checkin.id,
      recommendedTracks: tracks,
      userPlayed: [],
    );

    await recommendationDoc.set(recommendation.toMap());
    print('Recommendations saved successfully for user: $userId');

  } catch (e) {
    print('Error generating recommendation: $e');
  }
}


  Future<List<MusicTrack>> _fetchYouTubeMusic(String query) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search'
      '?part=snippet'
      '&maxResults=5'
      '&q=${Uri.encodeComponent(query)}'
      '&type=video'
      '&videoCategoryId=10' // Music category
      '&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      print('YouTube API error: ${response.statusCode} - ${response.body}');
      return [];
    }

    final data = json.decode(response.body);
    final items = data['items'] as List<dynamic>;

    return items.map((item) {
      final id = item['id']['videoId'];
      final title = item['snippet']['title'];
      final artistName = item['snippet']['channelTitle']; // YouTube channel as artist
      final trackUrl = 'https://www.youtube.com/watch?v=$id';
      final albumArtUrl = item['snippet']['thumbnails']['high']['url']; // Use high-quality thumbnail

      return MusicTrack(
        trackName: title,
        artistName: artistName,
        trackUrl: trackUrl,
        albumArtUrl: albumArtUrl,
      );
    }).toList();
  }
}
