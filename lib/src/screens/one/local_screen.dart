import 'package:flutter/material.dart';

import 'package:harmony/src/services/local_music_service.dart';
import 'package:harmony/src/screens/one/playlist_screen.dart';

class LocalScreen extends StatelessWidget {
  const LocalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LocalMusicService.instance.scan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final tracks = snapshot.data ?? [];
        final totalMs = tracks.fold<int>(0, (s, t) => s + t.durationMs);
        return PlaylistScreen(
          title: 'Local',
          cover: Image.asset('assets/Logo-Local.png', fit: BoxFit.cover),
          totalDuration: Duration(milliseconds: totalMs),
          tracks: tracks,
          backgroundColor: const Color(0xFF1ED760),
        );
      },
    );
  }
}

