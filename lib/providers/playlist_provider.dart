import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bridge/bridge_generated.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];
  static const String _storageKey = 'harmony_playlists';
  static const int maxPlaylists = 500;

  List<Playlist> get playlists => _playlists;

  PlaylistProvider() {
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        _playlists = list.map((e) {
          final m = e as Map<String, dynamic>;
          return Playlist(
            id: m['id'] as String,
            name: m['name'] as String,
            description: (m['description'] ?? '') as String,
            trackIds: List<String>.from(m['trackIds'] ?? const []),
            createdAt: m['createdAt'] as int,
            updatedAt: m['updatedAt'] as int,
            coverImagePath: m['coverImagePath'] as String?,
          );
        }).toList();
        notifyListeners();
        return;
      }
    } catch (_) {}
    // Fallback to FFI stub (usually empty)
    try {
      final loaded = nexoraGetAllPlaylists();
      if (loaded.isNotEmpty) {
        _playlists = loaded;
        await _savePlaylists();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _playlists.map((p) => {
            'id': p.id,
            'name': p.name,
            'description': p.description,
            'trackIds': p.trackIds,
            'createdAt': p.createdAt,
            'updatedAt': p.updatedAt,
            'coverImagePath': p.coverImagePath,
          }).toList();
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (_) {}
  }

  void createPlaylist(String name, String description) {
    if (name.trim().isEmpty) return;
    if (_playlists.length >= maxPlaylists) return;
    try {
      final playlist = nexoraCreatePlaylist(name: name, description: description);
      _playlists.add(playlist);
      _savePlaylists();
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  void deletePlaylist(String playlistId) {
    try {
      nexoraDeletePlaylist(playlistId: playlistId);
    } catch (e) {
      // ignore
    }
    _playlists.removeWhere((p) => p.id == playlistId);
    _savePlaylists();
    notifyListeners();
  }

  void addTrackToPlaylist(String playlistId, String trackId) {
    if (trackId.isEmpty) return;
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    try {
      nexoraAddTrackToPlaylist(playlistId: playlistId, trackId: trackId);
    } catch (_) {}
    final playlist = _playlists[index];
    if (!playlist.trackIds.contains(trackId)) {
      playlist.trackIds.add(trackId);
    }
    _playlists[index] = Playlist(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      trackIds: List<String>.from(playlist.trackIds),
      createdAt: playlist.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      coverImagePath: playlist.coverImagePath,
    );
    _savePlaylists();
    notifyListeners();
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    try {
      nexoraRemoveTrackFromPlaylist(playlistId: playlistId, trackId: trackId);
    } catch (_) {}
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    final playlist = _playlists[index];
    playlist.trackIds.remove(trackId);
    _playlists[index] = Playlist(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      trackIds: List<String>.from(playlist.trackIds),
      createdAt: playlist.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      coverImagePath: playlist.coverImagePath,
    );
    _savePlaylists();
    notifyListeners();
  }

  void renamePlaylist(String playlistId, String newName) {
    if (newName.trim().isEmpty) return;
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    try {
      nexoraRenamePlaylist(playlistId: playlistId, newName: newName);
    } catch (_) {}
    final old = _playlists[index];
    _playlists[index] = Playlist(
      id: old.id,
      name: newName,
      description: old.description,
      trackIds: List<String>.from(old.trackIds),
      createdAt: old.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      coverImagePath: old.coverImagePath,
    );
    _savePlaylists();
    notifyListeners();
  }

  void setCoverImagePath(String playlistId, String? path) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    final old = _playlists[index];
    _playlists[index] = Playlist(
      id: old.id,
      name: old.name,
      description: old.description,
      trackIds: List<String>.from(old.trackIds),
      createdAt: old.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      coverImagePath: path,
    );
    _savePlaylists();
    notifyListeners();
  }
}
