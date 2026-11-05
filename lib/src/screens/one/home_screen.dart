import 'package:flutter/material.dart';
import 'dart:math';

import 'package:xora/xora.dart';
import 'package:harmony/src/services/local_music_service.dart';
import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/shared/widgets/cached_artwork.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.userName = 'Usuario'});

  final String userName;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Buenos días';
    if (h >= 12 && h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          '${_greeting()}, $userName',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://picsum.photos/seed/harmony/800/400',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              height: 200,
              color: XoraColors.surfaceVariant,
              child: const Icon(Icons.image, size: 48),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _section(context, 'Recomendado para ti hoy'),
        _recommendedSlide(),
        const SizedBox(height: 16),
        _section(context, 'Lo más nuevo'),
        _slide(),
        const SizedBox(height: 16),
        _section(context, 'Tus playlist'),
        _slide(),
        const SizedBox(height: 16),
        _section(context, 'Recientes'),
        _recentSlide(),
      ],
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _slide() {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: XoraColors.surfaceVariant,
                      child: const Center(child: Icon(Icons.music_note)),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text('Canción ${i + 1}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                Text('Artista ${i + 1}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: XoraColors.textSecondary)),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _recommendedSlide() {
    return FutureBuilder<List<LocalTrack>>(
      future: LocalMusicService.instance.scan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
        }
        final tracks = snapshot.data ?? [];
        if (tracks.isEmpty) return _slide();
        final now = DateTime.now();
        final seed = now.year * 10000 + now.month * 100 + now.day;
        final rnd = Random(seed);
        final shuffled = List<LocalTrack>.from(tracks)..shuffle(rnd);
        final items = shuffled.take(20).toList();
        return SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final t = items[i];
              return SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CachedArtwork(
                        path: t.coverPath,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.circular(12),
                        fallback: Container(color: XoraColors.surfaceVariant, child: const Center(child: Icon(Icons.music_note))),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    Text(t.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: XoraColors.textSecondary)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _recentSlide() {
    return FutureBuilder<List<LocalTrack>>(
      future: LocalMusicService.instance.scan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
        }
        final tracks = snapshot.data ?? [];
        if (tracks.isEmpty) return _slide();
        // Most recently played first; without playback history, show last scanned first.
        final items = tracks.reversed.take(20).toList();
        return SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final t = items[i];
              return SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CachedArtwork(
                        path: t.coverPath,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.circular(12),
                        fallback: Container(color: XoraColors.surfaceVariant, child: const Center(child: Icon(Icons.music_note))),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    Text(t.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: XoraColors.textSecondary)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
