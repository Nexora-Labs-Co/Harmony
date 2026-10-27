import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../providers/player_provider.dart';

class DesktopBottomBar extends StatelessWidget {
  const DesktopBottomBar({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    if (player.currentTrack == null) return const SizedBox.shrink();

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.music_note, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.currentTrack!.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        player.currentTrack!.artist,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.favorite_border, size: 18),
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
                      icon: Icon(Icons.shuffle, size: 16),
                      onPressed: () => player.toggleShuffle(),
                      color: player.shuffle ? Theme.of(context).colorScheme.primary : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_previous, size: 20),
                      onPressed: () => player.previous(),
                    ),
                    IconButton(
                      icon: Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 20,
                      ),
                      onPressed: () => player.togglePlayPause(),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next, size: 20),
                      onPressed: () => player.next(),
                    ),
                    IconButton(
                      icon: Icon(
                        player.repeatMode == PlayerRepeatMode.one
                            ? Icons.repeat
                            : Icons.repeat,
                        size: 16,
                      ),
                      onPressed: () => player.toggleRepeat(),
                      color: player.repeatMode != PlayerRepeatMode.none ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatDuration(player.position),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: Slider(
                        value: player.position.inMilliseconds.toDouble().clamp(0, player.duration.inMilliseconds.toDouble().clamp(1, double.infinity)),
                        max: player.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                        onChanged: (value) {
                          player.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                    Text(
                      _formatDuration(player.duration),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
                  icon: Icon(Icons.queue_music, size: 16),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.devices, size: 16),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.volume_up, size: 16),
                  onPressed: () {},
                ),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: player.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (v) => player.setVolume(v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
