import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/music_recommendation.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _apiKey = 'AIzaSyDKf71lai7DOR4vCHqKZHI3tovGxlZ_VJg'; // ⚠️ Move to env vars in production

final Map<String, List<String>> moodToMusic = {
  'Happy😁': [
    'upbeat happy songs',
    'feel-good pop hits',
    'dance party music',
    'positive vibe playlist',
    'summer pop songs',
    'cheerful mood booster'
  ],
  'Calm😌': [
    'calming relaxing music',
    'peaceful instrumental',
    'soft piano tracks',
    'chill acoustic playlist',
    'gentle ambient sounds',
    'relaxing evening tunes'
  ],
  'Sad😞': [
    'sad emotional songs',
    'heartbreak music',
    'sad indie acoustic',
    'melancholy soft songs',
    'emotional piano playlist',
    'slow sad ballads'
  ],
  'Neutral😑': [
    'chill background music',
    'lofi chillhop',
    'ambient workspace tunes',
    'instrumental focus music',
    'easy listening mix',
    'mellow instrumental beats'
  ],
  'Angry😠': [
    'anger release rock music',
    'intense metal playlist',
    'screamo for venting',
    'hard rock anthems',
    'aggressive rap tracks',
    'high energy guitar music'
  ],
  'Anxious😥': [
    'soothing anxiety relief music',
    'guided meditation sounds',
    'healing ambient pads',
    'calm your mind playlist',
    'deep breathing music',
    'serene background sounds'
  ],
  'Empty☹': [
    'ambient lonely melodies',
    'minimal piano sadness',
    'slow emotional strings',
    'quiet reflective music',
    'deep thinking tunes',
    'low energy instrumental'
  ],
};


final Map<String, List<String>> primaryEmotionToMusic = {
  'Excitement🤩': [
    'energetic workout playlist',
    'party hype tracks',
    'feel good EDM',
    'high energy hits',
    'fast-paced music',
    'motivational workout songs'
  ],
  'Joy😄': [
    'feel good hits',
    'sunshine pop anthems',
    'smiling indie mix',
    'happy acoustic playlist',
    'joyful tunes',
    'bright uplifting music'
  ],
  'Love🥰': [
    'romantic love songs',
    'slow dance ballads',
    'deep love RnB',
    'love pop playlist',
    'classic romantic hits',
    'soft emotional love songs'
  ],
  'Confidence😎': [
    'motivational hype music',
    'confident rap tracks',
    'swagger playlist',
    'power boost songs',
    'victory anthems',
    'bold attitude music'
  ],
  'Nostalgia🥹': [
    'nostalgic throwback tracks',
    '90s & 2000s hits',
    'vintage pop memories',
    'old favorites playlist',
    'soft rock classics',
    'memorable feel-good songs'
  ],
  'Overwhelm🤯': [
    'calming stress relief music',
    'breathing soundscapes',
    'reset your mind',
    'mental clarity sounds',
    'soothing background tracks',
    'slow peaceful music'
  ],
  'Self-Doubt😣': [
    'empowering anthems',
    'self-love affirmations',
    'you got this! mix',
    'confidence boost songs',
    'music to believe in yourself',
    'uplifting pop for growth'
  ],
  'Resentment😒': [
    'intense cathartic tunes',
    'angsty breakup rock',
    'rage vent metal',
    'emotional release songs',
    'songs to let go',
    'raw emotion playlist'
  ],
};


  final Random _random = Random();

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

      List<MusicTrack> moodTracks = [];
      List<MusicTrack> emotionTracks = [];

      // Randomized query selection
      if (mood != null && moodToMusic.containsKey(mood)) {
        final queries = moodToMusic[mood]!;
        final query = queries[_random.nextInt(queries.length)];
        print('Fetching YouTube music for mood query: $query');
        moodTracks = await _fetchYouTubeMusic(query);
      }

      if (primaryEmotion != null && primaryEmotionToMusic.containsKey(primaryEmotion)) {
        final queries = primaryEmotionToMusic[primaryEmotion]!;
        final query = queries[_random.nextInt(queries.length)];
        print('Fetching YouTube music for emotion query: $query');
        emotionTracks = await _fetchYouTubeMusic(query);
      }

      if (moodTracks.isEmpty && emotionTracks.isEmpty) {
        print('No tracks found for mood or emotion.');
        return;
      }

      // Create Firestore doc
      final recommendationDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('music_recommendations')
          .doc();

      final recommendation = MusicRecommendation(
        id: recommendationDoc.id,
        timestamp: DateTime.now(),
        fromCheckinId: checkin.id,
        moodTracks: moodTracks,
        emotionTracks: emotionTracks,
        userPlayed: [],
      );

      await recommendationDoc.set(recommendation.toMap());
      print('Recommendations saved successfully for user: $userId');

    } catch (e) {
      print('Error generating recommendation: $e');
    }
  }

  Future<List<MusicTrack>> _fetchYouTubeMusic(String query) async {
    final orders = ['relevance', 'date', 'viewCount'];
    final order = orders[_random.nextInt(orders.length)];

    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search'
      '?part=snippet'
      '&maxResults=10'
      '&q=${Uri.encodeComponent(query)}'
      '&type=video'
      '&videoCategoryId=10'
      '&order=$order'
      '&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      print('YouTube API error: ${response.statusCode} - ${response.body}');
      return [];
    }

    final data = json.decode(response.body);
    final items = data['items'] as List<dynamic>;

    final tracks = items.map((item) {
      final id = item['id']['videoId'];
      final title = item['snippet']['title'];
      final artistName = item['snippet']['channelTitle'];
      final trackUrl = 'https://www.youtube.com/watch?v=$id';
      final albumArtUrl = item['snippet']['thumbnails']['high']['url'];

      return MusicTrack(
        trackName: title,
        artistName: artistName,
        trackUrl: trackUrl,
        albumArtUrl: albumArtUrl,
      );
    }).toList();

    tracks.shuffle();
    return tracks.take(5).toList(); // Return only top 5 shuffled
  }
}
