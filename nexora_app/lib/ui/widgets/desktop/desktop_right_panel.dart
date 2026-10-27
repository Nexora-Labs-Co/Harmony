import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../providers/player_provider.dart';

class DesktopRightPanel extends StatelessWidget {
  const DesktopRightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Vista previa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 16),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: player.currentTrack == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sin reproducción',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 280,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.music_note, size: 80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          player.currentTrack!.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          player.currentTrack!.artist,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          player.currentTrack!.album,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Letra',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Letra no disponible\n\nUsa la función de búsqueda de letra\npara obtener las letras de tus canciones',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
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
