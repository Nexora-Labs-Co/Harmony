import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/player_provider.dart';

class DesktopBottomBar extends StatelessWidget {
  const DesktopBottomBar({super.key});

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Widget _artwork(BuildContext context, String? albumArt) {
    if (albumArt != null && albumArt.isNotEmpty) {
      try {
        final bytes = base64Decode(albumArt);
        return Image.memory(
          bytes,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) {
            debugPrint('Image.memory error: $err');
            return _genericArt(context);
          },
        );
      } catch (e) {
        debugPrint('base64Decode error: $e');
        return _genericArt(context);
      }
    }
    return _genericArt(context);
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _artwork(context, track.albumArt),
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
                        track.artist.isEmpty ? 'Artista desconocido' : track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border, size: 20),
                  onPressed: () {},
                ),
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