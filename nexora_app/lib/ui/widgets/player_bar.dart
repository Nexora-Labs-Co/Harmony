import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/audio_service.dart';

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioService>();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.album, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio.currentTrack?.title ?? 'Sin reproducción',
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  audio.currentTrack?.artist ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(audio.playing ? Icons.pause : Icons.play_arrow),
            iconSize: 32,
            onPressed: audio.initialized ? () => audio.togglePlayPause() : null,
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            iconSize: 32,
            onPressed: audio.initialized ? () => audio.stop() : null,
          ),
          const SizedBox(width: 16),
          const Icon(Icons.volume_down),
          SizedBox(
            width: 150,
            child: Slider(
              value: audio.volume,
              min: 0.0,
              max: 1.0,
              onChanged: audio.initialized ? (v) => audio.setVolume(v) : null,
            ),
          ),
          const Icon(Icons.volume_up),
        ],
      ),
    );
  }
}
```