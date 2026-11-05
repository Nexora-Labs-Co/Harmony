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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CachedArtwork(
                    path: track.coverPath,
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.circular(10),
                    fallback: Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.music_note),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      PlayerService.instance.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: PlayerService.instance.togglePlay,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: PlayerService.instance.next,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
