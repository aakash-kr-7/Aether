import 'package:cloud_firestore/cloud_firestore.dart';

class MusicRecommendation {
  final String id; // Firestore document ID
  final DateTime timestamp;
  final String? fromCheckinId; // optional reference to the checkin
  final List<MusicTrack> recommendedTracks;
  final List<String> userPlayed;

  MusicRecommendation({
    required this.id,
    required this.timestamp,
    this.fromCheckinId,
    required this.recommendedTracks,
    required this.userPlayed,
  });

  factory MusicRecommendation.fromMap(String id, Map<String, dynamic> data) {
    return MusicRecommendation(
      id: id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      fromCheckinId: data['fromCheckinId'],
      recommendedTracks: (data['recommendedTracks'] as List<dynamic>)
          .map((track) => MusicTrack.fromMap(track))
          .toList(),
      userPlayed: List<String>.from(data['userPlayed'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'fromCheckinId': fromCheckinId,
      'recommendedTracks': recommendedTracks.map((track) => track.toMap()).toList(),
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
