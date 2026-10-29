
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:provider/provider.dart';

import '../../../providers/player_provider.dart';
import '../../../providers/playlist_provider.dart';
import '../../../providers/library_provider.dart';
import '../cached_artwork.dart';

class DesktopBottomBar extends StatelessWidget {
  const DesktopBottomBar({
    super.key,
    this.onToggleRightPanel,
    this.onToggleFullscreen,
  });

  final VoidCallback? onToggleRightPanel;
  final VoidCallback? onToggleFullscreen;

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  String _formatArtists(String raw) {
    final parts = raw.split(RegExp(r'\s*/\s*'));
    if (parts.length <= 1) return raw.trim();
    final limited = parts.take(3).map((e) => e.trim()).toList();
    final joined = limited.join(' · ');
    return parts.length > 3 ? '$joined...' : joined;
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
      decoration: const BoxDecoration(
        color: NexoraColors.surface,
        border: Border(top: BorderSide(color: NexoraColors.border)),
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
                Expanded(
                  child: Column(
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
                      track.artist.trim().isEmpty
                          ? 'Artista desconocido'
                          : _formatArtists(track.artist),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                ),
                const SizedBox(width: 8),
                Consumer<LibraryProvider>(
                  builder: (context, lib, _) {
                    final isFav = track.id.isNotEmpty && lib.isFavorite(track.id);
                    return IconButton(
                      icon: FaIcon(isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart, size: 22,
                          color: isFav ? const Color(0xFFA50021) : null),
                      tooltip: 'Favorito',
                      onPressed: () => lib.toggleFavorite(track.id),
                    );
                  },
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.plus, size: 22),
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
                      icon: FaIcon(FontAwesomeIcons.shuffle, size: 18),
                      color: player.shuffle
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      onPressed: () => player.toggleShuffle(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.backwardStep, size: 18),
                      onPressed: () => player.previous(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: FaIcon(player.isPlaying ? FontAwesomeIcons.circlePause : FontAwesomeIcons.circlePlay, size: 28),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => player.togglePlayPause(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.forwardStep, size: 18),
                      onPressed: () => player.next(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: FaIcon(
                        player.repeatMode == PlayerRepeatMode.one ? FontAwesomeIcons.repeat : FontAwesomeIcons.repeat,
                        size: 18,
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
                  icon: FaIcon(FontAwesomeIcons.microphone, size: 22),
                  tooltip: 'Letra',
                  onPressed: () => _showLyrics(context, track),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.bars, size: 22),
                  tooltip: 'Lista de reproduccion',
                  onPressed: onToggleRightPanel,
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.display, size: 22),
                  tooltip: 'Dispositivos',
                  onPressed: null,
                ),
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
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.expand, size: 22),
                  tooltip: 'Pantalla completa',
                  onPressed: onToggleFullscreen,
                ),
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
        child: FaIcon(FontAwesomeIcons.music, size: 22, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

void _showLyrics(BuildContext context, dynamic track) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(track.title ?? 'Letra'),
          leading: IconButton(
            icon: FaIcon(FontAwesomeIcons.xmark),
            onPressed: () => Navigator.pop(ctx),
          ),
        ),
        body: const Center(
          child: Text('Letra no disponible'),
        ),
      ),
    ),
  );
}
