import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    if (player.currentTrack == null) return const SizedBox.shrink();

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.music_note,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.currentTrack!.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      player.currentTrack!.artist,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 32,
                      onPressed: () => player.previous(),
                    ),
                    IconButton(
                      icon: Icon(player.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                      iconSize: 48,
                      onPressed: () => player.togglePlayPause(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 32,
                      onPressed: () => player.next(),
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
                      icon: Icon(player.shuffle ? Icons.shuffle : Icons.shuffle_outlined),
                      onPressed: () => player.toggleShuffle(),
                    ),
                    IconButton(
                      icon: Icon(
                        player.repeatMode == PlayerRepeatMode.one
                            ? Icons.repeat_one
                            : player.repeatMode == PlayerRepeatMode.all
                                ? Icons.repeat
                                : Icons.repeat_outlined,
                      ),
                      onPressed: () => player.toggleRepeat(),
                    ),
                    const Icon(Icons.volume_down),
                    SizedBox(
                      width: 100,
                      child: Slider(
                        value: player.volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (v) => player.setVolume(v),
                      ),
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
