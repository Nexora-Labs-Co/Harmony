import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/models/yt_track.dart';
import 'package:harmony/src/services/player_service.dart';
import 'package:harmony/src/services/youtube_search_service.dart';
import 'package:harmony/src/services/youtube_streaming_service.dart';
import 'package:harmony/src/shared/widgets/cached_artwork.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<YtTrack> _results = [];
  bool _loading = false;

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _loading = true);
    final res = await YouTubeSearchService.instance.search(q);
    if (!mounted) return;
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  Future<void> _play(YtTrack t) async {
    final resolved = await YouTubeStreamingService.instance.resolve(t);
    if (resolved == null || resolved.streamUrl == null) return;
    final track = LocalTrack(
      path: resolved.streamUrl!,
      title: resolved.title,
      artist: resolved.artist,
      album: '',
      durationMs: resolved.durationSeconds * 1000,
      coverPath: resolved.thumbnailUrl,
    );
    PlayerService.instance.play(track);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar en YouTube',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: _search,
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        Expanded(
          child: _results.isEmpty
              ? const Center(child: Text('Busca una canción'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final t = _results[index];
                    return ListTile(
                      leading: CachedArtwork(
                        path: t.thumbnailUrl,
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(6),
                        fallback: const Icon(Icons.music_note),
                      ),
                      title: Text(t.title),
                      subtitle: Text(t.artist),
                      onTap: () => _play(t),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
