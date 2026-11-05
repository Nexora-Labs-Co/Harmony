import 'package:flutter/material.dart';

import 'package:harmony/src/screens/one/playlist_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaylistScreen(
      title: 'Favoritos',
      cover: Image.asset('assets/Logo-Favoritos.png', fit: BoxFit.cover),
      totalDuration: const Duration(minutes: 42),
      showAppBar: false,
    );
  }
}
