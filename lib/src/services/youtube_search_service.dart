import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/yt_track.dart';

class YouTubeSearchService {
  YouTubeSearchService._();
  static final instance = YouTubeSearchService._();

  Future<List<YtTrack>> search(String query, {int limit = 20}) async {
    final yt = YoutubeExplode();
    try {
      final videos = await yt.search.search(query);
      return videos.take(limit).map((v) => YtTrack(
        id: v.id.value,
        title: v.title,
        artist: v.author,
        thumbnailUrl: v.thumbnails.highResUrl,
        durationSeconds: v.duration?.inSeconds ?? 0,
      )).toList();
    } catch (_) {
      return [];
    } finally {
      yt.close();
    }
  }
}
