import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bridge/bridge_generated.dart';
import '../services/audio_service.dart';
import '../services/music_watcher.dart';

class LibraryProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService.instance;
  
  List<Track> _allTracks = [];
  List<Track> _favorites = [];
  List<String> _favoriteIds = [];
  bool _isScanning = false;

  LibraryProvider() {
    _loadFavorites();
    // Auto-scan common music folders on startup
    Future.delayed(const Duration(milliseconds: 500), () {
      autoScanMusicFolders();
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('favorite_ids') ?? [];
      _favoriteIds = stored;
      _favorites = _allTracks.where((t) => _favoriteIds.contains(t.id)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_ids', _favoriteIds);
    } catch (_) {}
  }

  List<Track> get allTracks => _allTracks;
  List<Track> get favorites => _favorites;
  List<String> get favoriteIds => _favoriteIds;
  bool get isScanning => _isScanning;

  String _getHomeDir() {
    if (Platform.isLinux || Platform.isMacOS) {
      return Platform.environment['HOME'] ?? '/home/${Platform.environment['USER']}';
    } else if (Platform.isWindows) {
      return Platform.environment['USERPROFILE'] ?? 'C:\\\\Users\\\\${Platform.environment['USERNAME']}';
    }
    return '';
  }

  Future<void> autoScanMusicFolders() async {
    // Common music directories
    final home = _getHomeDir();
    final candidates = [
      '$home/Music',
      '$home/Música',
      '$home/music',
      '$home/Descargas',
    ];
    for (final dir in candidates) {
      try {
        final d = Directory(dir);
        if (await d.exists()) {
          await scanLibrary(dir);
          if (_allTracks.isNotEmpty) break;
        }
      } catch (_) {}
    }
  }

  Future<void> scanLibrary(String directory) async {
    _isScanning = true;
    notifyListeners();
    
    try {
      _allTracks = _audioService.scanLibrary(directory);
      // Merge persisted favorites
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('favorite_ids');
      if (stored != null) _favoriteIds = stored;
      _favorites = _allTracks.where((t) => _favoriteIds.contains(t.id)).toList();
      // Inicia watcher en segundo plano (sin bucles constantes)
      MusicWatcher.instance.start(directory, this);
    } catch (e) {
      _allTracks = [];
      _favorites = [];
    }
    
    _isScanning = false;
    notifyListeners();
  }

  void toggleFavorite(String trackId) {
    final isFav = nexoraToggleFavorite(trackId: trackId);
    if (isFav) {
      if (!_favoriteIds.contains(trackId)) {
        _favoriteIds.add(trackId);
      }
    } else {
      _favoriteIds.remove(trackId);
    }
    _favorites = _allTracks.where((t) => _favoriteIds.contains(t.id)).toList();
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String trackId) {
    return _favoriteIds.contains(trackId);
  }

  void addTracks(List<Track> tracks) {
    _allTracks.addAll(tracks);
    _favoriteIds = nexoraGetFavoriteIds();
    _favorites = _allTracks.where((t) => _favoriteIds.contains(t.id)).toList();
    notifyListeners();
  }
}
