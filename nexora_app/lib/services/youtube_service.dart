import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'audio_service.dart';

class YouTubeTrack {
  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final String thumbnailUrl;

  const YouTubeTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.thumbnailUrl,
  });

  String get watchUrl => 'https://www.youtube.com/watch?v=$id';
}

class YouTubeService {
  YouTubeService._internal();
  static final YouTubeService instance = YouTubeService._internal();

  final YoutubeExplode _yt = YoutubeExplode();

  Future<List<YouTubeTrack>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final results = await _yt.search.getVideos(query);
      return results.map((v) {
        return YouTubeTrack(
          id: v.id.value,
          title: v.title,
          artist: v.author,
          duration: v.duration ?? Duration.zero,
          thumbnailUrl: v.thumbnails.highResUrl,
        );
      }).toList();
    } catch (e) {
      debugPrint('YouTubeService.search error: $e');
      return [];
    }
  }

  Future<String?> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audio = manifest.audioOnly.withHighestBitrate();
      return audio.url.toString();
    } catch (e) {
      debugPrint('YouTubeService.getAudioStreamUrl error: $e');
      return null;
    }
  }

  Future<bool> playTrack(YouTubeTrack track) async {
    final url = await getAudioStreamUrl(track.id);
    if (url == null) return false;
    try {
      await AudioService.instance.playUrl(url, title: track.title, artist: track.artist, thumbnailUrl: track.thumbnailUrl, durationMs: track.duration.inMilliseconds);
      return true;
    } catch (e) {
      debugPrint('YouTubeService.playTrack error: $e');
      return false;
    }
  }

  void dispose() {
    _yt.close();
  }
}
