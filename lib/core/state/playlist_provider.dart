import 'package:flutter/material.dart';

import '../models/models.dart';

class PlaylistProvider extends ChangeNotifier {
  PlaylistProvider() {
    _playlists = _seedPlaylists();
  }

  List<Playlist> _playlists = [];

  List<Playlist> get playlists => List.unmodifiable(_playlists);

  void createPlaylist(String name, String description) {
    _playlists.add(Playlist(
      id: 'playlist_${_playlists.length + 1}',
      name: name,
      description: description,
    ));
    notifyListeners();
  }

  void addTrackToPlaylist(String playlistId, String trackId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index < 0) return;
    final playlist = _playlists[index];
    if (playlist.trackIds.contains(trackId)) return;
    _playlists[index] = Playlist(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      trackIds: [...playlist.trackIds, trackId],
      coverImagePath: playlist.coverImagePath,
    );
    notifyListeners();
  }

  static List<Playlist> _seedPlaylists() => List.generate(
        4,
        (i) => Playlist(
          id: 'playlist_${i + 1}',
          name: 'Playlist ${i + 1}',
          trackIds: List.generate(3, (j) => 'track_${i * 3 + j + 1}'),
        ),
      );
}
