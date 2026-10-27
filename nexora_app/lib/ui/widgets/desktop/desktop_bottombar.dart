import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/player_provider.dart';
import '../../../providers/playlist_provider.dart';
import '../../../providers/library_provider.dart';
import '../cached_artwork.dart';

class DesktopBottomBar extends StatelessWidget {
  const DesktopBottomBar({super.key});

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Widget _artwork(BuildContext context, String? albumArt) {
    return CachedArtwork(
      albumArt: albumArt,
      width: 56,
      height: 56,
      borderRadius: BorderRadius.circular(8),
      fallback: _genericArt(context),
    );
  }

  Widget _genericArt(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.music_note, size: 28, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    if (player.currentTrack == null) return const SizedBox.shrink();

    final track = player.currentTrack!;
    final remaining = player.duration - player.position;
    final remainingClamped = remaining.isNegative ? Duration.zero : remaining;

    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                RepaintBoundary(
                  child: _BottomArtwork(albumArt: track.albumArt),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      track.artist.isEmpty ? 'Artista desconocido' : track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Consumer<LibraryProvider>(
                  builder: (context, lib, _) {
                    final isFav = track.id.isNotEmpty && lib.isFavorite(track.id);
                    return IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 20,
                          color: isFav ? Colors.red : null),
                      tooltip: 'Favorito',
                      onPressed: () => lib.toggleFavorite(track.id),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.library_add, size: 20),
                  tooltip: 'Anadir a album',
                  onPressed: () => _showAddToAlbumMenu(context, track),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle, size: 22),
                      color: player.shuffle
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      onPressed: () => player.toggleShuffle(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 28),
                      onPressed: () => player.previous(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(player.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 40),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => player.togglePlayPause(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 28),
                      onPressed: () => player.next(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        player.repeatMode == PlayerRepeatMode.one ? Icons.repeat_one : Icons.repeat,
                        size: 22,
                      ),
                      color: player.repeatMode != PlayerRepeatMode.none
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      onPressed: () => player.toggleRepeat(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(_format(player.position), style: Theme.of(context).textTheme.bodySmall),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        ),
                        child: Slider(
                          value: player.duration.inMilliseconds > 0
                              ? player.position.inMilliseconds.toDouble().clamp(0, player.duration.inMilliseconds.toDouble())
                              : 0.0,
                          max: player.duration.inMilliseconds > 0 ? player.duration.inMilliseconds.toDouble() : 1.0,
                          onChanged: (v) => player.seek(Duration(milliseconds: v.toInt())),
                        ),
                      ),
                    ),
                    Text(_format(remainingClamped), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.queue_music, size: 20),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                Icon(Icons.volume_down, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(
                  width: 110,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(
                      value: player.volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (v) => player.setVolume(v),
                    ),
                  ),
                ),
                Icon(Icons.volume_up, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showAddToAlbumMenu(BuildContext context, dynamic track) {
  final provider = context.read<PlaylistProvider>();
  showModalBottomSheet(
    context: context,
    builder: (ctx) {
      if (provider.playlists.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No hay albumes creados'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // create
                },
                child: const Text('Crear album'),
              ),
            ],
          ),
        );
      }
      return ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Anadir a album', style: Theme.of(context).textTheme.titleMedium),
          ),
          ...provider.playlists.map((p) => ListTile(
                leading: const Icon(Icons.queue_music),
                title: Text(p.name),
                subtitle: Text('${p.trackIds.length} pistas'),
                onTap: () {
                  provider.addTrackToPlaylist(p.id, track.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Anadido a ${p.name}')),
                  );
                },
              )),
        ],
      );
    },
  );
}

class _BottomArtwork extends StatelessWidget {
  final String? albumArt;
  const _BottomArtwork({required this.albumArt});

  @override
  Widget build(BuildContext context) {
    return CachedArtwork(
      albumArt: albumArt,
      width: 56,
      height: 56,
      borderRadius: BorderRadius.circular(8),
      fallback: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.music_note, size: 28, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
