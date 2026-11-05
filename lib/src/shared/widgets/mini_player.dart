import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/services/player_service.dart';
import 'package:harmony/src/services/playlists_store.dart';
import 'package:xora/xora.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  Future<void> _showAddToPlaylist(
    BuildContext context,
    LocalTrack track,
  ) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Nueva playlist'),
                leading: const Icon(Icons.add),
                onTap: () async {
                  Navigator.pop(ctx);
                  final name = await showDialog<String>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: const Text('Nueva playlist'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(d),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(d, controller.text.trim()),
                          child: const Text('Crear'),
                        ),
                      ],
                    ),
                  );
                  if (name == null || name.isEmpty) return;
                  PlaylistsStore.instance.add(name);
                  PlaylistsStore.instance.addTrack(name, track.path);
                },
              ),
              ...PlaylistsStore.instance.playlists.value.map(
                (e) => ListTile(
                  title: Text(e.name),
                  onTap: () {
                    PlaylistsStore.instance.addTrack(e.name, track.path);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PlayerService.instance,
      builder: (context, _) {
        final track = PlayerService.instance.currentTrack;
        if (track == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                  XoraArtwork(
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
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddToPlaylist(context, track),
                  ),
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
