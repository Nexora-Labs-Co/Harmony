import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/screens/one/playlist_screen.dart';
import 'package:harmony/src/services/favorites_store.dart';
import 'package:harmony/src/services/local_music_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoritesStore.instance.paths,
      builder: (context, favPaths, _) {
        return FutureBuilder<List<LocalTrack>>(
          future: LocalMusicService.instance.scan(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final favorites = (snapshot.data ?? [])
                .where((t) => favPaths.contains(t.path))
                .toList();
            final totalMs = favorites.fold<int>(0, (s, t) => s + t.durationMs);
            return PlaylistScreen(
              title: 'Favoritos',
              backgroundColor: const Color(0xFFFA3850),
              cover: Image.asset('assets/Logo-Favoritos.png', fit: BoxFit.cover),
              totalDuration: Duration(milliseconds: totalMs),
              tracks: favorites,
              showAppBar: false,
      showMiniPlayer: false,
            );
          },
        );
      },
    );
  }
}
