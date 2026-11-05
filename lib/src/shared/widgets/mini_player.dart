import 'package:flutter/material.dart';

import 'package:harmony/src/services/player_service.dart';
import 'package:harmony/src/shared/widgets/cached_artwork.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PlayerService.instance,
      builder: (context, _) {
        final track = PlayerService.instance.currentTrack;
        if (track == null) return const SizedBox.shrink();
        return Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              CachedArtwork(
                path: track.coverPath,
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(6),
                fallback: Container(
                  width: 44,
                  height: 44,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.music_note),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(PlayerService.instance.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: PlayerService.instance.togglePlay,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: PlayerService.instance.next,
              ),
            ],
          ),
        );
      },
    );
  }
}
