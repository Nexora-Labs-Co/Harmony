import 'dart:io';
import 'package:flutter/foundation.dart';
import '../bridge/bridge_generated.dart';
import '../services/audio_service.dart';

class LibraryProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService.instance;
  
  List<Track> _allTracks = [];
  List<Track> _favorites = [];
  List<String> _favoriteIds = [];
  bool _isScanning = false;

  LibraryProvider() {
    // Auto-scan common music folders on startup
    Future.delayed(const Duration(milliseconds: 500), () {
      autoScanMusicFolders();
    });
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
      _favoriteIds = nexoraGetFavoriteIds();
      _favorites = _allTracks.where((t) => _favoriteIds.contains(t.id)).toList();
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
