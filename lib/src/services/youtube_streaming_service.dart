import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/yt_track.dart';

class YouTubeStreamingService {
  YouTubeStreamingService._();
  static final instance = YouTubeStreamingService._();

  final Map<String, YtTrack> _cache = {};

  Future<YtTrack?> resolve(YtTrack track) async {
    final key = track.id.isNotEmpty ? track.id : track.title;
    if (_cache.containsKey(key)) return _cache[key];

    final yt = YoutubeExplode();
    try {
      final video = track.id.isNotEmpty
          ? await yt.videos.get(track.id)
          : (await yt.search.search(track.title)).first;
      final manifest = await yt.videos.streamsClient.getManifest(video.id);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final resolved = YtTrack(
        id: video.id.value,
        title: video.title,
        artist: video.author,
        thumbnailUrl: video.thumbnails.highResUrl,
        durationSeconds: video.duration?.inSeconds ?? 0,
        streamUrl: streamInfo.url.toString(),
      );
      _cache[key] = resolved;
      return resolved;
    } catch (_) {
      return null;
    } finally {
      yt.close();
    }
  }
}
