import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/services/recent_tracks_service.dart';

class PlayerService extends ChangeNotifier {
  PlayerService._();
  static final instance = PlayerService._();

  List<LocalTrack> _queue = [];
  int _index = 0;
  bool _isPlaying = false;

  LocalTrack? get currentTrack => _queue.isEmpty ? null : _queue[_index.clamp(0, _queue.length - 1)];
  bool get isPlaying => _isPlaying;

  void play(LocalTrack track, {List<LocalTrack>? queue}) {
    if (queue != null && queue.isNotEmpty) {
      _queue = List<LocalTrack>.from(queue);
      _index = _queue.indexOf(track).clamp(0, _queue.length - 1);
      if (_index < 0) _index = 0;
    } else {
      _queue = [track];
      _index = 0;
    }
    _isPlaying = true;
    RecentTracksService.instance.record(currentTrack!);
    notifyListeners();
  }

  void playQueue(List<LocalTrack> queue, int startIndex) {
    if (queue.isEmpty) return;
    _queue = List<LocalTrack>.from(queue);
    _index = startIndex.clamp(0, queue.length - 1);
    _isPlaying = true;
    RecentTracksService.instance.record(currentTrack!);
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void next() {
    if (_queue.isEmpty) return;
    _index = (_index + 1) % _queue.length;
    _isPlaying = true;
    RecentTracksService.instance.record(currentTrack!);
    notifyListeners();
  }

  void previous() {
    if (_queue.isEmpty) return;
    _index = (_index - 1 + _queue.length) % _queue.length;
    _isPlaying = true;
    RecentTracksService.instance.record(currentTrack!);
    notifyListeners();
  }
}
