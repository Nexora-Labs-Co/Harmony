import 'package:flutter/foundation.dart';
import '../bridge/bridge_generated.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];

  List<Playlist> get playlists => _playlists;

  static const int maxPlaylists = 500;

  PlaylistProvider() {
    loadPlaylists();
  }

  void loadPlaylists() {
    try {
      final loaded = nexoraGetAllPlaylists();
      if (loaded.isNotEmpty) {
        _playlists = loaded;
      }
      notifyListeners();
    } catch (e) {
      // keep existing local playlists
    }
  }

  void createPlaylist(String name, String description) {
    if (name.trim().isEmpty) return;
    if (_playlists.length >= maxPlaylists) return;
    try {
      final playlist = nexoraCreatePlaylist(name: name, description: description);
      _playlists.add(playlist);
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  void deletePlaylist(String playlistId) {
    try {
      if (nexoraDeletePlaylist(playlistId: playlistId)) {
        _playlists.removeWhere((p) => p.id == playlistId);
        notifyListeners();
      }
    } catch (e) {
      // ignore
    }
  }

  void addTrackToPlaylist(String playlistId, String trackId) {
    if (trackId.isEmpty) return;
    try {
      nexoraAddTrackToPlaylist(playlistId: playlistId, trackId: trackId);
    } catch (e) {
      // ignore
    }
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      if (!playlist.trackIds.contains(trackId)) {
        playlist.trackIds.add(trackId);
      }
      notifyListeners();
    }
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    try {
      nexoraRemoveTrackFromPlaylist(playlistId: playlistId, trackId: trackId);
    } catch (e) {
      // ignore
    }
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].trackIds.remove(trackId);
      notifyListeners();
    }
  }

  void renamePlaylist(String playlistId, String newName) {
    if (newName.trim().isEmpty) return;
    try {
      if (nexoraRenamePlaylist(playlistId: playlistId, newName: newName)) {
        final index = _playlists.indexWhere((p) => p.id == playlistId);
        if (index != -1) {
          // Playlist fields are final; recreate with new name.
          final old = _playlists[index];
          _playlists[index] = Playlist(
            id: old.id,
            name: newName,
            description: old.description,
            trackIds: List<String>.from(old.trackIds),
            createdAt: old.createdAt,
            updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      // ignore
    }
  }
}
