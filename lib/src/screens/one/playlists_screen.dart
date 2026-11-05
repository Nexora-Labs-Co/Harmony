import 'package:flutter/material.dart';

import 'package:harmony/src/screens/one/local_screen.dart';
import 'package:harmony/src/screens/one/playlist_screen.dart';
import 'package:harmony/src/services/playlist_store.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: PlaylistStore.instance.playlists,
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
            final name = playlists[index];
            return GestureDetector(
              onTap: () {
                if (name == 'Local') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LocalScreen()),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlaylistScreen(title: name, totalDuration: const Duration(minutes: 30)),
                    ),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: name == 'Local'
                        ? Image.asset('assets/Logo-Local.png', fit: BoxFit.cover)
                        : const Icon(Icons.queue_music, size: 48),
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
