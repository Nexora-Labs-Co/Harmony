import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/cached_artwork.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    final tracks = library.allTracks;

    final recommended = tracks.isEmpty ? <dynamic>[] : List.generate(8, (i) => tracks[i % tracks.length]);
    final albums = tracks.isEmpty ? <dynamic>[] : List.generate(4, (i) => tracks[i % tracks.length]);
    final recent = tracks.isEmpty ? <dynamic>[] : tracks.take(8).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greeting()}, Santiago',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _section(context, 'Recomendado por Cari, para ti', recommended, player, library),
            const SizedBox(height: 16),
            _section(context, 'Álbumes', albums, player, library),
            const SizedBox(height: 16),
            _section(context, 'Recientes', recent, player, library),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List tracks, PlayerProvider player, LibraryProvider library) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (tracks.isEmpty)
          Text('Sin canciones', style: Theme.of(context).textTheme.bodyMedium)
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 120,
                    child: InkWell(
                      onTap: () {
                        final idx = library.allTracks.indexOf(track);
                        player.setQueue(library.allTracks, startIndex: idx < 0 ? 0 : idx);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedArtwork(albumArt: track.albumArt, width: double.infinity, height: double.infinity, borderRadius: BorderRadius.circular(8), fallback: Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.music_note))),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
