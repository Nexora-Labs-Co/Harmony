import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/services/local_music_service.dart';
import 'package:harmony/src/services/player_service.dart';
import 'package:xora/xora.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LocalTrack>>(
      future: LocalMusicService.instance.scan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = snapshot.data ?? [];
        final q = _query.toLowerCase();
        final results = q.isEmpty
            ? all
            : all.where((t) =>
                t.title.toLowerCase().contains(q) ||
                t.artist.toLowerCase().contains(q) ||
                t.album.toLowerCase().contains(q)).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar canciones, artistas o álbumes',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('Sin resultados'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final t = results[index];
                        return ListTile(
                          leading: XoraArtwork(
                            path: t.coverPath,
                            width: 44,
                            height: 44,
                            borderRadius: BorderRadius.circular(6),
                            fallback: Container(
                              width: 44,
                              height: 44,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.music_note),
                            ),
                          ),
                          title: Text(t.title),
                          subtitle: Text(t.artist),
                          onTap: () => PlayerService.instance.play(t, queue: results),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}