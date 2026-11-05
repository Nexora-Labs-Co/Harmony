import 'package:flutter/material.dart';

import 'package:harmony/src/screens/one/local_screen.dart';
import 'package:harmony/src/screens/one/playlist_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlists = ['Local', 'Playlist 1', 'Playlist 2'];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: const [
              Spacer(),
              Icon(Icons.search),
              SizedBox(width: 12),
              Icon(Icons.add),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: name == 'Local'
                        ? Image.asset('assets/Logo-Local.png', fit: BoxFit.cover)
                        : const Icon(Icons.queue_music, size: 48),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
