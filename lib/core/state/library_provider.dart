import 'package:flutter/material.dart';

import '../models/models.dart';

class LibraryProvider extends ChangeNotifier {
  LibraryProvider() {
    _tracks = _seedTracks();
  }

  List<Track> _tracks = [];
  final Set<String> _favorites = {};

  List<Track> get allTracks => List.unmodifiable(_tracks);
  List<Track> get favorites =>
      _tracks.where((t) => _favorites.contains(t.id)).toList();

  bool isFavorite(String id) => _favorites.contains(id);

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }

  static List<Track> _seedTracks() => List.generate(
        12,
        (i) => Track(
          id: 'track_${i + 1}',
          title: 'Canción ${i + 1}',
          artist: 'Artista ${i + 1}',
          album: 'Álbum ${i + 1}',
          durationMs: 180000 + i * 15000,
        ),
      );
}
