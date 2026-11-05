import 'dart:convert';
import 'dart:io';

import '../models/yt_track.dart';

class YouTubeStreamingService {
  YouTubeStreamingService._();
  static final instance = YouTubeStreamingService._();

  static const _modulePath = '/home/saaarmyx/Desktop/NexoraLabsCo/Modules/harmony-media-streaming/stream.py';

  Future<YtTrack?> resolve(YtTrack track) async {
    final module = File(_modulePath);
    if (module.existsSync()) {
      try {
        final res = await Process.run('python3', [module.path, track.id.isNotEmpty ? track.id : track.title]);
        if (res.exitCode == 0) {
          final data = jsonDecode(res.stdout as String) as Map<String, dynamic>;
          return YtTrack(
            id: data['id']?.toString() ?? track.id,
            title: data['title']?.toString() ?? track.title,
            artist: data['artist']?.toString() ?? track.artist,
            thumbnailUrl: data['thumbnailUrl']?.toString() ?? track.thumbnailUrl,
            durationSeconds: (data['duration'] is num) ? (data['duration'] as num).toInt() : track.durationSeconds,
            streamUrl: data['streamUrl']?.toString(),
          );
        }
      } catch (_) {}
    }
    return null;
  }
}
