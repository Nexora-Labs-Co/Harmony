import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/screens/one/local_screen.dart';
import 'package:harmony/src/screens/one/playlist_screen.dart';
import 'package:harmony/src/services/local_music_service.dart';
import 'package:harmony/src/services/playlists_store.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LocalTrack>>(
      future: LocalMusicService.instance.scan(),
      builder: (context, snapshot) {
        final allTracks = snapshot.data ?? [];
        return ValueListenableBuilder<List<PlaylistEntry>>(
          valueListenable: PlaylistsStore.instance.playlists,
          builder: (context, playlists, _) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final entry = playlists[index];
                return GestureDetector(
                  onTap: () {
                    if (entry.name == 'Local') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LocalScreen()),
                      );
                      return;
                    }
                    final paths = PlaylistsStore.instance.tracksOf(entry.name);
                    final tracks = paths
                        .map((p) => allTracks.firstWhere((t) => t.path == p, orElse: () => allTracks.isNotEmpty ? allTracks.first : LocalTrack(path: p, title: 'Canción', artist: 'Artista')))
                        .toList();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlaylistScreen(
                          title: entry.name,
                          totalDuration: Duration(milliseconds: tracks.fold<int>(0, (s, t) => s + t.durationMs)),
                          backgroundColor: entry.color,
                          tracks: tracks,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: entry.color,
                      child: Center(
                        child: entry.name == 'Local'
                            ? Image.asset('assets/Logo-Local.png', fit: BoxFit.cover)
                            : const Icon(Icons.queue_music, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
