import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/playlist_provider.dart';
import 'cached_artwork.dart';

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    if (player.currentTrack == null) return const SizedBox.shrink();

    final track = player.currentTrack!;

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CachedArtwork(
                albumArt: track.albumArt,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(8),
                fallback: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(FontAwesomeIcons.music, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.display),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dispositivos')),
                  );
                },
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.plus),
                onPressed: () => _showAddToAlbumMenu(context, track),
              ),
              IconButton(
                icon: FaIcon(player.isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play),
                iconSize: 32,
                onPressed: () => player.togglePlayPause(),
              ),
            ],
          ),
          Row(
            children: [
              Text(_format(player.position), style: Theme.of(context).textTheme.bodySmall),
              Expanded(
                child: Slider(
                  value: player.duration.inMilliseconds > 0
                      ? player.position.inMilliseconds.toDouble().clamp(0, player.duration.inMilliseconds.toDouble())
                      : 0,
                  max: player.duration.inMilliseconds > 0 ? player.duration.inMilliseconds.toDouble() : 1,
                  onChanged: (v) => player.seek(Duration(milliseconds: v.toInt())),
                ),
              ),
              Text(_format(player.duration), style: Theme.of(context).textTheme.bodySmall),
            ],
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
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'),
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
                leading: FaIcon(FontAwesomeIcons.bars),
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
