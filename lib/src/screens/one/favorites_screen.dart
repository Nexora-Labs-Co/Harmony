import 'package:flutter/material.dart';

import 'package:harmony/src/screens/one/playlist_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaylistScreen(
      title: 'Favoritos',
      totalDuration: Duration(minutes: 42),
    );
  }
}
