import 'package:xora/xora.dart';
import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/services/player_service.dart';
import 'package:harmony/src/services/playlists_store.dart';
import 'package:harmony/src/screens/one/player_screen.dart';
import 'package:harmony/src/shared/widgets/cached_artwork.dart';

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
          child: ValueListenableBuilder<List<PlaylistEntry>>(
            valueListenable: PlaylistsStore.instance.playlists,
            builder: (context, playlists, _) {
              return Column(
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
                  ...playlists.map(
                    (PlaylistEntry e) => ListTile(
                      title: Text(e.name),
                      onTap: () {
                        PlaylistsStore.instance.addTrack(e.name, track.path);
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              );
            },
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
        return GestureDetector(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const PlayerScreen())),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 30),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                        child: const XoraIcon(XoraIcons.musicNote),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      icon: const XoraIcon(XoraIcons.plus),
                      onPressed: () => _showAddToPlaylist(context, track),
                    ),
                    IconButton(
                      icon: XoraIcon(
                        PlayerService.instance.isPlaying
                            ? XoraIcons.pause
                            : XoraIcons.playArrow,
                      ),
                      onPressed: PlayerService.instance.togglePlay,
                    ),
                    IconButton(
                      icon: const XoraIcon(XoraIcons.skipNext),
                      onPressed: PlayerService.instance.next,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
