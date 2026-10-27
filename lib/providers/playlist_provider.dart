import 'package:flutter/foundation.dart';
import '../bridge/bridge_generated.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];

  List<Playlist> get playlists => _playlists;

  PlaylistProvider() {
    loadPlaylists();
  }

  void loadPlaylists() {
    try {
      _playlists = nexoraGetAllPlaylists();
      notifyListeners();
    } catch (e) {
      _playlists = [];
    }
  }

  void createPlaylist(String name, String description) {
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
    try {
      nexoraAddTrackToPlaylist(playlistId: playlistId, trackId: trackId);
      loadPlaylists();
    } catch (e) {
      // ignore
    }
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    try {
      nexoraRemoveTrackFromPlaylist(playlistId: playlistId, trackId: trackId);
      loadPlaylists();
    } catch (e) {
      // ignore
    }
  }

  void renamePlaylist(String playlistId, String newName) {
    try {
      if (nexoraRenamePlaylist(playlistId: playlistId, newName: newName)) {
        loadPlaylists();
      }
    } catch (e) {
      // ignore
    }
  }
}
