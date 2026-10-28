import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../bridge/bridge_generated.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/playlist_provider.dart';
import '../cached_artwork.dart';

class AlbumDetailContent extends StatelessWidget {
  final String playlistId;
  const AlbumDetailContent({super.key, required this.playlistId});

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    final playerProvider = context.watch<PlayerProvider>();

    final playlist = playlistProvider.playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => playlistProvider.playlists.isNotEmpty ? playlistProvider.playlists.first : null as dynamic,
    );
    if (playlist == null) {
      return const Center(child: Text('Album no encontrado'));
    }

    final tracks = playlist.trackIds
        .map((id) => libraryProvider.allTracks.firstWhere((t) => t.id == id, orElse: () => null as dynamic))
        .where((t) => t != null)
        .cast<Track>()
        .toList();

    final totalMs = tracks.fold<int>(0, (s, t) => s + t.durationMs);
    final totalDur = Duration(milliseconds: totalMs);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.queue_music, size: 64),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ALBUM', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(playlist.name, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(playlist.description.isEmpty ? 'Sin descripcion' : playlist.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text('${tracks.length} pistas • ${_format(totalDur)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // ── Acciones ────────────────────────────────────────────────────
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {
                  if (tracks.isNotEmpty) playerProvider.setQueue(tracks);
                },
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Reproducir todo'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  if (tracks.isNotEmpty) {
                    playerProvider.setQueue(tracks);
                    playerProvider.toggleShuffle();
                  }
                },
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text('Aleatorio'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Tabla de canciones ──────────────────────────────────────────
          Expanded(
            child: tracks.isEmpty
                ? Center(child: Text('Este album no tiene pistas', style: Theme.of(context).textTheme.bodyMedium))
                : ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      final isFav = libraryProvider.isFavorite(track.id);
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 28, child: Text('${index + 1}', style: Theme.of(context).textTheme.bodySmall)),
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedArtwork(
                                albumArt: track.albumArt,
                                width: 40,
                                height: 40,
                                borderRadius: BorderRadius.circular(4),
                                fallback: Container(
                                  width: 40,
                                  height: 40,
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.music_note, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(track.artist.isEmpty ? 'Artista desconocido' : track.artist,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(track.album, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ),
                            const SizedBox(width: 12),
                            Text(_formatMs(track.durationMs), style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 18,
                                  color: isFav ? Colors.red : null),
                              onPressed: () => libraryProvider.toggleFavorite(track.id),
                            ),
                          ],
                        ),
                        onTap: () => playerProvider.setQueue(tracks, startIndex: index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
