import 'package:flutter/material.dart';

import 'package:harmony/src/screens/one/local_screen.dart';
import 'package:harmony/src/screens/one/playlist_screen.dart';
import 'package:harmony/src/services/playlists_store.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlaylistScreen(
                        title: entry.name,
                        totalDuration: const Duration(minutes: 30),
                        backgroundColor: entry.color,
                      ),
                    ),
                  );
                }
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
  }
}