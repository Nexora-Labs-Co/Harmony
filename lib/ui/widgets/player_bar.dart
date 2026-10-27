import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

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
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.music_note),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.currentTrack!.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text(player.currentTrack!.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 32, onPressed: () => player.togglePlayPause()),
              IconButton(icon: const Icon(Icons.stop), iconSize: 32, onPressed: () => player.stop()),
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
