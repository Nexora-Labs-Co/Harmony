import 'package:flutter/material.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
import 'package:provider/provider.dart';

import '../../../providers/player_provider.dart';
import '../cached_artwork.dart';

class DesktopRightPanel extends StatelessWidget {
  const DesktopRightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final current = player.currentTrack;
    final queue = player.queue;
    final nextIndex = player.currentIndex + 1;
    final nextTrack =
        (nextIndex >= 0 && nextIndex < queue.length) ? queue[nextIndex] : null;

    final title = current == null
        ? 'Reproduciendo'
        : (current.album.isNotEmpty ? current.album : current.title);

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: NexoraColors.surfaceAlt,
        border: Border(
          left: BorderSide(color: NexoraColors.border),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NexoraColors.foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_full, size: 16, color: NexoraColors.foreground),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: current == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 48,
                          color: NexoraColors.muted,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Sin reproducción',
                          style: TextStyle(color: NexoraColors.muted),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedArtwork(
                          albumArt: current.albumArt,
                          width: double.infinity,
                          height: 280,
                          borderRadius: BorderRadius.circular(12),
                          fallback: Container(
                            width: double.infinity,
                            height: 280,
                            color: NexoraColors.surfaceHover,
                            child: const Icon(Icons.music_note, size: 80, color: NexoraColors.muted),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          current.title,
                          style: const TextStyle(
                            color: NexoraColors.foreground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          current.artist,
                          style: const TextStyle(
                            color: NexoraColors.mutedStrong,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          current.album,
                          style: const TextStyle(
                            color: NexoraColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Letra',
                          style: TextStyle(
                            color: NexoraColors.foreground,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: NexoraColors.surfaceHover,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: NexoraColors.border),
                          ),
                          child: const Text(
                            'Letra no disponible\n\nUsa la función de búsqueda de letra\npara obtener las letras de tus canciones',
                            style: TextStyle(
                              color: NexoraColors.muted,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Siguiente canción',
                          style: TextStyle(
                            color: NexoraColors.foreground,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (nextTrack != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: NexoraColors.surfaceHover,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: NexoraColors.border),
                            ),
                            child: Row(
                              children: [
                                CachedArtwork(
                                  albumArt: nextTrack.albumArt,
                                  width: 48,
                                  height: 48,
                                  borderRadius: BorderRadius.circular(6),
                                  fallback: Container(
                                    width: 48,
                                    height: 48,
                                    color: NexoraColors.surface,
                                    child: const Icon(Icons.music_note, color: NexoraColors.muted),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nextTrack.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: NexoraColors.foreground,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        nextTrack.artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: NexoraColors.muted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Text(
                            'No hay siguiente canción',
                            style: TextStyle(color: NexoraColors.muted, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
