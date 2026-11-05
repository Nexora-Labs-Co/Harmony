import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xora/xora.dart';
import 'package:harmony/core/state/playlist_provider.dart';
import 'package:harmony/core/state/player_provider.dart';
import 'package:harmony/core/state/library_provider.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Playlists', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        for (final p in playlistProvider.playlists)
          XoraCard(
            child: ListTile(
              leading: XoraIcon(XoraIcons.list),
              title: Text(p.name),
              subtitle: Text('${p.trackIds.length} pistas'),
              onTap: () {
                final tracks = p.trackIds
                    .map((id) => library.allTracks.firstWhere((t) => t.id == id, orElse: () => library.allTracks.first))
                    .toList();
                if (tracks.isNotEmpty) player.setQueue(tracks);
              },
            ),
          ),
      ],
    );
  }
}
