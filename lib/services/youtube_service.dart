import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'audio_service.dart';
import '../bridge/bridge_generated.dart';

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
      debugPrint('YouTubeService: ${results.length} results for $query');
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

  Future<List<Track>> searchTracks(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final results = await _yt.search.getVideos(query);
      return results.map((v) {
        return Track(
          id: v.id.value,
          title: v.title,
          artist: v.author,
          album: 'YouTube Music',
          albumArt: v.thumbnails.highResUrl,
          sourceUri: 'https://www.youtube.com/watch?v=${v.id.value}',
          durationMs: (v.duration ?? Duration.zero).inMilliseconds,
          trackType: TrackType.Remote,
          path: null,
        );
      }).toList();
    } catch (e) {
      debugPrint('YouTubeService.searchTracks error: $e');
      return [];
    }
  }

  Future<String?> getStreamUrl(String youtubeId) => getAudioStreamUrl(youtubeId);

  Future<String?> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      // Prefer MP4/M4A (AAC) streams for better compatibility with the player.
      final mp4Streams = manifest.audioOnly.where((s) {
        final mime = s.codec.mimeType.toLowerCase();
        return mime.contains('mp4') || mime.contains('m4a') || mime.contains('aac');
      }).toList();
      final audio = mp4Streams.isNotEmpty
          ? mp4Streams.reduce((a, b) => a.bitrate.bitsPerSecond > b.bitrate.bitsPerSecond ? a : b)
          : manifest.audioOnly.withHighestBitrate();
      debugPrint('YouTubeService: selected ${audio.codec.mimeType} ${audio.bitrate} for $videoId');
      return audio.url.toString();
    } catch (e) {
      debugPrint('YouTubeService.getAudioStreamUrl error: $e');
      return null;
    }
  }

  Future<bool> playTrack(YouTubeTrack track) async {
    debugPrint('YouTubeService.playTrack: resolving stream for ${track.id}');
    final url = await getAudioStreamUrl(track.id);
    if (url == null) {
      debugPrint('YouTubeService.playTrack: no stream url for ${track.id}');
      return false;
    }
    debugPrint('YouTubeService.playTrack: stream url = $url');
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
