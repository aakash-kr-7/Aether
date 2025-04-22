import 'package:cloud_firestore/cloud_firestore.dart';

class MusicRecommendation {
  final String id; // Firestore document ID
  final DateTime timestamp;
  final String? fromCheckinId; // Optional reference to the check-in document
  final List<MusicTrack> moodTracks;
  final List<MusicTrack> emotionTracks;
  final List<String> userPlayed;

  MusicRecommendation({
    required this.id,
    required this.timestamp,
    this.fromCheckinId,
    required this.moodTracks,
    required this.emotionTracks,
    required this.userPlayed,
  });

  factory MusicRecommendation.fromMap(String id, Map<String, dynamic> data) {
    return MusicRecommendation(
      id: id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      fromCheckinId: data['fromCheckinId'],
      moodTracks: (data['moodTracks'] as List<dynamic>)
          .map((track) => MusicTrack.fromMap(track))
          .toList(),
      emotionTracks: (data['emotionTracks'] as List<dynamic>)
          .map((track) => MusicTrack.fromMap(track))
          .toList(),
      userPlayed: List<String>.from(data['userPlayed'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'fromCheckinId': fromCheckinId,
      'moodTracks': moodTracks.map((track) => track.toMap()).toList(),
      'emotionTracks': emotionTracks.map((track) => track.toMap()).toList(),
      'userPlayed': userPlayed,
    };
  }
}

class MusicTrack {
  final String trackName;
  final String artistName;
  final String trackUrl;
  final String albumArtUrl;

  MusicTrack({
    required this.trackName,
    required this.artistName,
    required this.trackUrl,
    required this.albumArtUrl,
  });

  factory MusicTrack.fromMap(Map<String, dynamic> data) {
    return MusicTrack(
      trackName: data['trackName'] ?? '',
      artistName: data['artistName'] ?? '',
      trackUrl: data['trackUrl'] ?? '',
      albumArtUrl: data['albumArtUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trackName': trackName,
      'artistName': artistName,
      'trackUrl': trackUrl,
      'albumArtUrl': albumArtUrl,
    };
  }
}
