import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/yt_track.dart';

class YouTubeSearchService {
  YouTubeSearchService._();
  static final instance = YouTubeSearchService._();

  static const _modulePath = '/home/saaarmyx/Desktop/NexoraLabsCo/Modules/harmony-search/search.py';

  Future<List<YtTrack>> search(String query, {int limit = 20}) async {
    // Fast, universal path: scrape YouTube search results (no process window).
    try {
      final uri = Uri.parse('https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}');
      final res = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
      if (res.statusCode == 200) {
        final html = res.body;
        final reg = RegExp(r'"videoId":"([A-Za-z0-9_-]{11})".*?"title":\{"runs":\[\{"text":"([^"]+)"', dotAll: true);
        final matches = reg.allMatches(html);
        final seen = <String>{};
        final out = <YtTrack>[];
        for (final m in matches) {
          final id = m.group(1)!;
          if (!seen.add(id)) continue;
          final title = m.group(2)!;
          out.add(YtTrack(
            id: id,
            title: title,
            artist: '',
            thumbnailUrl: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
            durationSeconds: 0,
          ));
          if (out.length >= limit) break;
        }
        if (out.isNotEmpty) return out;
      }
    } catch (_) {}

    // Optional desktop module fallback.
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
