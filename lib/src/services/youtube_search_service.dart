import 'dart:convert';
import 'dart:io';

import '../models/yt_track.dart';

class YouTubeSearchService {
  YouTubeSearchService._();
  static final instance = YouTubeSearchService._();

  static const _modulePath = '/home/saaarmyx/Desktop/NexoraLabsCo/Modules/harmony-search/search.py';

  Future<List<YtTrack>> search(String query, {int limit = 20}) async {
    final module = File(_modulePath);
    if (module.existsSync()) {
      try {
        final res = await Process.run('python3', [module.path, query, '$limit']);
        if (res.exitCode == 0) {
          final data = jsonDecode(res.stdout as String) as List;
          return data.map((e) => YtTrack(
            id: e['id']?.toString() ?? '',
            title: e['title']?.toString() ?? '',
            artist: e['artist']?.toString() ?? '',
            thumbnailUrl: e['thumbnailUrl']?.toString(),
            durationSeconds: 0,
          )).toList();
        }
      } catch (_) {}
    }
    return [];
  }
}
