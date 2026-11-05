import 'package:flutter/material.dart';

import '../models/track.dart';
import '../models/external_track_model.dart';

class PlayerProvider extends ChangeNotifier {
  Track? _currentTrack;
  List<Track> _queue = [];
  int _currentIndex = 0;
  final List<Track> _recentlyPlayed = [];
  bool _shuffle = false;

  Track? get currentTrack => _currentTrack;
  List<Track> get queue => List.unmodifiable(_queue);
  List<Track> get recentlyPlayed => List.unmodifiable(_recentlyPlayed);
  bool get isShuffle => _shuffle;

  void setQueue(List<Track> tracks, {int startIndex = 0}) {
    _queue = List<Track>.from(tracks);
    _currentIndex = startIndex.clamp(0, tracks.isEmpty ? 0 : tracks.length - 1);
    if (tracks.isNotEmpty) {
      _currentTrack = tracks[_currentIndex];
      _addRecent(_currentTrack!);
    }
    notifyListeners();
  }

  void playTrack(Track track) {
    _currentTrack = track;
    _addRecent(track);
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  Future<void> downloadAndQueueExternal(ExternalTrackModel external) async {
    final track = Track(
      id: external.id,
      title: external.title,
      artist: external.artist,
      durationMs: external.duration,
      albumArt: external.thumbnailUrl,
    );
    _queue = [track, ..._queue];
    _currentTrack = track;
    _addRecent(track);
    notifyListeners();
  }

  void _addRecent(Track track) {
    _recentlyPlayed.removeWhere((t) => t.id == track.id);
    _recentlyPlayed.insert(0, track);
    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed.removeLast();
    }
  }
}
